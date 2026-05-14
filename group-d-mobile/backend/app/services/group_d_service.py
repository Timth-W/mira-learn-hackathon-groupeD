import json
import logging
from datetime import datetime, timezone
from decimal import Decimal, ROUND_HALF_UP

from sqlalchemy import Select, and_, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.exceptions import ConflictError, NotFoundError, ValidationError
from app.integrations.openrouter import llm_client
from app.models.domain import (
    StudentNote,
    StudentNoteOrganization,
    StudentQuizAnswer,
    StudentQuizAttempt,
)
from app.schemas.group_d import (
    QuizAnswerEvaluation,
    QuizAnswersBatchUpsert,
    QuizAttemptStart,
    QuizAttemptSubmit,
    StudentNoteCreate,
    StudentNoteOrganizationCreate,
    StudentNoteUpdate,
)

logger = logging.getLogger(__name__)

_QUIZ_DEFINITIONS: dict[str, dict] = {
    "11111111-2222-3333-4444-555555559001": {
        "id": "11111111-2222-3333-4444-555555559001",
        "title": "QCM - Storytelling pour investisseurs",
        "module_id": "11111111-2222-3333-4444-555555555003",
        "class_id": "11111111-2222-3333-4444-555555555001",
        "skill_name": "Pitch investor",
        "pass_threshold_pct": "70.00",
        "questions": [
            {
                "id": "11111111-2222-3333-4444-555555551001",
                "prompt": "Quel ordre rend un pitch plus clair ?",
                "options": [
                    {"id": "a", "label": "Probleme → Solution → Traction → Ask"},
                    {"id": "b", "label": "Traction → Ask → Probleme → Equipe"},
                    {"id": "c", "label": "Equipe → Vision → Problemes secondaires"},
                ],
                "correct_option_ids": ["a"],
                "points": 1,
            },
            {
                "id": "11111111-2222-3333-4444-555555551002",
                "prompt": "Quel element aide le plus a capter l attention en debut de pitch ?",
                "options": [
                    {"id": "a", "label": "Une liste de KPI"},
                    {"id": "b", "label": "Un hook concret et memorisable"},
                    {"id": "c", "label": "Le detail du cap table"},
                ],
                "correct_option_ids": ["b"],
                "points": 1,
            },
            {
                "id": "11111111-2222-3333-4444-555555551003",
                "prompt": "Quand presenter la traction ?",
                "options": [
                    {"id": "a", "label": "Jamais, cela coupe l emotion"},
                    {"id": "b", "label": "Apres la solution pour credibiliser le pitch"},
                    {"id": "c", "label": "Uniquement en annexe"},
                ],
                "correct_option_ids": ["b"],
                "points": 1,
            },
            {
                "id": "11111111-2222-3333-4444-555555551004",
                "prompt": "Que doit contenir un bon ask final ?",
                "options": [
                    {"id": "a", "label": "Un besoin clair et relie a la prochaine etape"},
                    {"id": "b", "label": "Une longue biographie du fondateur"},
                    {"id": "c", "label": "Le planning de tous les posts LinkedIn"},
                ],
                "correct_option_ids": ["a"],
                "points": 1,
            },
            {
                "id": "11111111-2222-3333-4444-555555551005",
                "prompt": "Quel ton est recommande pour repondre a une objection investisseur ?",
                "options": [
                    {"id": "a", "label": "Defensif pour montrer sa conviction"},
                    {"id": "b", "label": "Calme, factuel et recentre sur le risque traite"},
                    {"id": "c", "label": "Tres technique des la premiere phrase"},
                ],
                "correct_option_ids": ["b"],
                "points": 1,
            },
        ],
    },
    "11111111-2222-3333-4444-555555559002": {
        "id": "11111111-2222-3333-4444-555555559002",
        "title": "QCM - Objections et FAQ",
        "module_id": "11111111-2222-3333-4444-555555555004",
        "class_id": "11111111-2222-3333-4444-555555555001",
        "skill_name": "Gestion des objections",
        "pass_threshold_pct": "70.00",
        "questions": [
            {
                "id": "11111111-2222-3333-4444-555555552001",
                "prompt": "Face a une objection, quel reflexe est prefere ?",
                "options": [
                    {"id": "a", "label": "Reformuler avant de repondre"},
                    {"id": "b", "label": "Couper la personne pour rectifier"},
                    {"id": "c", "label": "Changer completement de sujet"},
                ],
                "correct_option_ids": ["a"],
                "points": 1,
            },
        ],
    },
}


def _apply_note_filters(
    query: Select,
    class_id: str | None,
    module_id: str | None,
    is_favorite: bool | None,
    tags: list[str] | None,
) -> Select:
    if class_id:
        query = query.where(StudentNote.class_id == class_id)
    if module_id:
        query = query.where(StudentNote.module_id == module_id)
    if is_favorite is not None:
        query = query.where(StudentNote.is_favorite == is_favorite)
    if tags:
        query = query.where(StudentNote.tags.contains(tags))
    return query


def _learning_takeaway(content: str) -> str:
    text = " ".join(content.strip().split())
    if not text:
        return "Revoir cette idee et la rattacher a un exemple concret."

    lowered = text.lower()
    if ">" in text:
        parts = [part.strip(" .") for part in text.split(">")]
        if len(parts) >= 2 and parts[0] and parts[1]:
            return f"Prioriser {parts[0]} plutot que {parts[1]}."
    if "doit" in lowered:
        return text.replace("doit", "doit absolument", 1)
    if ":" in text:
        title, detail = text.split(":", 1)
        return f"{title.strip()} : retenir la structure {detail.strip()}"
    return text if text.endswith(".") else f"{text}."


def _concept_description(concept_name: str, notes_count: int) -> str:
    labels = {
        "seo": "Optimiser la visibilite en distinguant les leviers vraiment utiles des actions de volume.",
        "pitch": "Construire un message court, clair et convaincant pour un investisseur.",
        "storytelling": "Transformer une idee en narration memorisable avec une progression logique.",
        "growth": "Tester vite, mesurer, puis concentrer l'effort sur ce qui convertit.",
        "feedback": "Formuler un retour utile, actionnable et recevable par l'autre personne.",
        "leadership": "Clarifier la posture de decision et l'impact sur l'equipe.",
        "communication": "Rendre un message plus clair en separant faits, ressenti, besoin et demande.",
    }
    if concept_name in labels:
        return labels[concept_name]
    return f"Concept a reviser a partir de {notes_count} note(s), avec exemples et cas d'usage."


def _local_learning_sheet(notes: list[StudentNote], scope_module_id: str | None) -> dict:
    concepts_map: dict[str, list[StudentNote]] = {}
    for note in notes:
        key = note.tags[0] if note.tags else "general"
        concepts_map.setdefault(key, []).append(note)

    concepts = []
    for concept_name, concept_notes in concepts_map.items():
        key_points = [_learning_takeaway(n.content) for n in concept_notes[:3]]
        concepts.append(
            {
                "concept_name": concept_name,
                "description": _concept_description(concept_name, len(concept_notes)),
                "related_note_ids": [n.id for n in concept_notes],
                "key_points": key_points,
            }
        )

    scope = "ce module" if scope_module_id else "cette classe"
    return {
        "summary": (
            f"Fiche de revision generee pour {scope}: {len(notes)} note(s) transformee(s) "
            f"en {len(concepts)} concept(s) et points a retenir."
        ),
        "concepts": concepts,
        "key_takeaways": [_learning_takeaway(n.content) for n in notes[:4]],
        "generated_by_llm": False,
        "llm_model_used": "local-fallback",
        "llm_tokens_consumed": None,
    }


async def _generate_learning_sheet(notes: list[StudentNote], scope_module_id: str | None) -> dict:
    notes_payload = [
        {
            "id": note.id,
            "module_id": note.module_id,
            "tags": note.tags,
            "content": note.content,
        }
        for note in notes
    ]
    system_prompt = (
        "Tu es Mira Learn, un assistant pedagogique pour nomades apprenants. "
        "Transforme des notes brutes en vraie fiche de revision. "
        "Ne te contente pas de recopier: reformule, clarifie, structure, rends memorisable. "
        "Retourne uniquement du JSON valide."
    )
    user_prompt = (
        "Cree une fiche de revision a partir de ces notes.\n"
        "Contraintes:\n"
        "- summary: synthese courte en 2 phrases maximum.\n"
        "- key_takeaways: 3 a 5 points reformules, actionnables pour reviser.\n"
        "- concepts: groupes pedagogiques avec concept_name, description, related_note_ids, key_points.\n"
        "- related_note_ids doit uniquement contenir des ids fournis.\n"
        "- key_points doivent etre des reformulations utiles, pas des copies mot a mot.\n\n"
        f"Notes JSON:\n{json.dumps(notes_payload, ensure_ascii=False)}"
    )

    try:
        response = await llm_client.complete(
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            temperature=0.25,
            max_tokens=1000,
            response_format={"type": "json_object"},
        )
        content = response["content"].strip()
        sheet = json.loads(content)
        return {
            "summary": str(sheet.get("summary") or ""),
            "concepts": sheet.get("concepts") or [],
            "key_takeaways": sheet.get("key_takeaways") or [],
            "generated_by_llm": True,
            "llm_model_used": settings.OPENROUTER_DEFAULT_MODEL,
            "llm_tokens_consumed": (response.get("usage") or {}).get("total_tokens"),
        }
    except Exception as exc:
        logger.warning("LLM note organization failed, using local fallback: %s", exc)
        return _local_learning_sheet(notes, scope_module_id)


async def list_notes(
    db: AsyncSession,
    user_id: str,
    class_id: str | None,
    module_id: str | None,
    is_favorite: bool | None,
    tags: list[str] | None,
) -> list[StudentNote]:
    query = (
        select(StudentNote)
        .where(StudentNote.user_id == user_id)
        .where(StudentNote.deleted_at.is_(None))
        .order_by(StudentNote.created_at.desc())
    )
    query = _apply_note_filters(query, class_id, module_id, is_favorite, tags)
    result = await db.execute(query)
    return list(result.scalars().all())


async def create_note(db: AsyncSession, user_id: str, body: StudentNoteCreate) -> StudentNote:
    note = StudentNote(
        user_id=user_id,
        class_id=body.class_id,
        session_id=body.session_id,
        module_id=body.module_id,
        content=body.content,
        tags=body.tags,
        replay_timecode_seconds=body.replay_timecode_seconds,
        is_favorite=body.is_favorite,
        color=body.color,
    )
    db.add(note)
    await db.flush()
    await db.refresh(note)
    return note


async def get_note(db: AsyncSession, user_id: str, note_id: str, include_deleted: bool = False) -> StudentNote:
    query = select(StudentNote).where(StudentNote.id == note_id, StudentNote.user_id == user_id)
    if not include_deleted:
        query = query.where(StudentNote.deleted_at.is_(None))
    result = await db.execute(query)
    note = result.scalars().first()
    if not note:
        raise NotFoundError("StudentNote", note_id)
    return note


async def update_note(db: AsyncSession, user_id: str, note_id: str, body: StudentNoteUpdate) -> StudentNote:
    note = await get_note(db, user_id, note_id)
    data = body.model_dump(exclude_unset=True)

    if "content" in data:
        note.content = data["content"]
    if "tags" in data:
        note.tags = data["tags"]
    if "replay_timecode_seconds" in data:
        note.replay_timecode_seconds = data["replay_timecode_seconds"]
    if "is_favorite" in data:
        note.is_favorite = data["is_favorite"]
    if "color" in data:
        note.color = data["color"]

    await db.flush()
    await db.refresh(note)
    return note


async def delete_note(db: AsyncSession, user_id: str, note_id: str) -> None:
    note = await get_note(db, user_id, note_id)
    note.deleted_at = datetime.now(timezone.utc)
    await db.flush()


async def restore_note(db: AsyncSession, user_id: str, note_id: str) -> StudentNote:
    note = await get_note(db, user_id, note_id, include_deleted=True)
    note.deleted_at = None
    await db.flush()
    await db.refresh(note)
    return note


async def create_note_organization(
    db: AsyncSession,
    user_id: str,
    body: StudentNoteOrganizationCreate,
    llm_model_used: str,
) -> StudentNoteOrganization:
    day_start = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0)
    daily_count_query = select(func.count(StudentNoteOrganization.id)).where(
        StudentNoteOrganization.user_id == user_id,
        StudentNoteOrganization.created_at >= day_start,
    )
    daily_count = (await db.execute(daily_count_query)).scalar_one()
    if daily_count >= 50:
        raise ConflictError("Rate limit reached: max 50 note organizations per day")

    notes_query = select(StudentNote).where(
        StudentNote.user_id == user_id,
        StudentNote.class_id == body.class_id,
        StudentNote.deleted_at.is_(None),
    )
    if body.scope_module_id:
        notes_query = notes_query.where(StudentNote.module_id == body.scope_module_id)

    notes_result = await db.execute(notes_query.order_by(StudentNote.created_at.desc()))
    notes = list(notes_result.scalars().all())
    if not notes:
        raise ValidationError("Pas de notes a organiser")

    sheet = await _generate_learning_sheet(notes, body.scope_module_id)

    org = StudentNoteOrganization(
        user_id=user_id,
        class_id=body.class_id,
        scope_module_id=body.scope_module_id,
        note_ids_organized=[n.id for n in notes],
        summary=sheet["summary"],
        concepts=sheet["concepts"],
        key_takeaways=sheet["key_takeaways"],
        generated_by_llm=sheet["generated_by_llm"],
        llm_model_used=sheet["llm_model_used"] or llm_model_used,
        llm_tokens_consumed=sheet["llm_tokens_consumed"],
    )
    db.add(org)
    await db.flush()
    await db.refresh(org)
    return org


async def list_note_organizations(db: AsyncSession, user_id: str) -> list[StudentNoteOrganization]:
    result = await db.execute(
        select(StudentNoteOrganization)
        .where(StudentNoteOrganization.user_id == user_id)
        .order_by(StudentNoteOrganization.created_at.desc())
    )
    return list(result.scalars().all())


async def get_note_organization(db: AsyncSession, user_id: str, organization_id: str) -> StudentNoteOrganization:
    result = await db.execute(
        select(StudentNoteOrganization).where(
            StudentNoteOrganization.id == organization_id,
            StudentNoteOrganization.user_id == user_id,
        )
    )
    organization = result.scalars().first()
    if not organization:
        raise NotFoundError("StudentNoteOrganization", organization_id)
    return organization


async def delete_note_organization(db: AsyncSession, user_id: str, organization_id: str) -> None:
    organization = await get_note_organization(db, user_id, organization_id)
    await db.delete(organization)
    await db.flush()


async def start_quiz_attempt(db: AsyncSession, user_id: str, quiz_id: str, body: QuizAttemptStart) -> StudentQuizAttempt:
    started_attempt = await db.execute(
        select(StudentQuizAttempt).where(
            StudentQuizAttempt.user_id == user_id,
            StudentQuizAttempt.quiz_id == quiz_id,
            StudentQuizAttempt.status == "started",
        )
    )
    existing_attempt = started_attempt.scalars().first()
    if existing_attempt is not None:
        return existing_attempt

    max_attempt_query = select(func.max(StudentQuizAttempt.attempt_number)).where(
        StudentQuizAttempt.user_id == user_id,
        StudentQuizAttempt.quiz_id == quiz_id,
    )
    current_max = (await db.execute(max_attempt_query)).scalar_one()
    next_attempt_number = (current_max or 0) + 1
    if next_attempt_number > body.max_attempts:
        raise ConflictError("Maximum attempts reached", data={"max_attempts": body.max_attempts})

    attempt = StudentQuizAttempt(
        user_id=user_id,
        quiz_id=quiz_id,
        module_id=body.module_id,
        class_id=body.class_id,
        attempt_number=next_attempt_number,
        status="started",
        max_score=body.max_score,
    )
    db.add(attempt)
    await db.flush()
    await db.refresh(attempt)
    return attempt


async def list_quiz_attempts(db: AsyncSession, user_id: str, quiz_id: str) -> list[StudentQuizAttempt]:
    result = await db.execute(
        select(StudentQuizAttempt)
        .where(StudentQuizAttempt.user_id == user_id, StudentQuizAttempt.quiz_id == quiz_id)
        .order_by(StudentQuizAttempt.attempt_number.desc())
    )
    return list(result.scalars().all())


async def list_all_attempts(db: AsyncSession, user_id: str) -> list[StudentQuizAttempt]:
    result = await db.execute(
        select(StudentQuizAttempt)
        .where(StudentQuizAttempt.user_id == user_id)
        .order_by(StudentQuizAttempt.created_at.desc())
    )
    return list(result.scalars().all())


def get_quiz_definition(quiz_id: str) -> dict:
    quiz = _QUIZ_DEFINITIONS.get(quiz_id)
    if quiz is None:
        raise NotFoundError("Quiz", quiz_id)

    max_score = sum(int(question["points"]) for question in quiz["questions"])
    return {
        **quiz,
        "max_score": max_score,
        "question_count": len(quiz["questions"]),
    }


async def get_attempt(db: AsyncSession, user_id: str, attempt_id: str) -> StudentQuizAttempt:
    result = await db.execute(
        select(StudentQuizAttempt).where(
            StudentQuizAttempt.id == attempt_id,
            StudentQuizAttempt.user_id == user_id,
        )
    )
    attempt = result.scalars().first()
    if not attempt:
        raise NotFoundError("StudentQuizAttempt", attempt_id)
    return attempt


async def upsert_attempt_answers(
    db: AsyncSession,
    user_id: str,
    attempt_id: str,
    body: QuizAnswersBatchUpsert,
) -> list[StudentQuizAnswer]:
    attempt = await get_attempt(db, user_id, attempt_id)
    if attempt.status != "started":
        raise ConflictError("Answers can only be updated while attempt status is 'started'")

    saved: list[StudentQuizAnswer] = []
    for answer in body.answers:
        existing_result = await db.execute(
            select(StudentQuizAnswer).where(
                StudentQuizAnswer.attempt_id == attempt.id,
                StudentQuizAnswer.question_id == answer.question_id,
            )
        )
        existing = existing_result.scalars().first()
        if existing:
            existing.selected_option_ids = answer.selected_option_ids
            saved.append(existing)
            continue

        created = StudentQuizAnswer(
            attempt_id=attempt.id,
            question_id=answer.question_id,
            selected_option_ids=answer.selected_option_ids,
        )
        db.add(created)
        saved.append(created)

    await db.flush()
    for item in saved:
        await db.refresh(item)
    return saved


async def list_attempt_answers(db: AsyncSession, user_id: str, attempt_id: str) -> list[StudentQuizAnswer]:
    attempt = await get_attempt(db, user_id, attempt_id)
    result = await db.execute(
        select(StudentQuizAnswer)
        .where(StudentQuizAnswer.attempt_id == attempt.id)
        .order_by(StudentQuizAnswer.answered_at.asc())
    )
    return list(result.scalars().all())


def _score_answer(answer: StudentQuizAnswer, evaluation: QuizAnswerEvaluation) -> tuple[bool, int]:
    is_correct = set(answer.selected_option_ids) == set(evaluation.correct_option_ids)
    points = evaluation.points if is_correct else 0
    return is_correct, points


async def submit_attempt(db: AsyncSession, user_id: str, attempt_id: str, body: QuizAttemptSubmit) -> StudentQuizAttempt:
    attempt = await get_attempt(db, user_id, attempt_id)
    if attempt.status != "started":
        raise ConflictError("Only 'started' attempts can be submitted")

    answers_result = await db.execute(
        select(StudentQuizAnswer).where(StudentQuizAnswer.attempt_id == attempt.id)
    )
    answers = list(answers_result.scalars().all())

    eval_by_question = {item.question_id: item for item in body.evaluations}
    total_score = 0
    for answer in answers:
        evaluation = eval_by_question.get(answer.question_id)
        if not evaluation:
            continue
        is_correct, points = _score_answer(answer, evaluation)
        answer.is_correct = is_correct
        answer.points_earned = points
        total_score += points

    if attempt.max_score <= 0:
        raise ValidationError("Attempt max_score must be greater than 0", field="max_score")

    score_pct = (Decimal(total_score) / Decimal(attempt.max_score)) * Decimal("100")
    score_pct = score_pct.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)

    attempt.score = total_score
    attempt.score_pct = score_pct
    attempt.passed = score_pct >= body.pass_threshold_pct
    attempt.status = "submitted"
    attempt.submitted_at = datetime.now(timezone.utc)
    attempt.time_spent_seconds = body.time_spent_seconds

    await db.flush()
    await db.refresh(attempt)
    return attempt


async def abandon_attempt(db: AsyncSession, user_id: str, attempt_id: str) -> StudentQuizAttempt:
    attempt = await get_attempt(db, user_id, attempt_id)
    if attempt.status != "started":
        raise ConflictError("Only 'started' attempts can be abandoned")

    attempt.status = "abandoned"
    await db.flush()
    await db.refresh(attempt)
    return attempt

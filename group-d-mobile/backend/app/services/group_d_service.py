from datetime import datetime, timezone
from decimal import Decimal, ROUND_HALF_UP

from sqlalchemy import Select, and_, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import ConflictError, NotFoundError, ValidationError
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
    if daily_count >= 5:
        raise ConflictError("Rate limit reached: max 5 note organizations per day")

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

    concepts_map: dict[str, list[StudentNote]] = {}
    for note in notes:
        key = note.tags[0] if note.tags else "general"
        concepts_map.setdefault(key, []).append(note)

    concepts = []
    for concept_name, concept_notes in concepts_map.items():
        concepts.append(
            {
                "concept_name": concept_name,
                "description": f"Regroupement automatique du concept '{concept_name}'",
                "related_note_ids": [n.id for n in concept_notes],
                "key_points": [n.content[:120] for n in concept_notes[:3]],
            }
        )

    key_takeaways = [n.content[:120] for n in notes[:3]]
    summary = f"{len(notes)} notes organisees sur {len(concepts)} concepts."

    org = StudentNoteOrganization(
        user_id=user_id,
        class_id=body.class_id,
        scope_module_id=body.scope_module_id,
        note_ids_organized=[n.id for n in notes],
        summary=summary,
        concepts=concepts,
        key_takeaways=key_takeaways,
        generated_by_llm=False,
        llm_model_used=llm_model_used,
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
    if started_attempt.scalars().first() is not None:
        raise ConflictError("An attempt is already in progress for this quiz")

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
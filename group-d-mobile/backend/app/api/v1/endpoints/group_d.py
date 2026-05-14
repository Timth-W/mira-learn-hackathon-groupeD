from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.auth import AuthenticatedUser, require_auth
from app.core.db import get_db
from app.core.responses import fail_response, success_response
from app.schemas.group_d import (
    QuizAnswersBatchUpsert,
    QuizAttemptStart,
    QuizAttemptSubmit,
    StudentNoteCreate,
    StudentNoteOrganizationCreate,
    StudentNoteOrganizationRead,
    StudentNoteRead,
    StudentNoteUpdate,
    StudentQuizAnswerRead,
    StudentQuizAttemptRead,
)
from app.services import group_d_service

router = APIRouter()

@router.post("/students/me/notes", status_code=status.HTTP_201_CREATED)
async def create_note(
    body: StudentNoteCreate,
    db: AsyncSession = Depends(get_db),
    user: AuthenticatedUser = Depends(require_auth),
) -> dict:
    note = await group_d_service.create_note(db, user.user_id, body)
    return success_response(
        data=StudentNoteRead.model_validate(note).model_dump(mode="json"),
        message="Note creee",
    )


@router.get("/students/me/notes")
async def list_notes(
    db: AsyncSession = Depends(get_db),
    user: AuthenticatedUser = Depends(require_auth),
    class_id: str | None = Query(default=None),
    module_id: str | None = Query(default=None),
    is_favorite: bool | None = Query(default=None),
    tags: list[str] | None = Query(default=None),
) -> dict:
    notes = await group_d_service.list_notes(db, user.user_id, class_id, module_id, is_favorite, tags)
    return success_response(data=[StudentNoteRead.model_validate(n).model_dump(mode="json") for n in notes])


@router.get("/students/me/notes/{note_id}")
async def get_note(
    note_id: str,
    db: AsyncSession = Depends(get_db),
    user: AuthenticatedUser = Depends(require_auth),
) -> dict:
    note = await group_d_service.get_note(db, user.user_id, note_id)
    return success_response(data=StudentNoteRead.model_validate(note).model_dump(mode="json"))


@router.patch("/students/me/notes/{note_id}")
async def update_note(
    note_id: str,
    body: StudentNoteUpdate,
    db: AsyncSession = Depends(get_db),
    user: AuthenticatedUser = Depends(require_auth),
) -> dict:
    if not body.model_dump(exclude_unset=True):
        return fail_response(data={"body": "no fields to update"}, message="Empty update body")

    note = await group_d_service.update_note(db, user.user_id, note_id, body)
    return success_response(data=StudentNoteRead.model_validate(note).model_dump(mode="json"))


@router.delete("/students/me/notes/{note_id}")
async def delete_note(
    note_id: str,
    db: AsyncSession = Depends(get_db),
    user: AuthenticatedUser = Depends(require_auth),
) -> dict:
    await group_d_service.delete_note(db, user.user_id, note_id)
    return success_response(data=None, message="Note supprimee")


@router.post("/students/me/notes/{note_id}/restore")
async def restore_note(
    note_id: str,
    db: AsyncSession = Depends(get_db),
    user: AuthenticatedUser = Depends(require_auth),
) -> dict:
    note = await group_d_service.restore_note(db, user.user_id, note_id)
    return success_response(data=StudentNoteRead.model_validate(note).model_dump(mode="json"))


@router.post("/students/me/note-organizations", status_code=status.HTTP_201_CREATED)
async def create_note_organization(
    body: StudentNoteOrganizationCreate,
    db: AsyncSession = Depends(get_db),
    user: AuthenticatedUser = Depends(require_auth),
) -> dict:
    organization = await group_d_service.create_note_organization(
        db,
        user.user_id,
        body,
        llm_model_used="local-fallback",
    )
    return success_response(data=StudentNoteOrganizationRead.model_validate(organization).model_dump(mode="json"))


@router.get("/students/me/note-organizations")
async def list_note_organizations(
    db: AsyncSession = Depends(get_db),
    user: AuthenticatedUser = Depends(require_auth),
) -> dict:
    organizations = await group_d_service.list_note_organizations(db, user.user_id)
    return success_response(data=[StudentNoteOrganizationRead.model_validate(o).model_dump(mode="json") for o in organizations])


@router.get("/students/me/note-organizations/{organization_id}")
async def get_note_organization(
    organization_id: str,
    db: AsyncSession = Depends(get_db),
    user: AuthenticatedUser = Depends(require_auth),
) -> dict:
    organization = await group_d_service.get_note_organization(db, user.user_id, organization_id)
    return success_response(data=StudentNoteOrganizationRead.model_validate(organization).model_dump(mode="json"))


@router.delete("/students/me/note-organizations/{organization_id}")
async def delete_note_organization(
    organization_id: str,
    db: AsyncSession = Depends(get_db),
    user: AuthenticatedUser = Depends(require_auth),
) -> dict:
    await group_d_service.delete_note_organization(db, user.user_id, organization_id)
    return success_response(data=None, message="Note organization supprimee")


@router.post("/students/me/quizzes/{quiz_id}/attempts", status_code=status.HTTP_201_CREATED)
async def start_quiz_attempt(
    quiz_id: str,
    body: QuizAttemptStart,
    db: AsyncSession = Depends(get_db),
    user: AuthenticatedUser = Depends(require_auth),
) -> dict:
    attempt = await group_d_service.start_quiz_attempt(db, user.user_id, quiz_id, body)
    return success_response(data=StudentQuizAttemptRead.model_validate(attempt).model_dump(mode="json"))


@router.get("/students/me/quizzes/{quiz_id}/attempts")
async def list_quiz_attempts(
    quiz_id: str,
    db: AsyncSession = Depends(get_db),
    user: AuthenticatedUser = Depends(require_auth),
) -> dict:
    attempts = await group_d_service.list_quiz_attempts(db, user.user_id, quiz_id)
    return success_response(data=[StudentQuizAttemptRead.model_validate(a).model_dump(mode="json") for a in attempts])


@router.get("/students/me/attempts/{attempt_id}")
async def get_attempt(
    attempt_id: str,
    db: AsyncSession = Depends(get_db),
    user: AuthenticatedUser = Depends(require_auth),
) -> dict:
    attempt = await group_d_service.get_attempt(db, user.user_id, attempt_id)
    return success_response(data=StudentQuizAttemptRead.model_validate(attempt).model_dump(mode="json"))


@router.patch("/students/me/attempts/{attempt_id}/answers")
async def patch_attempt_answers(
    attempt_id: str,
    body: QuizAnswersBatchUpsert,
    db: AsyncSession = Depends(get_db),
    user: AuthenticatedUser = Depends(require_auth),
) -> dict:
    answers = await group_d_service.upsert_attempt_answers(db, user.user_id, attempt_id, body)
    return success_response(data=[StudentQuizAnswerRead.model_validate(a).model_dump(mode="json") for a in answers])


@router.put("/students/me/attempts/{attempt_id}/answers")
async def put_attempt_answers(
    attempt_id: str,
    body: QuizAnswersBatchUpsert,
    db: AsyncSession = Depends(get_db),
    user: AuthenticatedUser = Depends(require_auth),
) -> dict:
    answers = await group_d_service.upsert_attempt_answers(db, user.user_id, attempt_id, body)
    return success_response(data=[StudentQuizAnswerRead.model_validate(a).model_dump(mode="json") for a in answers])


@router.get("/students/me/attempts/{attempt_id}/answers")
async def list_attempt_answers(
    attempt_id: str,
    db: AsyncSession = Depends(get_db),
    user: AuthenticatedUser = Depends(require_auth),
) -> dict:
    answers = await group_d_service.list_attempt_answers(db, user.user_id, attempt_id)
    return success_response(data=[StudentQuizAnswerRead.model_validate(a).model_dump(mode="json") for a in answers])


@router.post("/students/me/attempts/{attempt_id}/submit")
async def submit_attempt(
    attempt_id: str,
    body: QuizAttemptSubmit,
    db: AsyncSession = Depends(get_db),
    user: AuthenticatedUser = Depends(require_auth),
) -> dict:
    attempt = await group_d_service.submit_attempt(db, user.user_id, attempt_id, body)
    return success_response(data=StudentQuizAttemptRead.model_validate(attempt).model_dump(mode="json"))


@router.post("/students/me/attempts/{attempt_id}/abandon")
async def abandon_attempt(
    attempt_id: str,
    db: AsyncSession = Depends(get_db),
    user: AuthenticatedUser = Depends(require_auth),
) -> dict:
    attempt = await group_d_service.abandon_attempt(db, user.user_id, attempt_id)
    return success_response(data=StudentQuizAttemptRead.model_validate(attempt).model_dump(mode="json"))


@router.get("/students/me/quiz-attempts")
async def list_all_attempts(
    db: AsyncSession = Depends(get_db),
    user: AuthenticatedUser = Depends(require_auth),
) -> dict:
    attempts = await group_d_service.list_all_attempts(db, user.user_id)
    return success_response(data=[StudentQuizAttemptRead.model_validate(a).model_dump(mode="json") for a in attempts])


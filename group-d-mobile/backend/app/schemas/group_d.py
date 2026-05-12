from datetime import datetime
from decimal import Decimal
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


AttemptStatus = Literal["started", "submitted", "expired", "abandoned"]
NoteColor = Literal["yellow", "green", "red", "blue", "purple"]


class StudentNoteCreate(BaseModel):
    class_id: str
    session_id: str | None = None
    module_id: str | None = None
    content: str = Field(default="", max_length=50000)
    tags: list[str] = Field(default_factory=list)
    replay_timecode_seconds: int | None = Field(default=None, ge=0)
    is_favorite: bool = False
    color: NoteColor | None = None


class StudentNoteUpdate(BaseModel):
    content: str | None = None
    tags: list[str] | None = None
    replay_timecode_seconds: int | None = Field(default=None, ge=0)
    is_favorite: bool | None = None
    color: NoteColor | None = None


class StudentNoteRead(BaseModel):
    id: str
    user_id: str
    class_id: str
    session_id: str | None
    module_id: str | None
    content: str
    tags: list[str]
    replay_timecode_seconds: int | None
    is_favorite: bool
    color: str | None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class StudentNoteOrganizationCreate(BaseModel):
    class_id: str
    scope_module_id: str | None = None


class OrganizedConcept(BaseModel):
    concept_name: str
    description: str
    related_note_ids: list[str]
    key_points: list[str]


class StudentNoteOrganizationRead(BaseModel):
    id: str
    user_id: str
    class_id: str
    scope_module_id: str | None
    note_ids_organized: list[str]
    summary: str
    concepts: list[OrganizedConcept]
    key_takeaways: list[str]
    generated_by_llm: bool
    llm_model_used: str
    llm_tokens_consumed: int | None
    generation_latency_ms: int | None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class QuizAttemptStart(BaseModel):
    module_id: str
    class_id: str
    max_score: int = Field(ge=1)
    max_attempts: int = Field(default=3, ge=1, le=20)


class QuizAnswerUpsert(BaseModel):
    question_id: str
    selected_option_ids: list[str]


class QuizAnswersBatchUpsert(BaseModel):
    answers: list[QuizAnswerUpsert]


class QuizAnswerEvaluation(BaseModel):
    question_id: str
    correct_option_ids: list[str]
    points: int = Field(default=1, ge=0)


class QuizAttemptSubmit(BaseModel):
    pass_threshold_pct: Decimal = Field(default=Decimal("70.00"), ge=Decimal("0"), le=Decimal("100"))
    time_spent_seconds: int | None = Field(default=None, ge=0)
    evaluations: list[QuizAnswerEvaluation]


class StudentQuizAnswerRead(BaseModel):
    id: str
    attempt_id: str
    question_id: str
    selected_option_ids: list[str]
    is_correct: bool | None
    points_earned: int | None
    answered_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class StudentQuizAttemptRead(BaseModel):
    id: str
    user_id: str
    quiz_id: str
    module_id: str
    class_id: str
    attempt_number: int
    status: AttemptStatus
    started_at: datetime
    submitted_at: datetime | None
    expired_at: datetime | None
    time_spent_seconds: int | None
    score: int | None
    max_score: int
    score_pct: Decimal | None
    passed: bool | None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
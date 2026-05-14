from datetime import datetime
from decimal import Decimal

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    DateTime,
    ForeignKey,
    Integer,
    Numeric,
    String,
    Text,
    UniqueConstraint,
    func,
    text,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base, SoftDeleteMixin, TimestampMixin


class StudentNote(Base, TimestampMixin, SoftDeleteMixin):
    __tablename__ = "student_note"

    id: Mapped[str] = mapped_column(UUID(as_uuid=False), primary_key=True, server_default=text("uuid_generate_v4()"))
    user_id: Mapped[str] = mapped_column(UUID(as_uuid=False), nullable=False, index=True)
    class_id: Mapped[str] = mapped_column(UUID(as_uuid=False), nullable=False, index=True)
    session_id: Mapped[str | None] = mapped_column(UUID(as_uuid=False), nullable=True)
    module_id: Mapped[str | None] = mapped_column(UUID(as_uuid=False), nullable=True)
    content: Mapped[str] = mapped_column(Text, nullable=False, default="")
    tags: Mapped[list[str]] = mapped_column(JSONB, nullable=False, default=list)
    replay_timecode_seconds: Mapped[int | None] = mapped_column(Integer, nullable=True)
    is_favorite: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    color: Mapped[str | None] = mapped_column(String(16), nullable=True)


class StudentNoteOrganization(Base):
    __tablename__ = "student_note_organization"

    id: Mapped[str] = mapped_column(UUID(as_uuid=False), primary_key=True, server_default=text("uuid_generate_v4()"))
    user_id: Mapped[str] = mapped_column(UUID(as_uuid=False), nullable=False, index=True)
    class_id: Mapped[str] = mapped_column(UUID(as_uuid=False), nullable=False, index=True)
    scope_module_id: Mapped[str | None] = mapped_column(UUID(as_uuid=False), nullable=True)
    note_ids_organized: Mapped[list[str]] = mapped_column(JSONB, nullable=False, default=list)
    summary: Mapped[str] = mapped_column(Text, nullable=False)
    concepts: Mapped[list[dict]] = mapped_column(JSONB, nullable=False, default=list)
    key_takeaways: Mapped[list[str]] = mapped_column(JSONB, nullable=False, default=list)
    generated_by_llm: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    llm_model_used: Mapped[str] = mapped_column(String(64), nullable=False)
    llm_tokens_consumed: Mapped[int | None] = mapped_column(Integer, nullable=True)
    generation_latency_ms: Mapped[int | None] = mapped_column(Integer, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, server_default=func.now())


class StudentQuizAttempt(Base, TimestampMixin):
    __tablename__ = "student_quiz_attempt"
    __table_args__ = (
        CheckConstraint("status IN ('started', 'submitted', 'expired', 'abandoned')", name="student_quiz_attempt_status_check"),
        CheckConstraint("score_pct IS NULL OR score_pct BETWEEN 0 AND 100", name="student_quiz_attempt_score_pct_check"),
        UniqueConstraint("user_id", "quiz_id", "attempt_number", name="uq_student_quiz_attempt_user_quiz_num"),
    )

    id: Mapped[str] = mapped_column(UUID(as_uuid=False), primary_key=True, server_default=text("uuid_generate_v4()"))
    user_id: Mapped[str] = mapped_column(UUID(as_uuid=False), nullable=False, index=True)
    quiz_id: Mapped[str] = mapped_column(UUID(as_uuid=False), nullable=False, index=True)
    module_id: Mapped[str] = mapped_column(UUID(as_uuid=False), nullable=False)
    class_id: Mapped[str] = mapped_column(UUID(as_uuid=False), nullable=False, index=True)
    attempt_number: Mapped[int] = mapped_column(Integer, nullable=False)
    status: Mapped[str] = mapped_column(String(16), nullable=False, default="started")
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, server_default=func.now())
    submitted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    expired_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    time_spent_seconds: Mapped[int | None] = mapped_column(Integer, nullable=True)
    score: Mapped[int | None] = mapped_column(Integer, nullable=True)
    max_score: Mapped[int] = mapped_column(Integer, nullable=False)
    score_pct: Mapped[Decimal | None] = mapped_column(Numeric(5, 2), nullable=True)
    passed: Mapped[bool | None] = mapped_column(Boolean, nullable=True)


class StudentQuizAnswer(Base):
    __tablename__ = "student_quiz_answer"
    __table_args__ = (
        UniqueConstraint("attempt_id", "question_id", name="uq_student_quiz_answer_attempt_question"),
    )

    id: Mapped[str] = mapped_column(UUID(as_uuid=False), primary_key=True, server_default=text("uuid_generate_v4()"))
    attempt_id: Mapped[str] = mapped_column(
        UUID(as_uuid=False),
        ForeignKey("student_quiz_attempt.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    question_id: Mapped[str] = mapped_column(UUID(as_uuid=False), nullable=False)
    selected_option_ids: Mapped[list[str]] = mapped_column(JSONB, nullable=False, default=list)
    is_correct: Mapped[bool | None] = mapped_column(Boolean, nullable=True)
    points_earned: Mapped[int | None] = mapped_column(Integer, nullable=True)
    answered_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )



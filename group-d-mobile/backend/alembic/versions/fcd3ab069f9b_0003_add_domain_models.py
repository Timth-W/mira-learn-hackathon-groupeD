"""0003_add_group_d_student_tables

Revision ID: fcd3ab069f9b
Revises: 0002d
Create Date: 2026-05-12 16:50:17.982240
"""
from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = 'fcd3ab069f9b'
down_revision: str | Sequence[str] | None = '0002d'
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        'student_note',
        sa.Column('id', postgresql.UUID(as_uuid=False), server_default=sa.text('uuid_generate_v4()'), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=False), nullable=False),
        sa.Column('class_id', postgresql.UUID(as_uuid=False), nullable=False),
        sa.Column('session_id', postgresql.UUID(as_uuid=False), nullable=True),
        sa.Column('module_id', postgresql.UUID(as_uuid=False), nullable=True),
        sa.Column('content', sa.Text(), server_default=sa.text("''::text"), nullable=False),
        sa.Column('tags', postgresql.JSONB(astext_type=sa.Text()), server_default=sa.text("'[]'::jsonb"), nullable=False),
        sa.Column('replay_timecode_seconds', sa.Integer(), nullable=True),
        sa.Column('is_favorite', sa.Boolean(), server_default=sa.text('false'), nullable=False),
        sa.Column('color', sa.String(length=16), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('deleted_at', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('id'),
    )
    op.create_index(
        'idx_student_note_user_class',
        'student_note',
        ['user_id', 'class_id'],
        unique=False,
        postgresql_where=sa.text('deleted_at IS NULL'),
    )
    op.create_index(
        'idx_student_note_module_id',
        'student_note',
        ['module_id'],
        unique=False,
        postgresql_where=sa.text('module_id IS NOT NULL'),
    )
    op.create_index(
        'idx_student_note_tags',
        'student_note',
        ['tags'],
        unique=False,
        postgresql_using='gin',
    )
    op.create_index(
        'idx_student_note_created',
        'student_note',
        ['user_id', 'created_at'],
        unique=False,
    )

    op.create_table(
        'student_note_organization',
        sa.Column('id', postgresql.UUID(as_uuid=False), server_default=sa.text('uuid_generate_v4()'), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=False), nullable=False),
        sa.Column('class_id', postgresql.UUID(as_uuid=False), nullable=False),
        sa.Column('scope_module_id', postgresql.UUID(as_uuid=False), nullable=True),
        sa.Column('note_ids_organized', postgresql.JSONB(astext_type=sa.Text()), server_default=sa.text("'[]'::jsonb"), nullable=False),
        sa.Column('summary', sa.Text(), nullable=False),
        sa.Column('concepts', postgresql.JSONB(astext_type=sa.Text()), server_default=sa.text("'[]'::jsonb"), nullable=False),
        sa.Column('key_takeaways', postgresql.JSONB(astext_type=sa.Text()), server_default=sa.text("'[]'::jsonb"), nullable=False),
        sa.Column('generated_by_llm', sa.Boolean(), server_default=sa.text('true'), nullable=False),
        sa.Column('llm_model_used', sa.String(length=64), nullable=False),
        sa.Column('llm_tokens_consumed', sa.Integer(), nullable=True),
        sa.Column('generation_latency_ms', sa.Integer(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.PrimaryKeyConstraint('id'),
    )
    op.create_index(
        'idx_student_note_organization_user_class',
        'student_note_organization',
        ['user_id', 'class_id', 'created_at'],
        unique=False,
    )

    op.create_table(
        'student_quiz_attempt',
        sa.Column('id', postgresql.UUID(as_uuid=False), server_default=sa.text('uuid_generate_v4()'), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=False), nullable=False),
        sa.Column('quiz_id', postgresql.UUID(as_uuid=False), nullable=False),
        sa.Column('module_id', postgresql.UUID(as_uuid=False), nullable=False),
        sa.Column('class_id', postgresql.UUID(as_uuid=False), nullable=False),
        sa.Column('attempt_number', sa.Integer(), nullable=False),
        sa.Column('status', sa.String(length=16), server_default=sa.text("'started'::character varying"), nullable=False),
        sa.Column('started_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('submitted_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('expired_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('time_spent_seconds', sa.Integer(), nullable=True),
        sa.Column('score', sa.Integer(), nullable=True),
        sa.Column('max_score', sa.Integer(), nullable=False),
        sa.Column('score_pct', sa.Numeric(precision=5, scale=2), nullable=True),
        sa.Column('passed', sa.Boolean(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.CheckConstraint("status IN ('started', 'submitted', 'expired', 'abandoned')", name='student_quiz_attempt_status_check'),
        sa.CheckConstraint('score_pct IS NULL OR score_pct BETWEEN 0 AND 100', name='student_quiz_attempt_score_pct_check'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('user_id', 'quiz_id', 'attempt_number', name='uq_student_quiz_attempt_user_quiz_num'),
    )
    op.create_index('idx_student_quiz_attempt_user_quiz', 'student_quiz_attempt', ['user_id', 'quiz_id'], unique=False)
    op.create_index('idx_student_quiz_attempt_class', 'student_quiz_attempt', ['user_id', 'class_id'], unique=False)
    op.create_index('idx_student_quiz_attempt_status', 'student_quiz_attempt', ['status'], unique=False)

    op.create_table(
        'student_quiz_answer',
        sa.Column('id', postgresql.UUID(as_uuid=False), server_default=sa.text('uuid_generate_v4()'), nullable=False),
        sa.Column('attempt_id', postgresql.UUID(as_uuid=False), nullable=False),
        sa.Column('question_id', postgresql.UUID(as_uuid=False), nullable=False),
        sa.Column('selected_option_ids', postgresql.JSONB(astext_type=sa.Text()), server_default=sa.text("'[]'::jsonb"), nullable=False),
        sa.Column('is_correct', sa.Boolean(), nullable=True),
        sa.Column('points_earned', sa.Integer(), nullable=True),
        sa.Column('answered_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.ForeignKeyConstraint(['attempt_id'], ['student_quiz_attempt.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('attempt_id', 'question_id', name='uq_student_quiz_answer_attempt_question'),
    )
    op.create_index('idx_student_quiz_answer_attempt_id', 'student_quiz_answer', ['attempt_id'], unique=False)


def downgrade() -> None:
    op.drop_index('idx_student_quiz_answer_attempt_id', table_name='student_quiz_answer')
    op.drop_table('student_quiz_answer')

    op.drop_index('idx_student_quiz_attempt_status', table_name='student_quiz_attempt')
    op.drop_index('idx_student_quiz_attempt_class', table_name='student_quiz_attempt')
    op.drop_index('idx_student_quiz_attempt_user_quiz', table_name='student_quiz_attempt')
    op.drop_table('student_quiz_attempt')

    op.drop_index('idx_student_note_organization_user_class', table_name='student_note_organization')
    op.drop_table('student_note_organization')

    op.drop_index('idx_student_note_created', table_name='student_note')
    op.drop_index('idx_student_note_tags', table_name='student_note')
    op.drop_index('idx_student_note_module_id', table_name='student_note')
    op.drop_index('idx_student_note_user_class', table_name='student_note')
    op.drop_table('student_note')

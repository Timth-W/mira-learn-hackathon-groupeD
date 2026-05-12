"""0004_seed_demo_content

Revision ID: 61d3eca2a09c
Revises: fcd3ab069f9b
Create Date: 2026-05-12 16:54:21.266859
"""
from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op


revision: str = '61d3eca2a09c'
down_revision: str | Sequence[str] | None = 'fcd3ab069f9b'
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    # ID d'Anna Lopez : 33e25231-0fb2-4c35-82f4-2169dc769d4d
    # IDs fixes pour seed de demo
    anna_user_id = "33e25231-0fb2-4c35-82f4-2169dc769d4d"
    class_id = "11111111-2222-3333-4444-555555555001"
    session_id = "11111111-2222-3333-4444-555555555002"
    module_id = "11111111-2222-3333-4444-555555555003"
    quiz_id = "11111111-2222-3333-4444-555555555004"
    question_id = "11111111-2222-3333-4444-555555555005"
    option_a = "11111111-2222-3333-4444-555555555006"
    option_b = "11111111-2222-3333-4444-555555555007"
    note_1 = "11111111-2222-3333-4444-555555555101"
    note_2 = "11111111-2222-3333-4444-555555555102"
    note_3 = "11111111-2222-3333-4444-555555555103"
    org_id = "11111111-2222-3333-4444-555555555201"
    attempt_id = "11111111-2222-3333-4444-555555555301"
    answer_id = "11111111-2222-3333-4444-555555555401"

    op.execute(
        sa.text(
            """
            INSERT INTO student_note (id, user_id, class_id, session_id, module_id, content, tags, is_favorite, color, created_at, updated_at)
            VALUES
            (:note_1, :user_id, :class_id, :session_id, :module_id, :content_1, '["pitch","investor"]'::jsonb, true, 'yellow', NOW(), NOW()),
            (:note_2, :user_id, :class_id, :session_id, :module_id, :content_2, '["pitch"]'::jsonb, false, 'blue', NOW(), NOW()),
            (:note_3, :user_id, :class_id, :session_id, :module_id, :content_3, '["storytelling"]'::jsonb, false, NULL, NOW(), NOW())
            """
        ),
        {
            "note_1": note_1,
            "note_2": note_2,
            "note_3": note_3,
            "user_id": anna_user_id,
            "class_id": class_id,
            "session_id": session_id,
            "module_id": module_id,
            "content_1": "Mon pitch doit expliquer le probleme client en 30 secondes.",
            "content_2": "Toujours finir avec la traction et la roadmap de financement.",
            "content_3": "Structure de narration: Hook, Probleme, Solution, Ask.",
        },
    )

    op.execute(
        sa.text(
            """
            INSERT INTO student_note_organization (
                id, user_id, class_id, scope_module_id, note_ids_organized, summary, concepts,
                key_takeaways, generated_by_llm, llm_model_used, llm_tokens_consumed, generation_latency_ms, created_at
            )
            VALUES (
                :org_id, :user_id, :class_id, :module_id,
                :note_ids::jsonb,
                :summary,
                :concepts::jsonb,
                :takeaways::jsonb,
                true,
                'anthropic/claude-3.5-haiku',
                280,
                450,
                NOW()
            )
            """
        ),
        {
            "org_id": org_id,
            "user_id": anna_user_id,
            "class_id": class_id,
            "module_id": module_id,
            "note_ids": f'["{note_1}","{note_2}","{note_3}"]',
            "summary": "Les notes convergent vers une trame de pitch: probleme, traction, puis demande claire.",
            "concepts": (
                '[{"concept_name":"pitch","description":"Construire un pitch clair et actionnable",'
                '"related_note_ids":["' + note_1 + '","' + note_2 + '"],'
                '"key_points":["Probleme client en 30s","Finir par traction + roadmap"]}]'
            ),
            "takeaways": '["Clarifier le probleme client", "Prouver la traction", "Conclure avec un ask précis"]',
        },
    )

    op.execute(
        sa.text(
            """
            INSERT INTO student_quiz_attempt (
                id, user_id, quiz_id, module_id, class_id, attempt_number, status,
                started_at, submitted_at, time_spent_seconds, score, max_score, score_pct, passed, created_at, updated_at
            )
            VALUES (
                :attempt_id, :user_id, :quiz_id, :module_id, :class_id, 1, 'submitted',
                NOW() - INTERVAL '10 minutes', NOW() - INTERVAL '5 minutes', 300,
                4, 5, 80.00, true, NOW(), NOW()
            )
            """
        ),
        {
            "attempt_id": attempt_id,
            "user_id": anna_user_id,
            "quiz_id": quiz_id,
            "module_id": module_id,
            "class_id": class_id,
        },
    )

    op.execute(
        sa.text(
            """
            INSERT INTO student_quiz_answer (
                id, attempt_id, question_id, selected_option_ids, is_correct, points_earned, answered_at, updated_at
            )
            VALUES (
                :answer_id, :attempt_id, :question_id,
                :selected_options::jsonb,
                true,
                1,
                NOW() - INTERVAL '7 minutes',
                NOW() - INTERVAL '7 minutes'
            )
            """
        ),
        {
            "answer_id": answer_id,
            "attempt_id": attempt_id,
            "question_id": question_id,
            "selected_options": f'["{option_a}","{option_b}"]',
        },
    )

def downgrade() -> None:
    op.execute("DELETE FROM student_quiz_answer WHERE id = '11111111-2222-3333-4444-555555555401';")
    op.execute("DELETE FROM student_quiz_attempt WHERE id = '11111111-2222-3333-4444-555555555301';")
    op.execute("DELETE FROM student_note_organization WHERE id = '11111111-2222-3333-4444-555555555201';")
    op.execute("DELETE FROM student_note WHERE id IN ('11111111-2222-3333-4444-555555555101','11111111-2222-3333-4444-555555555102','11111111-2222-3333-4444-555555555103');")

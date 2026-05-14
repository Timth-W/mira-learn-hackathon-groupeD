"""0005_enrich_anna_demo_data

Ajoute des notes variées sur 2 classes supplémentaires pour Anna Lopez
afin de rendre la démo mobile plus réaliste.

Revision ID: a1b2c3d4e5f6
Revises: 61d3eca2a09c
Create Date: 2026-05-13 00:00:00.000000
"""
from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "a1b2c3d4e5f6"
down_revision: str | Sequence[str] | None = "61d3eca2a09c"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    anna = "33e25231-0fb2-4c35-82f4-2169dc769d4d"

    # ── Classe 2 : Marketing Digital ──────────────────────────────────────
    class_2       = "22222222-aaaa-bbbb-cccc-000000000001"
    session_2     = "22222222-aaaa-bbbb-cccc-000000000002"
    module_2a     = "22222222-aaaa-bbbb-cccc-000000000011"
    module_2b     = "22222222-aaaa-bbbb-cccc-000000000012"

    note_2_01 = "22222222-aaaa-bbbb-cccc-100000000001"
    note_2_02 = "22222222-aaaa-bbbb-cccc-100000000002"
    note_2_03 = "22222222-aaaa-bbbb-cccc-100000000003"
    note_2_04 = "22222222-aaaa-bbbb-cccc-100000000004"

    # ── Classe 3 : Leadership & Management ────────────────────────────────
    class_3       = "33333333-aaaa-bbbb-cccc-000000000001"
    session_3     = "33333333-aaaa-bbbb-cccc-000000000002"
    module_3a     = "33333333-aaaa-bbbb-cccc-000000000011"

    note_3_01 = "33333333-aaaa-bbbb-cccc-100000000001"
    note_3_02 = "33333333-aaaa-bbbb-cccc-100000000002"
    note_3_03 = "33333333-aaaa-bbbb-cccc-100000000003"

    conn = op.get_bind()

    conn.execute(
        sa.text(
            """
            INSERT INTO student_note
                (id, user_id, class_id, session_id, module_id, content, tags, is_favorite, color, created_at, updated_at)
            VALUES
            -- Classe 2 – module 2a : SEO & contenu
            (:n201, :u, :c2, :s2, :m2a, :t201, '["seo","contenu"]'::jsonb,  false, 'green',  NOW() - INTERVAL '3 days',  NOW() - INTERVAL '3 days'),
            (:n202, :u, :c2, :s2, :m2a, :t202, '["seo"]'::jsonb,           true,  'green',  NOW() - INTERVAL '2 days',  NOW() - INTERVAL '2 days'),
            -- Classe 2 – module 2b : réseaux sociaux
            (:n203, :u, :c2, :s2, :m2b, :t203, '["social","growth"]'::jsonb, false, 'blue',  NOW() - INTERVAL '1 day',   NOW() - INTERVAL '1 day'),
            (:n204, :u, :c2, :s2, :m2b, :t204, '["growth"]'::jsonb,         false, NULL,     NOW() - INTERVAL '12 hours', NOW() - INTERVAL '12 hours'),
            -- Classe 3 – module 3a : leadership
            (:n301, :u, :c3, :s3, :m3a, :t301, '["leadership","feedback"]'::jsonb, true,  'yellow', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'),
            (:n302, :u, :c3, :s3, :m3a, :t302, '["leadership"]'::jsonb,            false, NULL,     NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days'),
            (:n303, :u, :c3, :s3, :m3a, :t303, '["feedback","communication"]'::jsonb, false, 'blue', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days')
            """
        ),
        {
            "u": anna,
            # classe 2
            "c2": class_2, "s2": session_2,
            "m2a": module_2a, "m2b": module_2b,
            "n201": note_2_01,
            "t201": "Le SEO on-page passe par la densité de mots-clés ET la structure H1/H2/H3.",
            "n202": note_2_02,
            "t202": "Les backlinks de qualité > volume. 5 liens d'autorité battent 50 liens génériques.",
            "n203": note_2_03,
            "t203": "Sur Instagram : publier en stories tous les jours, en feed 3x/semaine minimum.",
            "n204": note_2_04,
            "t204": "Le growth hacking : tester vite, couper ce qui ne convertit pas, doubler la mise sur ce qui marche.",
            # classe 3
            "c3": class_3, "s3": session_3, "m3a": module_3a,
            "n301": note_3_01,
            "t301": "Un bon manager donne du feedback dans les 24h — pas dans une réunion mensuelle.",
            "n302": note_3_02,
            "t302": "Différence manager vs leader : le manager optimise le présent, le leader construit le futur.",
            "n303": note_3_03,
            "t303": "Communication non-violente : Observation → Sentiment → Besoin → Demande.",
        },
    )


def downgrade() -> None:
    conn = op.get_bind()
    conn.execute(
        sa.text(
            """
            DELETE FROM student_note
            WHERE user_id = '33e25231-0fb2-4c35-82f4-2169dc769d4d'
              AND class_id IN (
                '22222222-aaaa-bbbb-cccc-000000000001',
                '33333333-aaaa-bbbb-cccc-000000000001'
              )
            """
        )
    )

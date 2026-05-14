"""0006_seed_community_feed

Revision ID: 9f2b7c4d8a10
Revises: a1b2c3d4e5f6
Create Date: 2026-05-14 20:45:00.000000
"""
from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "9f2b7c4d8a10"
down_revision: str | Sequence[str] | None = "a1b2c3d4e5f6"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column(
        "community_activity_feed",
        sa.Column("display_icon", sa.String(length=32), nullable=True),
    )
    op.create_index(
        "idx_community_feed_event_type",
        "community_activity_feed",
        ["event_type", "occurred_at"],
        unique=False,
    )

    conn = op.get_bind()
    conn.execute(
        sa.text(
            """
            INSERT INTO community_activity_feed
                (id, event_type, display_text, display_icon, context, occurred_at, created_at)
            VALUES
            (:id01, 'skill_validated', :t01, 'workspace_premium', '{"skill_name":"Pitch investor","city":"Portugal"}'::jsonb, NOW() - INTERVAL '12 minutes', NOW()),
            (:id02, 'enrolment_made', :t02, 'person_add', '{"class_title":"Pitch Investor","city":"Lisbonne","count":"3"}'::jsonb, NOW() - INTERVAL '28 minutes', NOW()),
            (:id03, 'class_started', :t03, 'travel_explore', '{"class_title":"Storytelling pour investisseurs","city":"Barcelone","country":"Espagne"}'::jsonb, NOW() - INTERVAL '43 minutes', NOW()),
            (:id04, 'skill_validated', :t04, 'workspace_premium', '{"skill_name":"Lean Canvas","city":"Bali"}'::jsonb, NOW() - INTERVAL '1 hour', NOW()),
            (:id05, 'mentor_validated', :t05, 'verified', '{"mentor_role":"Mira Mentor","category":"business"}'::jsonb, NOW() - INTERVAL '1 hour 30 minutes', NOW()),
            (:id06, 'class_published_soon', :t06, 'campaign', '{"class_title":"Remote Leadership","city":"Mexico City"}'::jsonb, NOW() - INTERVAL '2 hours', NOW()),
            (:id07, 'milestone_reached', :t07, 'flag', '{"milestone":"100_notes","city":"Lisbonne"}'::jsonb, NOW() - INTERVAL '2 hours 20 minutes', NOW()),
            (:id08, 'skill_validated', :t08, 'workspace_premium', '{"skill_name":"Public speaking","city":"Paris"}'::jsonb, NOW() - INTERVAL '3 hours', NOW()),
            (:id09, 'cohort_completed', :t09, 'groups', '{"class_title":"Funding Basics","city":"Berlin"}'::jsonb, NOW() - INTERVAL '3 hours 40 minutes', NOW()),
            (:id10, 'enrolment_made', :t10, 'person_add', '{"class_title":"UX Research","city":"Amsterdam","count":"5"}'::jsonb, NOW() - INTERVAL '4 hours', NOW()),
            (:id11, 'skill_validated', :t11, 'workspace_premium', '{"skill_name":"Funding strategy","city":"Lisbonne"}'::jsonb, NOW() - INTERVAL '5 hours', NOW()),
            (:id12, 'class_started', :t12, 'travel_explore', '{"class_title":"No-code landing pages","city":"Bali"}'::jsonb, NOW() - INTERVAL '6 hours', NOW()),
            (:id13, 'skill_validated', :t13, 'workspace_premium', '{"skill_name":"UI Design","city":"Valence"}'::jsonb, NOW() - INTERVAL '7 hours', NOW()),
            (:id14, 'mentor_validated', :t14, 'verified', '{"mentor_role":"Mira Mentor","category":"design"}'::jsonb, NOW() - INTERVAL '8 hours', NOW()),
            (:id15, 'enrolment_made', :t15, 'person_add', '{"class_title":"Solo founder finance","city":"Porto","count":"2"}'::jsonb, NOW() - INTERVAL '9 hours', NOW()),
            (:id16, 'skill_validated', :t16, 'workspace_premium', '{"skill_name":"Negotiation","city":"Madrid"}'::jsonb, NOW() - INTERVAL '10 hours', NOW()),
            (:id17, 'class_published_soon', :t17, 'campaign', '{"class_title":"Prompt engineering utile","city":"Lyon"}'::jsonb, NOW() - INTERVAL '11 hours', NOW()),
            (:id18, 'milestone_reached', :t18, 'flag', '{"milestone":"first_quiz","city":"Rome"}'::jsonb, NOW() - INTERVAL '12 hours', NOW()),
            (:id19, 'skill_validated', :t19, 'workspace_premium', '{"skill_name":"Growth hacking","city":"Lisbonne"}'::jsonb, NOW() - INTERVAL '14 hours', NOW()),
            (:id20, 'cohort_completed', :t20, 'groups', '{"class_title":"Pitch Investor","city":"Barcelone"}'::jsonb, NOW() - INTERVAL '16 hours', NOW()),
            (:id21, 'enrolment_made', :t21, 'person_add', '{"class_title":"Design systems","city":"Paris","count":"4"}'::jsonb, NOW() - INTERVAL '18 hours', NOW()),
            (:id22, 'skill_validated', :t22, 'workspace_premium', '{"skill_name":"Docker Kubernetes","city":"Tallinn"}'::jsonb, NOW() - INTERVAL '20 hours', NOW()),
            (:id23, 'class_started', :t23, 'travel_explore', '{"class_title":"Community building","city":"Lisbonne"}'::jsonb, NOW() - INTERVAL '22 hours', NOW()),
            (:id24, 'skill_validated', :t24, 'workspace_premium', '{"skill_name":"Storytelling","city":"Bali"}'::jsonb, NOW() - INTERVAL '1 day 1 hour', NOW()),
            (:id25, 'mentor_validated', :t25, 'verified', '{"mentor_role":"Mira Mentor","category":"soft"}'::jsonb, NOW() - INTERVAL '1 day 3 hours', NOW()),
            (:id26, 'enrolment_made', :t26, 'person_add', '{"class_title":"API design","city":"Berlin","count":"3"}'::jsonb, NOW() - INTERVAL '1 day 5 hours', NOW()),
            (:id27, 'skill_validated', :t27, 'workspace_premium', '{"skill_name":"Remote collaboration","city":"Porto"}'::jsonb, NOW() - INTERVAL '1 day 8 hours', NOW()),
            (:id28, 'class_published_soon', :t28, 'campaign', '{"class_title":"Personal finance nomade","city":"Lisbonne"}'::jsonb, NOW() - INTERVAL '1 day 12 hours', NOW()),
            (:id29, 'milestone_reached', :t29, 'flag', '{"milestone":"cohort_energy","city":"Barcelone"}'::jsonb, NOW() - INTERVAL '1 day 18 hours', NOW()),
            (:id30, 'skill_validated', :t30, 'workspace_premium', '{"skill_name":"Flutter mobile","city":"Athens"}'::jsonb, NOW() - INTERVAL '1 day 23 hours', NOW())
            """
        ),
        {
            "id01": "66666666-0000-0000-0000-000000000001",
            "id02": "66666666-0000-0000-0000-000000000002",
            "id03": "66666666-0000-0000-0000-000000000003",
            "id04": "66666666-0000-0000-0000-000000000004",
            "id05": "66666666-0000-0000-0000-000000000005",
            "id06": "66666666-0000-0000-0000-000000000006",
            "id07": "66666666-0000-0000-0000-000000000007",
            "id08": "66666666-0000-0000-0000-000000000008",
            "id09": "66666666-0000-0000-0000-000000000009",
            "id10": "66666666-0000-0000-0000-000000000010",
            "id11": "66666666-0000-0000-0000-000000000011",
            "id12": "66666666-0000-0000-0000-000000000012",
            "id13": "66666666-0000-0000-0000-000000000013",
            "id14": "66666666-0000-0000-0000-000000000014",
            "id15": "66666666-0000-0000-0000-000000000015",
            "id16": "66666666-0000-0000-0000-000000000016",
            "id17": "66666666-0000-0000-0000-000000000017",
            "id18": "66666666-0000-0000-0000-000000000018",
            "id19": "66666666-0000-0000-0000-000000000019",
            "id20": "66666666-0000-0000-0000-000000000020",
            "id21": "66666666-0000-0000-0000-000000000021",
            "id22": "66666666-0000-0000-0000-000000000022",
            "id23": "66666666-0000-0000-0000-000000000023",
            "id24": "66666666-0000-0000-0000-000000000024",
            "id25": "66666666-0000-0000-0000-000000000025",
            "id26": "66666666-0000-0000-0000-000000000026",
            "id27": "66666666-0000-0000-0000-000000000027",
            "id28": "66666666-0000-0000-0000-000000000028",
            "id29": "66666666-0000-0000-0000-000000000029",
            "id30": "66666666-0000-0000-0000-000000000030",
            "t01": "Une nomade vient de valider Pitch investor - Portugal",
            "t02": "3 nouvelles inscriptions sur Pitch Investor - Lisbonne",
            "t03": "Une Mira Class vient de demarrer - Barcelone",
            "t04": "Une nomade vient de valider Lean Canvas - Bali",
            "t05": "Un nouveau Mira Mentor business a ete valide",
            "t06": "Remote Leadership ouvre bientot une cohorte - Mexico City",
            "t07": "La communaute vient de depasser 100 notes prises cette semaine",
            "t08": "Une nomade vient de valider Public speaking - Paris",
            "t09": "Une cohorte Funding Basics vient de terminer - Berlin",
            "t10": "5 nomades rejoignent UX Research - Amsterdam",
            "t11": "Une nomade vient de valider Funding strategy - Lisbonne",
            "t12": "Une session No-code landing pages demarre - Bali",
            "t13": "Une nomade vient de valider UI Design - Valence",
            "t14": "Un nouveau Mira Mentor design rejoint la plateforme",
            "t15": "2 nouvelles inscriptions sur Solo founder finance - Porto",
            "t16": "Une nomade vient de valider Negotiation - Madrid",
            "t17": "Prompt engineering utile arrive bientot - Lyon",
            "t18": "Une premiere tentative QCM vient d'etre terminee - Rome",
            "t19": "Une nomade vient de valider Growth hacking - Lisbonne",
            "t20": "Une cohorte Pitch Investor vient de finir - Barcelone",
            "t21": "4 nomades rejoignent Design systems - Paris",
            "t22": "Une nomade vient de valider Docker Kubernetes - Tallinn",
            "t23": "Community building lance une session - Lisbonne",
            "t24": "Une nomade vient de valider Storytelling - Bali",
            "t25": "Un Mira Mentor soft skills vient d'etre valide",
            "t26": "3 nouvelles inscriptions sur API design - Berlin",
            "t27": "Une nomade vient de valider Remote collaboration - Porto",
            "t28": "Personal finance nomade ouvre bientot - Lisbonne",
            "t29": "Une cohorte a franchi son premier rituel collectif - Barcelone",
            "t30": "Une nomade vient de valider Flutter mobile - Athens",
        },
    )


def downgrade() -> None:
    op.execute("DELETE FROM community_activity_feed WHERE id::text LIKE '66666666-0000-0000-0000-0000000000%';")
    op.drop_index("idx_community_feed_event_type", table_name="community_activity_feed")
    op.drop_column("community_activity_feed", "display_icon")

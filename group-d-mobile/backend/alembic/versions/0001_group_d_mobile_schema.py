"""0001 — group-d-mobile schema (auto-généré depuis contracts/)

Revision ID: 0001d
Revises: None
Create Date: 2026-05-11
"""
from alembic import op

revision = "0001d"
down_revision = None
branch_labels = None
depends_on = None

SCHEMA_SQL = r"""
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE skill (
    id UUID NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    slug VARCHAR(64) NOT NULL UNIQUE,
    name VARCHAR(120) NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    category VARCHAR(32) NOT NULL CHECK (category IN ('business', 'design', 'tech', 'soft', 'lifestyle')),
    popularity_score INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE NULL
);

CREATE TABLE mentor_profile (
    id UUID NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE,
    slug VARCHAR(120) NOT NULL UNIQUE,
    display_name VARCHAR(120) NOT NULL,
    headline VARCHAR(255) NOT NULL DEFAULT '',
    bio TEXT NOT NULL DEFAULT '',
    avatar_url VARCHAR(500) NULL,
    professional_journey JSONB NOT NULL DEFAULT '[]'::jsonb,
    status VARCHAR(16) NOT NULL DEFAULT 'active',
    aggregate_rating NUMERIC(3, 2) NULL,
    rating_count INTEGER NOT NULL DEFAULT 0,
    classes_given_count INTEGER NOT NULL DEFAULT 0,
    validated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE NULL
);

CREATE TABLE mira_class (
    id UUID NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    application_id UUID NULL,
    mentor_user_id UUID NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    skills_taught JSONB NOT NULL DEFAULT '[]'::jsonb,
    total_hours INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    ai_assisted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE NULL
);

CREATE TABLE student_profile (
    id UUID NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE,
    display_name VARCHAR(120) NOT NULL,
    avatar_url VARCHAR(500) NULL,
    target_skills JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE NULL
);

CREATE TABLE community_activity_feed (
    id UUID NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    event_type VARCHAR(64) NOT NULL,
    display_text TEXT NOT NULL,
    context JSONB NOT NULL DEFAULT '{}'::jsonb,
    occurred_at TIMESTAMP WITH TIME ZONE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- ICI LA CORRECTION DE L'INDEX (Pas de NOW)
CREATE INDEX idx_community_feed_occ ON community_activity_feed (occurred_at DESC) WHERE expires_at IS NULL;
"""

def _split_statements(sql: str) -> list[str]:
    return [p.strip() for p in sql.split(';') if p.strip()]

def upgrade() -> None:
    for stmt in _split_statements(SCHEMA_SQL):
        op.execute(stmt)

def downgrade() -> None:
    op.execute('DROP TABLE IF EXISTS community_activity_feed CASCADE;')
    op.execute('DROP TABLE IF EXISTS student_profile CASCADE;')
    op.execute('DROP TABLE IF EXISTS mira_class CASCADE;')
    op.execute('DROP TABLE IF EXISTS mentor_profile CASCADE;')
    op.execute('DROP TABLE IF EXISTS skill CASCADE;')
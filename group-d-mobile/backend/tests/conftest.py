"""
pytest fixtures globales.

MIGRATION HINT (post-hackathon) :
    Remplacé par `ms-common-api.testing` qui propose des fixtures pré-câblées
    (test_db, async_client, mock_auth, mock_nats, etc.).
"""
import asyncio
import os
from collections.abc import AsyncGenerator

import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient

# Defaults for local test collection. Real deployments still validate their
# actual environment through app.core.config.Settings.
os.environ.setdefault(
    "DATABASE_URL",
    "postgresql+asyncpg://postgres:postgres@localhost:5432/mira_learn_test",
)
os.environ.setdefault("SUPABASE_URL", "https://example.supabase.co")
os.environ.setdefault("SUPABASE_ANON_KEY", "test-anon-key")
os.environ.setdefault("OPENROUTER_API_KEY", "test-openrouter-key")
os.environ.pop("SSLKEYLOGFILE", None)

from app.core.db import AsyncSessionLocal
from main import app


@pytest.fixture(scope="session")
def event_loop():
    """Force a single event loop for the whole test session."""
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


@pytest_asyncio.fixture
async def client() -> AsyncGenerator[AsyncClient, None]:
    """HTTP test client async."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        yield ac


@pytest_asyncio.fixture
async def db():
    """Session DB pour tests directs (sans HTTP)."""
    async with AsyncSessionLocal() as session:
        yield session
        await session.rollback()


@pytest.fixture
def mock_auth_headers() -> dict[str, str]:
    """Headers d'auth mockés pour tests (JWT factice).

    MIGRATION HINT : en V1 prod, les tests passent par edge-gateway test ou
    injectent directement X-User-Id / X-Computed-Scopes headers.
    """
    # JWT factice — l'auth mock côté tests bypass la validation JWKS
    return {"Authorization": "Bearer FAKE_TEST_TOKEN"}

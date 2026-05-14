import pytest
from fastapi import HTTPException, status
from httpx import AsyncClient

from app.core.auth import AuthenticatedUser, require_auth
from main import app


async def _reject_auth() -> AuthenticatedUser:
    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)


async def _mentor_auth() -> AuthenticatedUser:
    return AuthenticatedUser(
        user_id="33e25231-0fb2-4c35-82f4-2169dc769d4d",
        email="mentor@hackathon.test",
        role="mentor",
    )


@pytest.mark.asyncio
async def test_health(client: AsyncClient) -> None:
    response = await client.get("/v1/health")
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "success"
    assert body["data"]["status"] == "ok"


@pytest.mark.asyncio
async def test_version(client: AsyncClient) -> None:
    response = await client.get("/v1/version")
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "success"
    assert "service" in body["data"]
    assert "build_sha" in body["data"]


@pytest.mark.asyncio
async def test_list_examples_requires_auth(client: AsyncClient) -> None:
    app.dependency_overrides[require_auth] = _reject_auth
    try:
        response = await client.get("/v1/examples")
        assert response.status_code == 401
    finally:
        app.dependency_overrides.pop(require_auth, None)


@pytest.mark.asyncio
async def test_create_example_validation(
    client: AsyncClient,
    mock_auth_headers: dict[str, str],
) -> None:
    app.dependency_overrides[require_auth] = _mentor_auth
    try:
        response = await client.post(
            "/v1/examples",
            json={"title": "Demo", "status": "invalid"},
            headers=mock_auth_headers,
        )
        assert response.status_code == 422
    finally:
        app.dependency_overrides.pop(require_auth, None)

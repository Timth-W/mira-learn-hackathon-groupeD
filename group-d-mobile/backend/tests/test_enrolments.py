import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_list_my_enrolments_requires_auth(client: AsyncClient) -> None:
    response = await client.get("/v1/me/enrolments")
    assert response.status_code == 422

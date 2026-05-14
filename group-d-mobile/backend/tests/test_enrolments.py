import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_list_my_enrolments_returns_demo_user_data(client: AsyncClient) -> None:
    response = await client.get("/v1/me/enrolments")
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "success"
    assert isinstance(body["data"], list)

"""
Routes apprenant pour les enrolments.

Le mobile Groupe D consomme `GET /v1/me/enrolments` pour l'onglet Programmes.
"""

from fastapi import APIRouter, Depends

from app.core.auth import AuthenticatedUser, require_auth
from app.core.responses import success_response
from app.services import enrolment_service

router = APIRouter()


@router.get("/me/enrolments", summary="Lister mes inscriptions")
async def list_my_enrolments(
    user: AuthenticatedUser = Depends(require_auth),
) -> dict:
    """Retourne les inscriptions de l'apprenant courant."""
    items = enrolment_service.list_my_enrolments(user)
    return success_response(data=items)


@router.get("/me/enrolments/{class_id}", summary="Recuperer le detail d'une inscription")
async def get_my_enrolment_detail(
    class_id: str,
    user: AuthenticatedUser = Depends(require_auth),
) -> dict:
    """Retourne le detail d'une class et ses modules."""
    item = enrolment_service.get_my_enrolment_detail(user, class_id)
    return success_response(data=item)

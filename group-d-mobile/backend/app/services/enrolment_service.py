"""
Service applicatif pour les inscriptions de l'apprenant.

Hackathon scope:
    - Fournit une liste stable d'enrolments pour alimenter l'onglet Programmes
    - Fournit un detail de class avec modules pour le parcours mobile
    - Pas de DB pour l'instant: on retourne des donnees seed/mock coherentes
    - Le remplacement par une vraie source PostgreSQL/Supabase se fera sans
      changer le contrat HTTP mobile
"""

from app.core.auth import AuthenticatedUser
from app.core.exceptions import NotFoundError


_ENROLMENTS = [
    {
        "key": "pitch-investor",
        "class_id": "11111111-2222-3333-4444-555555555001",
        "status": "accepted",
        "enrolled_at": "2026-05-12T10:00:00Z",
        "class_title": "Pitch Investor",
        "mentor_display_name": "Antoine Mira",
        "location_city": "Barcelone",
        "module_count": 3,
        "next_module_title": "Storytelling pour investisseurs",
        "starts_at": "2026-07-05T09:00:00Z",
        "ends_at": "2026-07-26T18:00:00Z",
        "progress_pct": 68,
        "description": (
            "Apprends a pitcher ton projet avec clarte, narration et confiance "
            "pour convaincre mentors et investisseurs."
        ),
        "modules": [
            {
                "id": "11111111-2222-3333-4444-555555555003",
                "title": "Storytelling pour investisseurs",
                "duration_label": "1h 30",
                "progress_pct": 100,
                "status": "completed",
                "description": "Structurer un pitch clair, memorisable et oriente traction.",
                "materials": ["Video replay", "Template de pitch", "Checklist demo day"],
                "quiz_id": "11111111-2222-3333-4444-555555559001",
            },
            {
                "id": "11111111-2222-3333-4444-555555555004",
                "title": "Objections et FAQ",
                "duration_label": "1h 05",
                "progress_pct": 70,
                "status": "in_progress",
                "description": "Repondre aux objections sans perdre le fil de ta narration.",
                "materials": ["PDF objections frequentes", "Exercices de roleplay"],
                "quiz_id": "11111111-2222-3333-4444-555555559002",
            },
            {
                "id": "11111111-2222-3333-4444-555555555005",
                "title": "Demo day rehearsal",
                "duration_label": "45 min",
                "progress_pct": 0,
                "status": "locked",
                "description": "Simulation finale avant presentation publique.",
                "materials": ["Brief mentor", "Grille d evaluation"],
                "quiz_id": "11111111-2222-3333-4444-555555559003",
            },
        ],
    },
    {
        "key": "funding-basics",
        "class_id": "22222222-aaaa-bbbb-cccc-000000000001",
        "status": "waitlist",
        "enrolled_at": "2026-05-18T10:00:00Z",
        "class_title": "Funding Basics for Nomads",
        "mentor_display_name": "Lea Simon",
        "location_city": "Lisbonne",
        "module_count": 2,
        "next_module_title": "SEO & contenu pour acquisition",
        "starts_at": "2026-08-02T09:00:00Z",
        "ends_at": "2026-08-16T18:00:00Z",
        "progress_pct": 15,
        "description": (
            "Comprendre les fondamentaux du financement early-stage et les "
            "metriques qui rassurent les investisseurs."
        ),
        "modules": [
            {
                "id": "22222222-aaaa-bbbb-cccc-000000000011",
                "title": "SEO & contenu pour acquisition",
                "duration_label": "1h 20",
                "progress_pct": 35,
                "status": "available",
                "description": "Poser les bases d une strategie d acquisition organique durable.",
                "materials": ["Guide SEO", "Template calendrier editorial"],
                "quiz_id": "22222222-aaaa-bbbb-cccc-999999999011",
            },
            {
                "id": "22222222-aaaa-bbbb-cccc-000000000012",
                "title": "Growth loops & social media",
                "duration_label": "55 min",
                "progress_pct": 0,
                "status": "locked",
                "description": "Construire une boucle d acquisition repetable autour du contenu.",
                "materials": ["Cas d usage Instagram", "Worksheet KPI growth"],
                "quiz_id": "22222222-aaaa-bbbb-cccc-999999999012",
            },
        ],
    },
]


def _serialize_enrolment(user: AuthenticatedUser, item: dict) -> dict:
    return {
        "enrolment_id": f"{user.user_id}-{item['key']}",
        "status": item["status"],
        "enrolled_at": item["enrolled_at"],
        "class_id": item["class_id"],
        "class_title": item["class_title"],
        "mentor_display_name": item["mentor_display_name"],
        "location_city": item["location_city"],
        "module_count": item["module_count"],
        "next_module_title": item["next_module_title"],
        "starts_at": item["starts_at"],
        "ends_at": item["ends_at"],
        "progress_pct": item["progress_pct"],
    }


def list_my_enrolments(user: AuthenticatedUser) -> list[dict]:
    """Retourne les inscriptions visibles pour l'utilisateur courant."""
    return [_serialize_enrolment(user, item) for item in _ENROLMENTS]


def get_my_enrolment_detail(user: AuthenticatedUser, class_id: str) -> dict:
    """Retourne le detail d'une class et ses modules pour l'utilisateur courant."""
    match = next((item for item in _ENROLMENTS if item["class_id"] == class_id), None)
    if match is None:
        raise NotFoundError("Enrolment", class_id)

    detail = _serialize_enrolment(user, match)
    detail["description"] = match["description"]
    detail["modules"] = match["modules"]
    return detail

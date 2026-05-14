"""
Service applicatif pour les inscriptions de l'apprenant.

Hackathon scope:
    - Fournit une liste stable d'enrolments pour alimenter l'onglet Programmes
    - Pas de DB pour l'instant: on retourne des donnees seed/mock coherentes
    - Le remplacement par une vraie source PostgreSQL/Supabase se fera sans
      changer le contrat HTTP mobile
"""

from app.core.auth import AuthenticatedUser


def list_my_enrolments(user: AuthenticatedUser) -> list[dict]:
    """Retourne les inscriptions visibles pour l'utilisateur courant."""
    return [
        {
            "enrolment_id": f"{user.user_id}-pitch-investor",
            "status": "accepted",
            "enrolled_at": "2026-05-12T10:00:00Z",
            "class_id": "class-pitch-investor",
            "class_title": "Pitch Investor",
            "mentor_display_name": "Antoine Mira",
            "location_city": "Barcelone",
            "module_count": 5,
            "next_module_title": "Storytelling pour investisseurs",
            "starts_at": "2026-07-05T09:00:00Z",
            "ends_at": "2026-07-26T18:00:00Z",
        },
        {
            "enrolment_id": f"{user.user_id}-funding-basics",
            "status": "waitlist",
            "enrolled_at": "2026-05-18T10:00:00Z",
            "class_id": "class-funding-basics",
            "class_title": "Funding Basics for Nomads",
            "mentor_display_name": "Lea Simon",
            "location_city": "Lisbonne",
            "module_count": 4,
            "next_module_title": "Pre-seed metrics",
            "starts_at": "2026-08-02T09:00:00Z",
            "ends_at": "2026-08-16T18:00:00Z",
        },
    ]

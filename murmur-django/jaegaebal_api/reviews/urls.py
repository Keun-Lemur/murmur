from django.urls import path
from .views import get_filtered_reviews, get_reviews

urlpatterns = [
    path("", get_reviews, name="get_reviews"),
    path(
        "<int:vet_id>/<str:vet_explanation_type>/",
        get_filtered_reviews,
        name="get_filtered_reviews",
    ),
]

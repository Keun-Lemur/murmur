from django.urls import path
from .views import get_vets, search_vets
from vets import views

urlpatterns = [
    path("", get_vets, name="get_reviews"),
    path(
        "<int:vet_id>/",
        views.get_one_vet,
        name="get_one_vet",
    ),
    path("search/", search_vets, name="search_vets"),
]

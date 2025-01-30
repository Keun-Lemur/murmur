from django.urls import path
from .views import get_vet_search

urlpatterns = [
    path("", get_vet_search, name="vet_search"),
]

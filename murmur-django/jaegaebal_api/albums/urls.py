from django.urls import path
from .views import get_albums

urlpatterns = [
    path("", get_albums, name="get_albums"),
]

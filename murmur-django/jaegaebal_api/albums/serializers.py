from rest_framework import serializers
from vets.serializers import VetsSerializer
from .models import Albums


class AlbumsSerializer(serializers.ModelSerializer):
    vet = VetsSerializer(many=True)

    class Meta:
        model = Albums
        fields = "__all__"  # 모든 필드 포함

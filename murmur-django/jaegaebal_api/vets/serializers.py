from rest_framework import serializers
from .models import Vets


class VetsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vets
        fields = "__all__"  # 모든 필드 포함

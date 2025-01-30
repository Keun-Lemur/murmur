from rest_framework import serializers
from vets.serializers import VetsSerializer
from .models import Reviews


class ReviewsSerializer(serializers.ModelSerializer):
    vet = VetsSerializer(read_only=True)

    class Meta:
        model = Reviews
        fields = "__all__"  # 모든 필드 포함

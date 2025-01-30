from rest_framework import serializers
from search.models import VetSearch


class VetSearchSerializer(serializers.ModelSerializer):
    class Meta:
        model = VetSearch
        fields = [
            "hospital_name",
            "vet_name",
            "main_medical_subjects",
            "one_line_review",
            "exam_result_explanation",
            "prognosis_explanation",
            "care_method_explanation",
        ]

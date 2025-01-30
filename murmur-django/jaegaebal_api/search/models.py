from django.db import models


class VetSearch(models.Model):
    # 기본 검색 필드들
    hospital_name = models.TextField(blank=False, null=False)
    vet_name = models.TextField(blank=False, null=False)
    main_medical_subjects = models.TextField(blank=False, null=False)
    one_line_review = models.TextField(blank=True, null=True)

    # 추가 검색 필드들 (진료 성향 설명)
    exam_result_explanation = models.TextField(blank=True, null=True)
    prognosis_explanation = models.TextField(blank=True, null=True)
    care_method_explanation = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"{self.vet_name} - {self.hospital_name}"

from django.db import models


class Vets(models.Model):
    TELE_CONSULTATION_CHOICES = [
        ("가능", "가능"),
        ("불가능", "불가능"),
        ("진료 후 가능", "진료 후 가능"),
    ]

    # 기본정보
    vet_image_url = models.URLField(max_length=500, blank=True, null=True)
    hospital_name = models.TextField(blank=False, null=False)
    vet_name = models.TextField(blank=False, null=False)
    vet_role = models.TextField(blank=False, null=False)
    main_medical_subjects = models.TextField(blank=False, null=False)
    one_line_review = models.TextField(blank=True, null=True)

    # 진료성향
    exam_result_explanation = models.TextField(blank=True, null=True)
    prognosis_explanation = models.TextField(blank=True, null=True)
    care_method_explanation = models.TextField(blank=True, null=True)
    heart_disease_diagnosis_metrics = models.CharField(
        max_length=250, blank=True, null=True
    )
    heart_disease_stage_medications = models.JSONField(
        blank=True,
        null=True,
    )
    prescription_possible = models.TextField(blank=True, null=True)

    # 수의사 정보
    education = models.TextField(blank=True, null=True)
    research_activities = models.TextField(blank=True, null=True)
    teaching_activities = models.TextField(blank=True, null=True)
    qualification = models.TextField(blank=True, null=True)

    # 병원정보
    initial_cost = models.JSONField(blank=True, null=True)
    initial_cost_more = models.JSONField(blank=True, null=True)
    hospital_address = models.TextField(blank=True, null=True)
    parking = models.CharField(max_length=100)
    office_hours = models.JSONField(blank=True, null=True)
    exam_time = models.TextField(blank=True, null=True)
    initial_reservation_wait_time = models.TextField(blank=True, null=True)
    tele_consultation = models.TextField(blank=True, null=True)
    radiologist = models.JSONField(blank=True, null=True)
    key_equipment = models.JSONField(blank=True, null=True)

    def __str__(self):
        return self.vet_name

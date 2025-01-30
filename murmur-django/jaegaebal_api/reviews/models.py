import random
from django.db import models
from vets.models import Vets


class Reviews(models.Model):
    VET_EXPLANATION_TYPE = [
        ("검사결과 및 처방", "검사결과 및 처방"),
        ("예후 및 기대수명", "예후 및 기대수명"),
        ("관리 및 케어방법", "관리 및 케어방법"),
    ]

    vet = models.ForeignKey(Vets, on_delete=models.CASCADE, related_name="reviews")
    vet_explanation_type = models.CharField(
        max_length=9,  # 가장 긴 문자열 '검사결과 및 처방'은 9자
        choices=VET_EXPLANATION_TYPE,
        blank=True,
        null=True,
    )

    written_date = models.CharField(max_length=100)
    content_summary = models.TextField(blank=True, null=True)
    content = models.TextField(blank=False, null=False)
    writer_info = models.CharField(max_length=100, default="***보호자")

    def save(self, *args, **kwargs):
        if not self.writer_info or self.writer_info == "***보호자":
            stars = "*" * random.randint(2, 7)
            self.writer_info = f"{stars}보호자"
        super().save(*args, **kwargs)

    def __str__(self):
        return f"Reviews for {self.vet.vet_name} by {self.writer_info} on {self.written_date}"

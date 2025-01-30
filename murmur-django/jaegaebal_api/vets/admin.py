from django.contrib import admin
from .models import Vets


class VetsAdmin(admin.ModelAdmin):
    list_display = ("vet_name", "hospital_name", "vet_role", "main_medical_subjects")

    search_fields = ("vet_name", "hospital_name")

    # 리뷰 인라인을 지연 임포트로 변경
    def get_reviews(self, obj):
        # 필요한 시점에 임포트 수행
        from reviews.models import Review

        return "\n".join([review.content for review in obj.reviews.all()])

    get_reviews.short_description = "Reviews"


admin.site.register(Vets, VetsAdmin)

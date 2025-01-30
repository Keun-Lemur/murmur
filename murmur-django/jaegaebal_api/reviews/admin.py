from django.contrib import admin
from .models import Reviews


class ReviewAdmin(admin.ModelAdmin):
    list_display = (
        "vet",
        "written_date",
        "content_summary",
        "writer_info",
    )  # 리뷰에서 보여줄 필드

    search_fields = (
        "vet__vet_name",
        "content",
    )  # 수의사 이름과 리뷰 내용으로 검색 가능


admin.site.register(Reviews, ReviewAdmin)

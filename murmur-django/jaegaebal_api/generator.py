import json

from reviews.models import Reviews


csv_file_path = "/Users/hyungkeunkang/jaegaebal_api/jaegaebal_api/concrete-mvp-default-rtdb-reviewInput-export.json"

with open(csv_file_path, "r", encoding="utf-8") as f:
    reader = json.DictReader(f)
    reviews = []

    for row in reader:
        review = Reviews(
            vet_id=row["vet"],  # Vets의 ID를 사용해야 합니다
            vet_explanation_type=row["vet_explanation_type"],
            written_date=row["written_date"],
            content_summary=row["content_summary"],
            content=row["content"],
        )
        reviews.append(review)

    Reviews.objects.bulk_create(reviews)  # 성능을 위해 bulk_create 사용

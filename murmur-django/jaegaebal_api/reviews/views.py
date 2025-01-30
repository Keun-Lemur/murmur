from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Reviews
from .serializers import ReviewsSerializer
from rest_framework import status
from urllib.parse import unquote  # URL 디코딩을 위한 모듈


EXPLANATION_TYPE_MAP = {
    "a": "검사결과 및 처방",
    "b": "예후 및 기대수명",
    "c": "관리 및 케어방법",
}


@api_view(["GET"])
def get_reviews(request):
    """
    GET 요청으로 모든 리뷰를 반환하는 API
    """
    reviews = Reviews.objects.all()  # 모든 리뷰를 조회

    if not reviews:
        return Response(
            {"detail": "리뷰가 없습니다."}, status=status.HTTP_404_NOT_FOUND
        )

    serializer = ReviewsSerializer(reviews, many=True)  # 리뷰 데이터를 직렬화
    return Response(serializer.data, status=status.HTTP_200_OK)


from urllib.parse import unquote
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Reviews
from .serializers import ReviewsSerializer
from rest_framework import status


EXPLANATION_TYPE_MAP = {
    "a": "검사결과 및 처방",
    "b": "예후 및 기대수명",
    "c": "관리 및 케어방법",
}


@api_view(["GET"])
def get_filtered_reviews(request, vet_id, vet_explanation_type):
    """
    GET 요청으로 특정 수의사의 특정 설명 타입에 맞는 리뷰를 반환하는 API
    """
    # URL 인코딩된 vet_explanation_type을 디코딩
    vet_explanation_type = unquote(vet_explanation_type)

    # 설명 타입을 확인하여 매핑된 값 가져오기
    explanation_type = EXPLANATION_TYPE_MAP.get(vet_explanation_type)

    if not explanation_type:
        return Response(
            {"detail": "유효하지 않은 설명 타입이에요."},
            status=status.HTTP_400_BAD_REQUEST,
        )

    # 특정 수의사의 특정 설명 타입에 맞는 리뷰 필터링
    reviews = Reviews.objects.filter(
        vet_id=vet_id, vet_explanation_type=explanation_type
    )

    if not reviews:
        return Response(
            {"detail": "해당 설명 타입에 맞는 리뷰가 없습니다."},
            status=status.HTTP_404_NOT_FOUND,
        )

    serializer = ReviewsSerializer(reviews, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


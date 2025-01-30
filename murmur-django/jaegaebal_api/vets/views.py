from urllib.parse import unquote
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Vets
from .serializers import VetsSerializer
from rest_framework import status
from django.db.models import Q


@api_view(["GET"])
def get_vets(request):
    """
    GET 요청으로 모든 수의사를 반환하는 API
    """
    vets = Vets.objects.all()  # 모든 수의사 데이터를 조회

    if not vets.exists():
        return Response(
            {"detail": "수의사가 없습니다."}, status=status.HTTP_404_NOT_FOUND
        )

    serializer = VetsSerializer(vets, many=True)  # 수의사 데이터를 직렬화
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(["GET"])
def get_one_vet(request, vet_id):
    """
    GET 요청으로 수의사를 반환하는 API
    """
    try:
        # vet_id를 이용해 Hospital에서 조회 (외래키 관계의 필드 명을 사용해야 함)
        one_vet = Vets.objects.get(id=vet_id)  # vet는 외래키, vet__id로 필터링

        # 특정 필드만 직렬화하기 위해 커스텀 serializer 생성
        serializer = VetsSerializer(one_vet)

        return Response(serializer.data)

    except Vets.DoesNotExist:
        return Response(
            {"error": "해당 수의사가 속한 병원이 존재하지 않습니다."},
            status=status.HTTP_404_NOT_FOUND,
        )


@api_view(["GET"])
def search_vets(request):
    """
    병원 이름 또는 수의사 이름으로 검색하는 API
    """
    search_word = request.GET.get("search-word", "")
    search_word = unquote(search_word)  # URL 인코딩된 검색어를 디코딩

    if search_word:
        # 병원 이름 또는 수의사 이름을 검색
        vets = Vets.objects.filter(
            Q(vet_name__icontains=search_word) | Q(hospital_name__icontains=search_word)
        ).distinct()
    else:
        return Response(
            {"detail": "검색어를 입력해주세요."}, status=status.HTTP_400_BAD_REQUEST
        )

    if not vets.exists():
        return Response(
            {"detail": "검색 결과가 없습니다."}, status=status.HTTP_404_NOT_FOUND
        )

    serializer = VetsSerializer(vets, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)

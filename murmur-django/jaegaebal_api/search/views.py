from urllib.parse import unquote
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.db.models import Q

from .models import VetSearch
from .serializers import VetSearchSerializer


@api_view(["GET"])
def get_vet_search(request):
    """병원 이름이나 수의사 이름으로 검색 기능"""
    # search-word를 URL에서 추출한 후 디코딩
    search_word = request.GET.get("search-word", "")
    search_word = unquote(unquote(search_word))  # 두 번 디코딩
    print(f"Received search word after decoding: {search_word}")  # 디코딩 후 출력

    if search_word:
        # VetSearch 모델에서 병원 이름이나 수의사 이름으로 검색
        vets = VetSearch.objects.filter(
            Q(vet_name__icontains=search_word) | Q(hospital_name__icontains=search_word)
        ).distinct()
    else:
        vets = VetSearch.objects.all()

    serializer = VetSearchSerializer(vets, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)

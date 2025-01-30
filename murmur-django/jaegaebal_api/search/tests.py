from django.test import TestCase
from django.urls import reverse
from .models import VetSearch


class VetSearchTest(TestCase):

    def setUp(self):
        # 테스트용 데이터 생성
        self.vet = VetSearch.objects.create(
            hospital_name="테스트 병원",
            vet_name="홍길동 수의사",
            main_medical_subjects="심장내과",
            one_line_review="최고의 수의사입니다.",
        )

    def test_vet_creation(self):
        # 생성된 수의사 정보가 잘 저장되었는지 테스트
        vet = VetSearch.objects.get(vet_name="홍길동 수의사")
        self.assertEqual(vet.hospital_name, "테스트 병원")

    def test_vet_search(self):
        # 검색 API 테스트
        response = self.client.get(reverse("vet_search"), {"search-word": "홍길동"})
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "홍길동 수의사")

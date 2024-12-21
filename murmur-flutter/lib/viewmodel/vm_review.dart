import 'package:flutter/material.dart';
import '../model/review.dart';
import '../service/review_service.dart';
import '../repository/review_repository.dart';

class ReviewViewModel extends ChangeNotifier {
  final ReviewService reviewService;

  List<Review> reviews = []; // 전체 리뷰 리스트
  bool isLoading = false;

  // 각 설명 유형에 따른 리뷰를 저장하기 위한 맵
  Map<String, List<Review>> filteredReviewsByType = {};
  Map<String, bool> isDataLoadedByType = {}; // 설명 유형별 데이터 로드 여부를 저장
  Map<String, bool> isLoadingByType = {}; // 설명 유형별 로딩 상태 저장

  // 기본 생성자에서 자동으로 ReviewService를 초기화
  ReviewViewModel()
      : reviewService = ReviewService(
          ReviewRepository(baseUrl: 'https://b1b2cd.up.railway.app/reviews/'),
        );

  // 특정 수의사와 설명 타입에 따른 리뷰 개수 가져오기
  int getReviewCountByType(String explanationType) {
    return filteredReviewsByType[explanationType]?.length ?? 0;
  }

  // 특정 수의사와 설명 타입에 맞는 리뷰 데이터를 가져오는 메서드
  Future<void> fetchFilteredReviews(
      int vetId, String vetExplanationType) async {
    // 이미 해당 설명 유형의 데이터가 로드되었거나 로딩 중이면 다시 가져오지 않음
    if (isDataLoadedByType[vetExplanationType] == true ||
        isLoadingByType[vetExplanationType] == true) {
      return;
    }

    isLoadingByType[vetExplanationType] = true;
    notifyListeners();

    try {
      List<Review> filteredReviews =
          await reviewService.getFilteredReviews(vetId, vetExplanationType);
      filteredReviewsByType[vetExplanationType] = filteredReviews;
      isDataLoadedByType[vetExplanationType] = true; // 데이터 로드됨 표시
    } catch (e) {
      // 에러 발생 시 해당 설명 유형에 빈 리스트 저장
      filteredReviewsByType[vetExplanationType] = [];
      isDataLoadedByType[vetExplanationType] = false; // 에러 시 로드 안됨으로 표시
    } finally {
      isLoadingByType[vetExplanationType] = false; // 로딩 완료 표시
      notifyListeners();
    }
  }

  // 특정 설명 유형에 맞는 리뷰 데이터를 반환하는 메서드
  List<Review> getReviewsByType(String explanationType) {
    return filteredReviewsByType[explanationType] ?? [];
  }

  // 설명 유형별 로딩 상태를 반환하는 메서드
  bool isReviewLoading(String explanationType) {
    return isLoadingByType[explanationType] ?? false;
  }

  // 리뷰 데이터를 강제로 새로 로드할 수 있도록 하는 메서드
  void resetReviewDataForType(String explanationType) {
    filteredReviewsByType[explanationType] = [];
    isDataLoadedByType[explanationType] = false;
    isLoadingByType[explanationType] = false;
    notifyListeners();
  }
}

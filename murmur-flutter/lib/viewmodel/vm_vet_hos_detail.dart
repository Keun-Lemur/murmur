import 'package:concrete_jaegaebal/model/vet_hos_detail_info.dart';
import 'package:concrete_jaegaebal/model/vet_info.dart';
import 'package:concrete_jaegaebal/service/vet_hos_detail_service.dart';
import 'package:flutter/material.dart';

class VetHosDetailViewModel extends ChangeNotifier {
  final VetHosDetailService _vetHosInfoDetailService = VetHosDetailService();

  VetInfo? _vetHosDetail; // VetHosInfoDetail 객체로 데이터 관리
  VetInfo? get vetHosDetail => _vetHosDetail; // 외부에서 접근 가능

  bool _isLoading = false; // 로딩 상태
  bool get isLoading => _isLoading;

  String? _errorMessage; // 에러 메시지
  String? get errorMessage => _errorMessage;

  bool _isDataLoaded = false; // 데이터가 로드되었는지 확인
  bool get isDataLoaded => _isDataLoaded;

  // 특정 vetId에 대한 VetHosInfoDetail 데이터를 가져오는 메서드
  Future<void> fetchVetHosDetail(int vetId) async {
    if (_isDataLoaded) {
      // 이미 데이터가 로드되었으면 다시 로드하지 않음
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 데이터 가져오는 작업 수행
      _vetHosDetail = await _vetHosInfoDetailService.getVetHosInfoDetail(vetId);
      _isDataLoaded = true; // 데이터가 성공적으로 로드되었음을 표시
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Error fetching vet and hospital info: $e";
    } finally {
      _isLoading = false;
      notifyListeners(); // 로딩이 끝난 후에만 호출
    }
  }

  // 데이터를 강제로 다시 로드하고 싶을 때 사용할 메서드
  Future<void> refreshVetHosDetail(int vetId) async {
    _isDataLoaded = false; // 데이터를 새로 로드할 수 있도록 플래그 초기화
    await fetchVetHosDetail(vetId); // 데이터를 다시 가져옴
  }
}

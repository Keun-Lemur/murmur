import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthStateProviderViewModel with ChangeNotifier {
  bool _isSurveyCompleted = false;

  bool get isSurveyCompleted => _isSurveyCompleted;

  // 설문조사 완료 시 호출되는 함수
  void completeSurvey() {
    _isSurveyCompleted = true;
    notifyListeners();
  }

  // Firestore에서 사용자 설문조사 완료 여부를 확인
  Future<bool> checkSurveyStatus() async {
    try {
      // FirebaseAuth를 통해 현재 사용자의 ID 가져오기
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;

        // Firestore에서 유저의 설문조사 완료 여부 확인
        final snapshot = await FirebaseFirestore.instance
            .collection('surveys')
            .doc(userId)
            .get(const GetOptions(source: Source.serverAndCache));

        // 문서가 존재하면 설문조사를 완료한 것으로 처리
        if (snapshot.exists && snapshot.data() != null) {
          _isSurveyCompleted = true;
        } else {
          _isSurveyCompleted = false;
        }
      } else {
        _isSurveyCompleted = false;
      }
    } catch (e) {
      // print('Error checking survey status: $e');
      _isSurveyCompleted = false;
    }

    notifyListeners();
    return _isSurveyCompleted; // Future<bool> 반환
  }

  // 상태 초기화 함수 (상태 비우기)
  void reset() {
    _isSurveyCompleted = false;
    notifyListeners(); // 상태가 변경되었음을 알림
  }

  @override
  void notifyListeners() {}
}

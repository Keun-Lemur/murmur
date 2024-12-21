// mobile_stub.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> updateVisitCountMobile() async {
  // 모바일 전용 로직
  // 예: Firebase를 사용하여 방문 횟수 업데이트
  var currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    final DocumentReference userDoc =
        FirebaseFirestore.instance.collection('logins').doc(currentUser.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userDoc);

      if (!snapshot.exists) {
        transaction.set(userDoc, {
          'uid': currentUser.uid,
          'email': currentUser.email,
          'login_count': 1,
          'last_login': FieldValue.serverTimestamp(),
          'isSurveyCompleted': false,
          'isWithdrawn': false
        });
      } else {
        int currentLoginCount = snapshot['login_count'];
        transaction.update(userDoc, {
          'login_count': currentLoginCount + 1,
          'last_login': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}

// 모바일 환경에서 iOS인지 여부를 반환하는 함수
bool isIOS() {
  print("ios detected");
  return Platform.isIOS;
}

// 모바일 환경에서는 웹이 아니므로 항상 false 반환
bool isIphoneInWeb() {
  print("모바일 환경에서 isIphoneInWeb 호출");
  return false;
}

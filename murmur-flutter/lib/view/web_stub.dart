// web_stub.dart

import 'package:universal_html/html.dart' as html;

// 웹 전용 로직
void updateVisitCountWeb() {
  if (html.window.sessionStorage['visit_logged'] != 'true') {
    html.window.sessionStorage['visit_logged'] = 'true';
  }
}

// // 웹 환경에서 iPhone인지 여부를 반환하는 함수
// bool isIphoneInWeb() {
//   print("웹 환경에서 isIphoneInWeb 호출");
//   final userAgent = html.window.navigator.userAgent.toLowerCase();
//   return userAgent.contains("iphone");
// }

// 웹 환경에서는 iOS가 아니므로 항상 false 반환
bool isIOS() {
  return false;
}

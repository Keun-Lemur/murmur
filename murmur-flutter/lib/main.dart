import 'dart:io';

// Flutter, Firebase 및 기타 필요한 패키지 import
import 'package:concrete_jaegaebal/view/web_stub.dart';
import 'package:flutter/foundation.dart'; // kIsWeb 사용
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart'; // Kakao SDK 추가

// 조건부 import
import 'package:concrete_jaegaebal/view/mobile_stub.dart'
    if (kIsWeb) 'package:concrete_jaegaebal/view/web_stub.dart';

import 'package:concrete_jaegaebal/view/s_home.dart';
import 'package:concrete_jaegaebal/viewmodel/vm_album.dart';
import 'package:concrete_jaegaebal/viewmodel/vm_auth_state_provider.dart';
import 'package:concrete_jaegaebal/viewmodel/vm_review.dart';
import 'package:concrete_jaegaebal/viewmodel/vm_vet_info.dart';
import 'package:showcaseview/showcaseview.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // // Kakao SDK 초기화 추가
  if (kIsWeb) {
    KakaoSdk.init(
      javaScriptAppKey:
          '001ca6947f8557f48e885c9b91776aaa', // 웹에서 사용하는 JavaScript 앱 키
    );
  } else {
    KakaoSdk.init(
      nativeAppKey: '66d4337703bd0185ce6b6fa2a783e63c', // 모바일에서 사용하는 네이티브 앱 키
    );
  }

  // 오류 처리 핸들러 추가
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print(details.stack); // 스택 트레이스를 출력
  };

  // 웹과 모바일 환경에 맞는 방문 카운트 업데이트 함수 호출
  if (kIsWeb) {
    updateVisitCountWeb(); // 웹에서 호출
  } else {
    await updateVisitCountMobile(); // 모바일에서 호출
  }

  runApp(
    ShowCaseWidget(
      builder: (context) => const MyApp(), // ShowCaseWidget 안에 MyApp을 배치
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlbumViewModel()),
        ChangeNotifierProvider(create: (_) => VetInfoViewModel()),
        ChangeNotifierProvider(create: (_) => ReviewViewModel()),
        ChangeNotifierProvider(create: (_) => AuthStateProviderViewModel()),
      ],
      child: MaterialApp(
        title: '머머: 우리아이와 맞는 심장병원을 찾아드립니다',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(
              fontFamily: 'PretendardDKTHK',
            ),
            bodyMedium: TextStyle(
              fontFamily: 'PretendardDKTHK',
            ),
            headlineLarge: TextStyle(
              fontFamily: 'PretendardDKTHK',
            ),
            headlineMedium: TextStyle(
              fontFamily: 'PretendardDKTHK',
            ),
          ),
        ),
        home: _getInitialScreen(),
        navigatorObservers: [
          FirebaseAnalyticsObserver(
              analytics: analytics), // FirebaseAnalyticsObserver 추가
        ],
      ),
    );
  }

  // 플랫폼에 따라 화면을 결정하는 함수
  Widget _getInitialScreen() {
    if (kIsWeb) {
      return const HomeScreen(); // 웹에서는 HomeScreen을 바로 보여줌
    } else if (Platform.isAndroid || Platform.isIOS) {
      return const IntroScreen(); // 모바일에서는 IntroScreen을 보여줌
    } else {
      return const HomeScreen(); // 기타 플랫폼에서도 HomeScreen
    }
  }
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 40,
                  right: 20,
                  left: 33), // Add padding from the edges
              child: Image.asset(
                'assets/splash.png',
                width: MediaQuery.of(context).size.width *
                    0.85, // Resize the image to 85% of screen width
              ),
            ),
          ),
        ],
      ),
    );
  }
}

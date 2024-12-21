// s_login.dart

// 조건부 임포트: 웹 환경이면 web_stub.dart, 아니면 mobile_stub.dart을 임포트
import 'mobile_stub.dart' if (dart.library.html) 'web_stub.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';

import 'package:concrete_jaegaebal/view/s_review.dart';
import 'package:concrete_jaegaebal/viewmodel/vm_auth_state_provider.dart';

import 's_signup.dart';

class LoginScreen extends StatefulWidget {
  final bool? withdrawFrom;
  final int? vetId;
  final String? title;
  const LoginScreen(
      {super.key, this.withdrawFrom = false, this.vetId, this.title});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  Future<void> checkLoginAndSurveyStatus(
      BuildContext context, bool withdrawFrom, int vetId, String title) async {
    // Firebase 현재 로그인된 사용자 확인
    var currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      print("User found: ${currentUser.uid} - ${currentUser.email}");

      final DocumentReference userDoc =
          FirebaseFirestore.instance.collection('logins').doc(currentUser.uid);

      // Firestore 문서 가져오기 및 설정
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userDoc);

        if (!snapshot.exists) {
          print("No document found for user. Creating a new document...");

          // 첫 로그인 시 Firestore에 문서 생성
          transaction.set(userDoc, {
            'uid': currentUser.uid,
            'email': currentUser.email,
            'login_count': 1,
            'last_login': FieldValue.serverTimestamp(),
            'isSurveyCompleted': false, // 설문조사 미완료 상태로 설정
            'isWithdrawn': false // 탈퇴 여부 기본값 설정
          });

          print("New document created for user: ${currentUser.uid}");
        } else {
          // 기존 로그인 기록이 있을 경우 login_count를 1 증가
          int currentLoginCount = snapshot['login_count'];
          print(
              "Existing document found. Current login count: $currentLoginCount");

          transaction.update(userDoc, {
            'login_count': currentLoginCount + 1,
            'last_login': FieldValue.serverTimestamp(),
          });

          print("Login count updated to ${currentLoginCount + 1}");
        }
      });

      // 문서 가져오기 (추가적인 처리를 위해)
      DocumentSnapshot userSnapshot = await userDoc.get();
      print("Document successfully retrieved: ${userSnapshot.id}");

      // 탈퇴 여부 확인
      bool isWithdrawn = userSnapshot['isWithdrawn'] ?? false;
      print("Is user withdrawn? $isWithdrawn");

      if (isWithdrawn) {
        // 탈퇴된 계정일 경우 로그인 차단
        print("User has withdrawn. Blocking login...");
        return;
      }

      // 설문조사 완료 여부 확인
      bool isSurveyCompleted = userSnapshot['isSurveyCompleted'] ?? false;
      print("Is survey completed? $isSurveyCompleted");

      if (isSurveyCompleted) {
        // 설문조사가 완료된 경우 바로 메인 화면으로 이동
        print("Survey completed. Navigating to main screen...");
        _navigateAfterLogin(context, withdrawFrom, vetId, title);
      } else {
        // 설문조사가 완료되지 않은 경우 설문조사 화면으로 이동
        print("Survey not completed. Navigating to survey screen...");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignupScreen(vetId: vetId, title: title),
          ),
        );
      }
    } else {
      print("No user found in FirebaseAuth");
    }
  }

  Future<void> completeSurvey() async {
    var currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final DocumentReference userDoc =
          FirebaseFirestore.instance.collection('logins').doc(currentUser.uid);

      // 설문조사 완료 시 Firestore에서 상태 업데이트
      await userDoc.update({
        'isSurveyCompleted': true, // 설문조사 완료로 업데이트
      });
    }
  }

  void _signInWithKakao(
      BuildContext context, bool withdrawFrom, int vetId, String title) async {
    setState(() => _loading = true);
    late OAuthProvider provider;

    // Initialize Kakao SDK for web and mobile
    if (kIsWeb) {
      KakaoSdk.init(
        javaScriptAppKey:
            '001ca6947f8557f48e885c9b91776aaa', // Web JavaScript app key
      );
    } else {
      KakaoSdk.init(
        nativeAppKey: '66d4337703bd0185ce6b6fa2a783e63c', // Native app key
      );
    }

    try {
      OAuthToken token;

      if (kIsWeb) {
        print("Starting Kakao login on web...");
        token = await UserApi.instance.loginWithKakaoAccount();
        var provider = OAuthProvider("oidc.heartb2");
        var credential = provider.credential(
          accessToken: token.accessToken,
          idToken: token.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      } else {
        if (await isKakaoTalkInstalled()) {
          print("Using KakaoTalk for login...");
          token = await UserApi.instance.loginWithKakaoAccount();
          var provider = OAuthProvider("oidc.kakaoApp");
          var credential = provider.credential(
            accessToken: token.accessToken,
            idToken: token.idToken,
          );
          await FirebaseAuth.instance.signInWithCredential(credential);
        } else {
          print("Using KakaoAccount for login...");
          token = await UserApi.instance.loginWithKakaoAccount();
          var provider = OAuthProvider("oidc.kakaoApp");
          var credential = provider.credential(
            accessToken: token.accessToken,
            idToken: token.idToken,
          );
          await FirebaseAuth.instance.signInWithCredential(credential);
        }
      }

      print("Kakao login successful: ${token.accessToken}");

      print("Firebase auth successful");

      // Check login and survey status
      await checkLoginAndSurveyStatus(context, withdrawFrom, vetId, title);
    } catch (error) {
      print("Kakao login failed: $error");
      if (error is FirebaseAuthException) {
        print("FirebaseAuthException: ${error.code} - ${error.message}");
      } else {
        print("Error: $error");
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> signInWithGoogle(
      BuildContext context, bool withdrawFrom, int vetId, String title) async {
    try {
      setState(() => _loading = true);

      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: ['profile', 'email'],
      ).signIn();

      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      await checkLoginAndSurveyStatus(context, withdrawFrom, vetId, title);
    } catch (e) {
      print(e);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> signInWithApple(
      BuildContext context, bool withdrawFrom, int vetId, String title) async {
    try {
      setState(() => _loading = true);

      final appleProvider = AppleAuthProvider();

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithProvider(appleProvider);

      await checkLoginAndSurveyStatus(context, withdrawFrom, vetId, title);
    } catch (e) {
      print(e);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            scrolledUnderElevation: 0,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 174),
                const Text(
                  '어딜 갈지\n결정을 못했나요?',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF333D4B),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.left,
                ),
                const Spacer(),
                Footer(
                  withdrawFrom: widget.withdrawFrom ?? false,
                  vetId: widget.vetId ?? 0,
                  title: widget.title ?? "Default Title",
                  signInWithKakao: _signInWithKakao,
                  signInWithGoogle: signInWithGoogle,
                  signInWithApple: signInWithApple,
                ),
              ],
            ),
          ),
        ),
        if (_loading)
          Container(
            color: Colors.black.withOpacity(0.7),
            width: double.maxFinite,
            height: double.maxFinite,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}

class Footer extends StatelessWidget {
  final bool withdrawFrom;
  final int vetId;
  final String title;
  final Function(BuildContext, bool, int, String) signInWithKakao;
  final Function(BuildContext, bool, int, String) signInWithGoogle;
  final Function(BuildContext, bool, int, String) signInWithApple;

  const Footer({
    super.key,
    required this.withdrawFrom,
    required this.vetId,
    required this.title,
    required this.signInWithKakao,
    required this.signInWithGoogle,
    required this.signInWithApple,
  });

  @override
  Widget build(BuildContext context) {
    print("Footer build called");

    // Call the platform-specific functions
    // bool isIphone = isIphoneInWeb();
    bool isIos = isIOS();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              signInWithKakao(context, withdrawFrom, vetId, title);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEE500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Image.asset(
              'assets/images/kakao_login.png',
              width: 147,
              height: 20,
            ),
          ),
        ),
        const SizedBox(height: 17),
        if (!kIsWeb && isIos)
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                signInWithApple(context, withdrawFrom, vetId, title);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16171C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Image.asset(
                'assets/images/apple_login.png',
                width: 147,
                height: 20,
              ),
            ),
          )
        else
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                signInWithGoogle(context, withdrawFrom, vetId, title);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16171C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Image.asset(
                'assets/images/google_login.png',
                width: 147,
                height: 20,
              ),
            ),
          ),
        const SizedBox(height: 72),
        // Optional: Use isIphone variable as needed
        // if (isIphone) const Text("iPhone detected on Web") else Container(),
      ],
    );
  }
}

void _navigateAfterLogin(
    BuildContext context, bool withdrawFrom, int vetId, String title) {
  if (withdrawFrom) {
    Navigator.pop(context, true);
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => SignupScreen(vetId: vetId, title: title)),
    );
  }
}

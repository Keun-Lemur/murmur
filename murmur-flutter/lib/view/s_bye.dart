import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concrete_jaegaebal/view/s_home.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'
    as kakao_user;
import 'package:firebase_core/firebase_core.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => WithdrawScreenState();
}

class WithdrawScreenState extends State<WithdrawScreen> {
  bool _isChecked = false;
  bool _loading = false;
  bool _isReauthenticated = false;

  // 문장 리스트로 변경
  final List<String> withdrawalMessages = [
    '개인정보 및 이용 기록은 모두 삭제되며, 삭제된 계정은 복구할 수 없어요.',
    'SNS 가입인 경우 해당 SNS 사이트에서 00과 연결된 계정을 직접 해제해주셔야 삭제가 가능합니다.',
    '앞으로 추가될 다양한 병원정보와 케어 방법등을 볼 수 없어요.'
  ];

  /// 공통 모달 다이얼로그 디자인 함수
  void _showCustomModal({
    required BuildContext context,
    required String title,
    required String content,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 355,
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333D4B),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF808799),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0073FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    onPressed: onPressed,
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 재로그인이 필요할 때 모달 표시
  Future<void> _showReauthenticationModal(BuildContext context) async {
    _showCustomModal(
      context: context,
      title: '로그인 계정이 없습니다!',
      content: '처음 방문하셨거나 로그인이 필요해요! 홈으로!',
      buttonText: '확인',
      onPressed: () {
        // Navigator.pop(context);
        Navigator.of(context)
            .pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false, // 모든 이전 화면을 제거합니다.
        )
            .then(
          (loginSuccess) {
            if (loginSuccess == true) {
              setState(() {
                _isReauthenticated = true;
              });
            }
          },
        );
      },
    );
  }

  // 탈퇴 완료 모달
  void _showConfirmationModal(BuildContext context) {
    _showCustomModal(
      context: context,
      title: '탈퇴 완료',
      content: '탈퇴가 완료되었습니다. 이용해주셔서 감사합니다.',
      buttonText: '완료',
      onPressed: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      },
    );
  }

  /// Firebase 인증 공급자에 따라 재인증 수행
  Future<void> reauthenticateUser() async {
    firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;

    if (user != null) {
      String providerId = user.providerData[0].providerId;
      // print("첫 번째 로그인 공급자: $providerId");

      if (providerId == 'google.com') {
        await _reauthenticateWithGoogle();
      } else if (providerId == 'apple.com') {
        await _reauthenticateWithApple();
      } else if (providerId == 'oidc.kakaoApp') {
        await _reauthenticateWithKakao();
      } else {
        // print("지원되지 않는 공급자입니다: $providerId");
      }
    } else {
      // print("로그인된 사용자가 없습니다.");
      _showReauthenticationModal(context); // 재인증 모달 표시
    }
  }

  /// 구글 계정으로 재인증
  Future<void> _reauthenticateWithGoogle() async {
    try {
      setState(() => _loading = true);

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // print("Google 로그인 실패: 사용자가 로그인하지 않았거나 취소되었습니다.");
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await firebase_auth.FirebaseAuth.instance.currentUser
          ?.reauthenticateWithCredential(credential);

      // print("구글 재인증 성공");
      await deleteUserAccount(); // 재인증 후 계정 삭제
    } catch (e) {
      // print("구글 재인증 중 오류 발생: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  /// 애플 계정으로 재인증
  Future<void> _reauthenticateWithApple() async {
    try {
      setState(() => _loading = true);
      final appleProvider = firebase_auth.AppleAuthProvider();

      await firebase_auth.FirebaseAuth.instance.currentUser
          ?.reauthenticateWithProvider(appleProvider);

      // print("애플 재인증 성공");
      await deleteUserAccount();
    } catch (e) {
      // print("애플 재인증 중 오류 발생: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  /// 카카오 계정으로 재인증
  Future<void> _reauthenticateWithKakao() async {
    try {
      setState(() => _loading = true);
      firebase_auth.OAuthProvider provider =
          firebase_auth.OAuthProvider("oidc.kakaoApp");

      kakao_user.OAuthToken token;
      if (await kakao_user.isKakaoTalkInstalled()) {
        try {
          token = await kakao_user.UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          token = await kakao_user.UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await kakao_user.UserApi.instance.loginWithKakaoAccount();
      }

      var credential = provider.credential(
          idToken: token.idToken, accessToken: token.accessToken);

      await firebase_auth.FirebaseAuth.instance.currentUser
          ?.reauthenticateWithCredential(credential);

      // print("카카오 재인증 성공");
      await deleteUserAccount(); // 재인증 후 계정 삭제
    } catch (error) {
      // print("카카오 재인증 실패: $error");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> deleteUserAccount() async {
    try {
      firebase_auth.User? user =
          firebase_auth.FirebaseAuth.instance.currentUser;

      if (user != null) {
        final DocumentReference userDoc =
            FirebaseFirestore.instance.collection('logins').doc(user.uid);

        await userDoc.update({
          'isWithdrawn': true, // 탈퇴 상태로 변경
        });

        await user.delete(); // Firebase에서 계정 삭제
        // print("사용자 계정이 삭제되었습니다.");

        _showConfirmationModal(context); // 탈퇴 완료 모달 표시
      } else {
        // print("로그인된 사용자가 없습니다.");
      }
    } catch (e) {
      // print("계정 삭제 중 오류 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
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
        title: const Text(
          '탈퇴',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 34),
              const Text(
                '보호자님,\n탈퇴하기 전에 확인해주세요',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333D4B),
                  fontFamily: 'PretendardDKTHK',
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 42),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: withdrawalMessages.map((message) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '•',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.9,
                            color: Color(0xFF7A8091),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            message,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF7A8091),
                              fontFamily: 'PretendardDKTHK',
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 36, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isChecked = !_isChecked; // 체크 상태 전환
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isChecked
                            ? const Color(0xFF0073FA)
                            : const Color(0xFFCACED8),
                        width: _isChecked ? 2 : 1,
                      ),
                    ),
                    child: _isChecked
                        ? const Icon(Icons.check,
                            size: 18, color: Color(0xFF0073FA))
                        : const Icon(Icons.check,
                            size: 18, color: Color(0xFFCACED8)),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '탈퇴에 동의합니다',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF7A8091),
                    fontFamily: 'PretendardDKTHK',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 29),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0073FA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                onPressed: _isChecked
                    ? () {
                        reauthenticateUser(); // 재인증 수행 후 계정 삭제
                      }
                    : null,
                child: const Text(
                  '다음',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'PretendardDKTHK',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

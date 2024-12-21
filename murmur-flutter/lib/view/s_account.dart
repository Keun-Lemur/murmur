import 'package:concrete_jaegaebal/view/s_bye.dart';
import 'package:flutter/material.dart';
import 'package:concrete_jaegaebal/view/s_privacy_policy.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // 그림자 제거
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
          '설정',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true, // 텍스트 중앙 정렬
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 20.0, vertical: 32.0), // 좌우 20px 패딩 추가
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrivacyPolicyScreen(),
                  ),
                );
              },
              child: const Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft, // 왼쪽에 딱 붙게
                      child: Text(
                        '개인정보 처리방침',
                        style: TextStyle(
                          fontFamily: 'PretendardDKTHK',
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF333D4B),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight, // 오른쪽에 딱 붙게
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36), // 두 항목 사이 36px 간격
            InkWell(
              onTap: () {
                // ByePage로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WithdrawScreen()),
                );
              },
              child: const Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft, // 왼쪽에 딱 붙게
                      child: Text(
                        '회원 탈퇴',
                        style: TextStyle(
                          fontFamily: 'PretendardDKTHK',
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF333D4B),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight, // 오른쪽에 딱 붙게
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

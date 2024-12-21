import 'package:flutter/material.dart';

class NoDataScreen extends StatelessWidget {
  const NoDataScreen({super.key});

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
          '영수증 자세히보기',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true, // 텍스트 중앙 정렬
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            Image.asset('assets/images/warning_sign.png'),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "데이터 분석 중",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                fontFamily: "PretendardDKTHK",
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
              children: [
                Image.asset(
                  'assets/images/dev.png',
                  height: 16, // 폰트 크기와 맞추기 위해 이미지 크기 조정
                ),
                const SizedBox(width: 5), // 이미지와 텍스트 사이 간격
                const Text(
                  "10/1 모든 진료영수증이 공개돼요",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "PretendardDKTHK",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TBDScreen extends StatelessWidget {
  const TBDScreen({super.key});

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
          '영수증 자세히 보기',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true, // 텍스트 중앙 정렬
      ),
      body: const Center(
        // 바디 전체를 중앙 정렬
        child: Padding(
          padding: EdgeInsets.only(top: 125.0), // 앱바 아래 125px
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '⚠️',
                style: TextStyle(
                  fontSize: 74, // 74px 크기
                ),
                textAlign: TextAlign.center, // 텍스트 가운데 정렬
              ),
              SizedBox(height: 19), // ⚠️ 아래로 19px
              Text(
                '데이터 분석중',
                style: TextStyle(
                  fontSize: 24, // 24px 크기
                  fontWeight: FontWeight.w800, // 두께 800
                  color: Colors.black,
                ),
                textAlign: TextAlign.center, // 텍스트 가운데 정렬
              ),
              SizedBox(height: 10), // 텍스트 아래로 10px
              Text(
                '👨🏻‍💻 10/1 모든 진료영수증이 공개돼요',
                style: TextStyle(
                  fontSize: 16, // 16px 크기
                  fontWeight: FontWeight.w400, // 두께 400
                  color: Colors.black,
                ),
                textAlign: TextAlign.center, // 텍스트 가운데 정렬
              ),
            ],
          ),
        ),
      ),
    );
  }
}

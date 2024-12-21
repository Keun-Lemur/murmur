import 'dart:math'; // for Random
import 'package:concrete_jaegaebal/viewmodel/vm_review.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReviewScreen extends StatefulWidget {
  final String title;
  final int vetId;
  final int? reviewCount;

  const ReviewScreen({
    super.key,
    required this.title,
    required this.vetId,
    this.reviewCount,
  });

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  @override
  void initState() {
    super.initState();
    // print(widget.vetId);
    // 데이터를 불러오고 상태를 갱신
    Future.microtask(() async {
      final reviewModel = Provider.of<ReviewViewModel>(context, listen: false);
      // 특정 수의사와 설명 유형에 맞는 리뷰를 로드
      await reviewModel.fetchFilteredReviews(widget.vetId, widget.title);
    });
  }

  // Helper method to generate random writer info
  String getRandomWriterInfo() {
    final random = Random();
    int starCount =
        random.nextInt(3) + 2; // Generates 2 to 4 stars (** to ****)
    return '${'*' * starCount} 보호자'; // Example: **보호자, ***보호자, etc.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar를 커스터마이즈하여 최대 너비 560으로 제한하고 상단에 정렬
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 제거
        toolbarHeight: 70.0, // AppBar 높이 고정
        flexibleSpace: Align(
          alignment: Alignment.center, // 왼쪽 정렬
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.symmetric(horizontal: 10.0), // 좌우 패딩 조절
            child: Row(
              children: [
                // 왼쪽 아이콘
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      size: 20, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                // 제목
                Expanded(
                  child: Text(
                    '${widget.title} 진료 후기', // 수정된 부분
                    style: const TextStyle(
                      color: Color(0xFF333D4B),
                      fontSize: 17,
                      fontFamily: 'PretendardDKTHK',
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center, // 왼쪽 정렬
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      ),
      // Scaffold의 body 영역을 Align과 Container로 감싸 최대 너비 560으로 제한하고 상단에 정렬
      body: Align(
        alignment: Alignment.topCenter, // 상단 정렬
        child: Container(
          constraints: const BoxConstraints(maxWidth: 560),
          width: double.infinity, // 화면 크기에 맞게 넓이 조정
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Consumer<ReviewViewModel>(
              builder: (context, reviewModel, child) {
                // 로딩 중일 때
                if (reviewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 설명 유형에 맞는 리뷰 리스트 가져오기
                final reviews = reviewModel.getReviewsByType(widget.title);

                // 리뷰가 없을 경우 처리
                if (reviews.isEmpty) {
                  return const Center(child: Text('리뷰가 없습니다.'));
                }

                // 리뷰 리스트 출력
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    final writerInfo = getRandomWriterInfo();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.contentSummary,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            review.content,
                            style: const TextStyle(
                              color: Color(0xFF434956),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${review.writtenDate} | $writerInfo', // 랜덤 보호자 정보
                            style: const TextStyle(
                              color: Color(0xFF95969A),
                              fontSize: 13,
                              fontFamily: 'PretendardDKTHK',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFE3E6ED),
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

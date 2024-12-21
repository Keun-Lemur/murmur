import 'package:concrete_jaegaebal/model/vet_info.dart';
import 'package:concrete_jaegaebal/view/s_hos_detail.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import '../model/album.dart';

class AlbumDetailScreen extends StatefulWidget {
  final Album album; // Album 객체를 전달받습니다.

  const AlbumDetailScreen({super.key, required this.album});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  // Firebase Analytics 인스턴스 생성
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  Future<void> _logAlbumDetailClickEvent(String vetName) async {
    await analytics.logEvent(
      name: 'album_detail_click',
      parameters: <String, Object>{
        'vet_name': vetName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<VetInfo> vets = widget.album.vets;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 제거
        toolbarHeight: 70.0, // AppBar 높이 고정
        flexibleSpace: Align(
          alignment: Alignment.center, // 중앙 정렬
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
                    widget.album.albumTitle.length > 17
                        ? '${widget.album.albumTitle.substring(0, 17)}...'
                        : widget.album.albumTitle,
                    style: const TextStyle(
                      color: Color(0xFF333D4B),
                      fontSize: 17,
                      fontFamily: 'PretendardDKTHK',
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center, // 중앙 정렬
                    overflow: TextOverflow.ellipsis, // 글자가 넘칠 경우 생략
                  ),
                ),

                // 오른쪽에 10px 간격 추가
                const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 7), // 7px 짜리 SizedBox 추가
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: vets.length,
              itemBuilder: (context, index) {
                final vet = vets[index];

                return GestureDetector(
                  onTap: () {
                    // print("I clicked firebase vetname: ${vet.vetName!}");
                    _logAlbumDetailClickEvent(vet.vetName!);
                    // 수의사 상세 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HospitalDetailScreen(
                          vetId: vet.id,
                        ),
                      ),
                    );
                  },
                  child: Align(
                    alignment: Alignment.center, // Card를 중앙에 배치
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: 560), // 최대 너비 설정
                      child: Card(
                        color: Colors.white,
                        elevation: 0, // 그림자 제거
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 17),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(22, 23, 22, 21),
                          child: SizedBox(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize:
                                  MainAxisSize.min, // This helps avoid overflow
                              children: [
                                const Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    '진료 스타일',
                                    style: TextStyle(
                                      color: Color(0xFF066AE5),
                                      fontSize: 13,
                                      fontFamily: 'PretendardDKTHK',
                                      fontWeight: FontWeight.w700,
                                      height: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    vet.oneLineReview ?? "한줄평이없어요",
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Color(0xFF333D4B),
                                      fontSize: 20.5,
                                      fontFamily: 'PretendardDKTHK',
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.41,
                                      height: 1.414,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Container(
                                  decoration: const ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 0.50,
                                        strokeAlign:
                                            BorderSide.strokeAlignCenter,
                                        color: Color(0xFFCACED8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    '${vet.hospitalName ?? ' '} ㅣ ${vet.vetName ?? ' '}',
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Color(0xFF434956),
                                      fontSize: 13,
                                      fontFamily: 'PretendardDKTHK',
                                      fontWeight: FontWeight.w400,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

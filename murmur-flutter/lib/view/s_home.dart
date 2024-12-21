import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:concrete_jaegaebal/viewmodel/vm_album.dart';
import 'package:concrete_jaegaebal/view/s_album_detail.dart';
import 'package:concrete_jaegaebal/view/s_search.dart';
import 'package:concrete_jaegaebal/view/s_account.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MainPageState();
}

class _MainPageState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  bool showFloatingSearchBar = false;

  // Firebase Analytics 인스턴스 생성
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // Firestore 인스턴스 생성.
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showBottomSheet();
      Provider.of<AlbumViewModel>(context, listen: false).fetchAlbums();
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
      showFloatingSearchBar = _scrollOffset >= 305.0;
    });
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: true, // 바깥을 누르면 닫히는 설정
      builder: (BuildContext context) {
        return Container(
          height: 350, // 높이를 350으로 설정
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Stack(
            children: <Widget>[
              // 닫기 버튼
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // 닫기
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.close_rounded,
                      weight: 20,
                    ),
                  ),
                ),
              ),
              // 내용
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                children: <Widget>[
                  Center(
                    child: Image.asset(
                      'assets/images/dont_understand.png', // 이미지 경로 설정
                      width: 90, // 이미지 가로 크기 설정
                      height: 90, // 이미지 세로 크기 설정
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(18.0),
                    child: Text(
                      '설명을 듣고도 집에서 \'폭풍검색\' 한다면?!\n설명 놓칠까 봐 녹음한다면?!',
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'PretendardDKTHK',
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.left, // 텍스트 왼쪽 정렬
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _incrementButtonClick(); // 클릭 횟수 저장 함수 호출
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0054bb), // 버튼 색상
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 8), // 양옆 더 길게, 높이 줄임
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // 살짝 둥근 모서리
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '여기서 확인하기',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'PretendardDKTHK',
                              color: Colors.white), // 버튼 텍스트 크기 조정
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

// 클릭 횟수 증가 함수
  Future<void> _incrementButtonClick() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Firestore에 클릭 횟수 저장
    DocumentReference docRef =
        firestore.collection('nok_clicks').doc('check_button');

    await firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        transaction.set(docRef, {'click_count': 1}); // 초기 클릭 횟수 설정
      } else {
        int newCount = snapshot['click_count'] + 1;
        transaction.update(docRef, {'click_count': newCount}); // 클릭 횟수 증가
      }
    });
  }

  Future<void> _logAlbumClickEvent(int albumId, String albumTitle) async {
    await analytics.logEvent(
      name: 'album_click',
      parameters: <String, Object>{
        'album_id': albumId,
        'album_title': albumTitle,
      },
    );
  }

  Future<void> _logArchiveClickEvent() async {
    await analytics.logEvent(
      name: 'archive_click',
      parameters: <String, Object>{'click_location': 'home_screen'},
    );
  }

  Widget _buildSearchBar(double height) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SearchScreen(),
          ),
        );
      },
      child: Container(
        height: height,
        decoration: ShapeDecoration(
          color: const Color(0xFFF2F4F7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Image.asset(
                'assets/images/search_icon.png',
                width: 23,
                height: 23,
              ),
            ),
            const Expanded(
              child: Text(
                '병원, 수의사를 검색하세요',
                style: TextStyle(
                  fontFamily: 'PretendardDKTHK',
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                  color: Color(0xFF808799),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double opacityValue;
    if (_scrollOffset <= 125) {
      opacityValue = 1.0;
    } else if (_scrollOffset <= 225) {
      opacityValue = 1 - ((_scrollOffset - 125) / 100);
    } else {
      opacityValue = 0.0;
    }
    opacityValue = opacityValue.clamp(0.0, 1.0);

    const double maxWidth = 560.0;

    Future<void> launchURL(String url) async {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.white,
                    pinned: false,
                    floating: false,
                    expandedHeight: 60.0,
                    elevation: 0,
                    flexibleSpace: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.account_circle_rounded,
                                  size: 40,
                                  color: Color(0xFF808799),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AccountScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverToBoxAdapter(
                      child: Opacity(
                        opacity: opacityValue,
                        child: Center(
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: maxWidth),
                            child: const Padding(
                              padding:
                                  EdgeInsets.only(top: 107.0, bottom: 18.0),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  '우리 아이와 맞는\n심장병원을 찾아드립니다.',
                                  style: TextStyle(
                                    color: Color(0xFF333D4B),
                                    fontSize: 30,
                                    fontFamily: 'PretendardDKTHK',
                                    fontWeight: FontWeight.w700,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverAppBar(
                    pinned: false,
                    floating: false,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    automaticallyImplyLeading: false,
                    expandedHeight: 56.0,
                    collapsedHeight: 56.0,
                    flexibleSpace: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: maxWidth),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 0.0),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: _buildSearchBar(54.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: maxWidth),
                          child: const Padding(
                            padding: EdgeInsets.only(top: 92),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '내 기준에 맞는 병원 찾기',
                                style: TextStyle(
                                  color: Color(0xFF333D4B),
                                  fontSize: 19,
                                  fontFamily: 'PretendardDKTHK',
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Consumer<AlbumViewModel>(
                    builder: (context, viewModel, child) {
                      if (viewModel.isLoading) {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 18, horizontal: 20.0),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width - 40,
                                    height: 123, // Shimmer 컨테이너의 높이 설정
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                            childCount: 6,
                          ),
                        );
                      } else if (viewModel.errorMessage != null) {
                        return SliverToBoxAdapter(
                          child: Center(child: Text(viewModel.errorMessage!)),
                        );
                      } else if (viewModel.albums.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Center(child: Text('No albums available')),
                        );
                      } else {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final album = viewModel.albums[index];
                              return GestureDetector(
                                onTap: () {
                                  _logAlbumClickEvent(index, album.albumTitle);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AlbumDetailScreen(album: album),
                                    ),
                                  );
                                },
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        maxWidth: maxWidth),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 18, horizontal: 20.0),
                                      child: album.albumImage != null
                                          ? Image.network(
                                              album.albumImage!,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  40,
                                              fit: BoxFit.fitWidth,
                                            )
                                          : Container(),
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: viewModel.albums.length,
                          ),
                        );
                      }
                    },
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: maxWidth),
                          child: const Padding(
                            padding: EdgeInsets.only(top: 73),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '모르고 가면 안 알려줘요',
                                style: TextStyle(
                                  color: Color(0xFF333D4B),
                                  fontSize: 19,
                                  fontFamily: 'PretendardDKTHK',
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: GestureDetector(
                      onTap: () {
                        _logArchiveClickEvent();
                        launchURL('https://page-archive.vercel.app');
                      },
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: maxWidth),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20.0),
                            child: Image.asset(
                              'assets/images/goto_archive.png', // assets에 저장된 이미지 경로
                              width: MediaQuery.of(context).size.width - 40,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // 상단 고정 검색바
          if (showFloatingSearchBar)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 108.0, // 앱바 높이
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFCCCCCC), // 아래쪽 보더라인 추가
                      width: 1.0,
                    ),
                  ),
                ),
                padding: const EdgeInsets.only(
                    top: 60.0, bottom: 10, left: 20, right: 20),
                child: Center(
                  child: SizedBox(
                    height: 36.0, // 검색창 높이를 36px로 설정
                    child: _buildSearchBar(36.0),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

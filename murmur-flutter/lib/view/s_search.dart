import 'package:concrete_jaegaebal/view/s_hos_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = []; // 검색 결과 저장
  List<String> _recentSearches = []; // 최근 검색어 저장
  bool _isLoading = false; // 검색 중 여부를 나타내는 상태
  bool _hasSearched = false; // 사용자가 검색을 했는지 여부를 추적하는 상태
  bool _isRecentSearchesLoaded = false; // 최근 검색어 로드 여부

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore 인스턴스 가져오기

  @override
  void initState() {
    super.initState();
    _loadRecentSearches(); // 앱 시작 시 최근 검색어 로드
    _searchController.addListener(_onSearchTextChanged); // 검색어 변경 감지
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged); // 리스너 해제
    _searchController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  // 검색어 입력 상태를 감지하는 함수
  void _onSearchTextChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _hasSearched = false; // 검색을 하지 않았다고 상태 변경
        _searchResults.clear(); // 검색 결과 초기화
      });
    }
  }

  // 최근 검색어 로드
  Future<void> _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
      _isRecentSearchesLoaded = true; // 최근 검색어 로드 완료
    });
  }

  // 최근 검색어 저장
  Future<void> _saveRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('recent_searches', _recentSearches);
  }

  // Firestore에 검색어 저장
  Future<void> _saveSearchTermToFirestore(String searchTerm) async {
    try {
      final searchTermsRef = _firestore.collection('search_terms');

      // 검색어가 이미 Firestore에 있는지 확인
      final querySnapshot =
          await searchTermsRef.where('term', isEqualTo: searchTerm).get();

      if (querySnapshot.docs.isEmpty) {
        // 검색어가 없으면 Firestore에 저장하고, count를 1로 설정
        await searchTermsRef.add({
          'term': searchTerm,
          'count': 1,
          'timestamp': FieldValue.serverTimestamp(), // 검색 시간 저장
        });
      } else {
        // 검색어가 있으면 count를 1 증가
        final docId = querySnapshot.docs.first.id;
        final currentCount = querySnapshot.docs.first['count'] ?? 0;

        await searchTermsRef.doc(docId).update({
          'count': currentCount + 1,
          'timestamp': FieldValue.serverTimestamp(), // 마지막 검색 시간 업데이트
        });
      }
    } catch (e) {
      print('Firestore에 검색어 저장 중 오류 발생: $e');
    }
  }

  // 검색 수행
  Future<void> _search(String query) async {
    if (query.isEmpty) return;

    // Firestore에 검색어 저장
    await _saveSearchTermToFirestore(query);

    // 최근 검색어에 추가
    if (!_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.add(query);
        _saveRecentSearches(); // 최근 검색어 저장
      });
    }

    // 새로운 검색어 입력 시 상태 초기화
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _searchResults = [];
    });

    try {
      var response = await Dio().get(
        'https://b1b2cd.up.railway.app/vets/search/', // 실제 API URL에 맞춰 변경
        queryParameters: {'search-word': query},
      );

      if (response.data is List) {
        setState(() {
          _searchResults = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('검색 중 오류 발생: $e');
    }
  }

  // 최근 검색어 삭제
  void _clearRecentSearches() {
    setState(() {
      _recentSearches.clear();
      _saveRecentSearches(); // 최근 검색어 삭제 후 저장
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 검색 결과가 있을 경우 배경색 변경
      backgroundColor:
          _searchResults.isNotEmpty ? const Color(0xFFF2F4F7) : Colors.white,

      // 커스터마이즈된 AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // 그림자 제거
        automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 제거
        toolbarHeight: 70.0, // AppBar 높이 고정

        // flexibleSpace를 사용하여 전체 AppBar 콘텐츠를 커스터마이징
        flexibleSpace: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.symmetric(horizontal: 20.0), // 좌우 패딩 조절
            child: Row(
              children: [
                // 왼쪽 아이콘
                Padding(
                  padding: const EdgeInsets.only(bottom: 0.0),
                  child: IconButton(
                    icon:
                        const Icon(Icons.close, size: 30, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 10), // 아이콘과 검색 바 사이 간격
                // 검색 바
                Expanded(
                  child: Container(
                    height: 47.0, // 검색 바 높이 고정
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: const Color(0xFFF2F4F7),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '검색어 병원, 수의사를 검색하세요',
                        hintStyle: const TextStyle(
                          fontFamily: 'NotoSansKR',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.45,
                          color: Color(0xFF949494),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            _search(_searchController.text);
                          },
                          child: const Icon(Icons.search),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 0.0), // 상하 패딩 0으로 설정
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (query) {
                        _search(query);
                      },
                      style: const TextStyle(
                        // 입력 텍스트 스타일 설정
                        fontFamily: 'NotoSansKR',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Scaffold의 body 영역을 최대 너비 560으로 제한하고 상단에 정렬
      body: Align(
        alignment: Alignment.topCenter, // 상단 정렬
        child: Container(
          constraints: const BoxConstraints(maxWidth: 560),
          width: double.infinity, // 화면 크기에 맞게 넓이 조정
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : !_hasSearched
                    ? _isRecentSearchesLoaded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_recentSearches.isNotEmpty) ...[
                                const Padding(
                                  padding:
                                      EdgeInsets.only(left: 0.0, top: 22.0),
                                  child: Text(
                                    '최근 검색어',
                                    style: TextStyle(
                                        fontFamily: 'NotoSansKR',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF808799)),
                                  ),
                                ),
                                for (var search in _recentSearches)
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceBetween, // 아이템을 양 끝으로 배치
                                        children: [
                                          Expanded(
                                            child: ListTile(
                                              contentPadding: EdgeInsets
                                                  .zero, // ListTile의 기본 패딩을 제거
                                              title: Text(
                                                search,
                                                style: const TextStyle(
                                                  // 텍스트 스타일 지정
                                                  fontFamily:
                                                      'NotoSansKR', // 원하는 폰트 패밀리
                                                  fontSize: 17, // 폰트 크기
                                                  fontWeight:
                                                      FontWeight.w400, // 폰트 굵기
                                                  color: Color(
                                                      0xFF333D4B), // 텍스트 색상
                                                ),
                                              ),
                                              onTap: () {
                                                _searchController.text = search;
                                                _search(search);
                                              },
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _recentSearches.remove(
                                                    search); // 해당 검색어 삭제
                                                _saveRecentSearches(); // 최근 검색어 저장
                                              });
                                            },
                                            style: TextButton.styleFrom(
                                              padding:
                                                  EdgeInsets.zero, // 기본 패딩 제거
                                              minimumSize:
                                                  const Size(0, 20), // 최소 크기 지정
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap, // 터치 영역 최소화
                                            ),
                                            child: const Icon(
                                              Icons.close, // 아이콘을 텍스트 대신 사용
                                              color:
                                                  Color(0xFF434956), // 아이콘 색상
                                              size: 21.0, // 아이콘 크기
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(
                                        // 구분선 추가
                                        thickness: 1, // 두께 설정
                                        color: Color(0xFFE0E0E0), // 색상 설정
                                        height: 0, // 구분선의 높이
                                        indent: 0, // 왼쪽 여백 제거
                                        endIndent: 0, // 오른쪽 여백 제거
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween, // 양 끝으로 배치
                                  children: [
                                    TextButton(
                                      onPressed: _clearRecentSearches,
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero, // 기본 패딩 제거
                                        minimumSize:
                                            const Size(0, 30), // 버튼의 최소 크기 설정
                                        tapTargetSize: MaterialTapTargetSize
                                            .shrinkWrap, // 탭 영역 최소화
                                      ),
                                      child: const Text(
                                        '전체 삭제',
                                        style: TextStyle(
                                          fontFamily: 'NotoSansKR',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF808799), // 글자색 설정
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero, // 기본 패딩 제거
                                        minimumSize:
                                            const Size(0, 30), // 버튼의 최소 크기 설정
                                        tapTargetSize: MaterialTapTargetSize
                                            .shrinkWrap, // 탭 영역 최소화
                                      ),
                                      child: const Text(
                                        '닫기',
                                        style: TextStyle(
                                          fontFamily: 'NotoSansKR',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF808799), // 글자색 설정
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else
                                const Center(
                                    child: Text(
                                  '',
                                )),
                            ],
                          )
                        : const Center(
                            child: Text(
                              '',
                            ),
                          )
                    : _searchResults.isEmpty
                        ? const Center(
                            child: Text('검색 결과가 없습니다.'),
                          )
                        : ListView.builder(
                            // Expanded 제거
                            physics:
                                const ClampingScrollPhysics(), // 스크롤 동작을 고정된 방식으로 설정
                            shrinkWrap: true, // ListView의 크기를 자식 요소에 맞춰 줄이지 않음
                            padding: EdgeInsets.zero, // 패딩을 0으로 설정
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final vet = _searchResults[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          HospitalDetailScreen(
                                        vetId: vet['id'],
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: Colors.white,
                                  elevation: 0, // 그림자 제거
                                  margin: const EdgeInsets.only(
                                      top: 44), // 수직 마진 줄임
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        22, 23, 22, 21),
                                    child: SizedBox(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              vet['one_line_review'] ??
                                                  "한줄평이없어요",
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
                                                  strokeAlign: BorderSide
                                                      .strokeAlignCenter,
                                                  color: Color(0xFFCACED8),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Text(
                                              '${vet['hospital_name'] ?? '병원 정보 없음'} ㅣ ${vet['vet_name'] ?? '이름 정보 없음'}',
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
                              );
                            },
                          ),
          ),
        ),
      ),
    );
  }
}

import 'package:concrete_jaegaebal/model/review.dart';
import 'package:concrete_jaegaebal/view/s_cost_detail.dart';
import 'package:concrete_jaegaebal/view/s_login.dart';
import 'package:concrete_jaegaebal/view/s_review.dart';
import 'package:concrete_jaegaebal/viewmodel/vm_auth_state_provider.dart';
import 'package:concrete_jaegaebal/viewmodel/vm_review.dart';
import 'package:concrete_jaegaebal/viewmodel/vm_vet_hos_detail.dart';
import 'package:concrete_jaegaebal/viewmodel/vm_vet_info.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vertical_scrollable_tabview/vertical_scrollable_tabview.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class CardData {
  final String title;
  final String content;
  final String? bonus;
  final List<String>? reviews;
  final List<String>? more;
  final int? vetId;

  CardData({
    required this.title,
    required this.content,
    this.bonus,
    this.reviews,
    this.vetId,
    this.more,
  });
}

class Category {
  final String title;
  final List<CardData> cards;

  Category({
    required this.title,
    required this.cards,
  });
}

class HospitalDetailScreen extends StatefulWidget {
  const HospitalDetailScreen({super.key, required this.vetId});

  final int vetId;

  @override
  State<HospitalDetailScreen> createState() => _HospitalDetailScreenState();
}

class _HospitalDetailScreenState extends State<HospitalDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late AutoScrollController autoScrollController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    autoScrollController = AutoScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch veterinarian info and then fetch review data
    _fetchVetInfoAndReviews();
  }

  Future<void> _fetchVetInfoAndReviews() async {
    setState(() {
      _isLoading = true; // 로딩 시작
    });

    try {
      final vetInfoViewModel =
          Provider.of<VetInfoViewModel>(context, listen: false);
      final reviewModel = Provider.of<ReviewViewModel>(context, listen: false);

      // 수의사 정보가 이미 로드되었는지 확인
      if (!vetInfoViewModel.isDataLoaded ||
          vetInfoViewModel.selectedVet?.id != widget.vetId) {
        await vetInfoViewModel.fetchVetById(widget.vetId);
      }

      // 리뷰 데이터를 강제로 가져옴
      await Future.wait([
        reviewModel.fetchFilteredReviews(widget.vetId, "검사결과 및 처방"),
        reviewModel.fetchFilteredReviews(widget.vetId, "예후 및 기대수명"),
        reviewModel.fetchFilteredReviews(widget.vetId, "관리 및 케어방법"),
        reviewModel.fetchFilteredReviews(widget.vetId, "단계별 약 처방"),
      ]);
    } catch (error, stackTrace) {
      print("Error fetching data: $error");
      print("Stack trace: $stackTrace");
    } finally {
      setState(() {
        _isLoading = false; // 데이터 로드 완료 후 로딩 종료
      });
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    autoScrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToIndex(int index) async {
    await autoScrollController.scrollToIndex(index,
        preferPosition: AutoScrollPosition.begin);
    autoScrollController.highlight(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar를 커스터마이즈하여 최대 너비 560으로 제한하고 상단에 정렬
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 제거
        toolbarHeight: 58.0, // AppBar 높이 고정
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
                  child: Consumer<VetInfoViewModel>(
                    builder: (context, viewModel, child) {
                      return Text(
                        viewModel.selectedVet?.hospitalName ?? '',
                        style: const TextStyle(
                          color: Color(0xFF333D4B),
                          fontSize: 17,
                          fontFamily: 'PretendardDKTHK',
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center, // 중앙 정렬
                      );
                    },
                  ),
                ),
                // 제목 오른쪽에 10px 간격 추가
                const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      ),

      // Scaffold의 body 영역을 Align과 Container로 감싸 최대 너비 560으로 제한하고 상단에 정렬
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter, // 상단 정렬
            child: Container(
              constraints: const BoxConstraints(maxWidth: 560),
              width: double.infinity, // 화면 크기에 맞게 넓이 조정
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Consumer<VetInfoViewModel>(
                  builder: (context, viewModel, child) {
                    // 로딩 중일 때 로딩 표시
                    if (viewModel.isLoading) {
                      return const Center(child: Text(""));
                    }

                    // 에러 발생 시 에러 메시지 표시
                    if (viewModel.errorMessage != null) {
                      return Center(
                          child: Text('Error: ${viewModel.errorMessage}'));
                    }

                    // 수의사 정보가 없는 경우 처리
                    if (viewModel.selectedVet == null) {
                      return const Center(child: Text('수의사 정보를 불러오지 못했습니다.'));
                    }

                    final vetHosDetail = viewModel.selectedVet!;

                    final List<Category> dynamicData = [
                      Category(title: '진료성향', cards: [
                        CardData(
                          title: '검사결과 및 처방',
                          content:
                              vetHosDetail.examResultExplanation ?? '정보 없음',
                        ),
                        CardData(
                            title: '예후 및 기대수명',
                            content:
                                vetHosDetail.prognosisExplanation ?? '정보 없음'),
                        CardData(
                            title: '관리 및 케어방법',
                            content:
                                vetHosDetail.careMethodExplanation ?? '정보 없음'),
                        CardData(
                            title: '심장병 진단수치 방식',
                            content:
                                vetHosDetail.heartDiseaseDiagnosisMetrics ??
                                    '정보 없음'),
                        CardData(
                          title: '단계별 약 처방',
                          content:
                              vetHosDetail.heartDiseaseStageMedications != null
                                  ? [
                                      '${vetHosDetail.heartDiseaseStageMedications!.pill?.b1}',
                                      '${vetHosDetail.heartDiseaseStageMedications!.pill?.b2}',
                                      '${vetHosDetail.heartDiseaseStageMedications!.pill?.c}',
                                      '${vetHosDetail.heartDiseaseStageMedications!.pill?.pre}',
                                    ].join('\n')
                                  : '정보 없음',
                        ),
                      ]),
                      Category(
                        title: '병원정보',
                        cards: [
                          CardData(
                            title: '(초진) 기본 검사 항목/비용',
                            content: vetHosDetail.initialCost != null
                                ? (vetHosDetail.initialCost!.details
                                        as List<dynamic>)
                                    .join(', ')
                                : '정보 없음',
                            vetId: widget.vetId,
                          ),
                          CardData(
                              title: '병원 위치',
                              content: vetHosDetail.hospitalAddress ?? '정보 없음'),
                          CardData(
                              title: '주차 환경',
                              content: vetHosDetail.parking ?? '정보 없음'),
                          CardData(
                            title: '진료 시간',
                            content: vetHosDetail.officeHours != null
                                ? vetHosDetail.officeHours!.getFormattedHours()
                                : '정보 없음',
                          ),
                          CardData(
                            title: '진료 상담 시간',
                            content: vetHosDetail.examTime != null
                                ? vetHosDetail.examTime!
                                : '정보 없음',
                          ),
                          CardData(
                            title: '초진 예약 후 대기기간',
                            content:
                                vetHosDetail.initialReservationWaitTime != null
                                    ? vetHosDetail.initialReservationWaitTime!
                                    : '정보 없음',
                          ),
                          CardData(
                            title: '수의사 유선 상담',
                            content: vetHosDetail.teleConsultation != null
                                ? vetHosDetail.teleConsultation!
                                : '정보 없음',
                          ),
                          CardData(
                            title: '영상 의학 수의사',
                            content: (vetHosDetail.radiologist != null &&
                                    vetHosDetail.radiologist!.radiologist !=
                                        null &&
                                    vetHosDetail
                                        .radiologist!.radiologist!.isNotEmpty)
                                ? vetHosDetail.radiologist!.radiologist!
                                    .join(', \n')
                                : '정보 없음',
                          ),
                          CardData(
                            title: '주요 보유 장비',
                            content: (vetHosDetail.keyEquipment != null &&
                                    vetHosDetail.keyEquipment!.equip.isNotEmpty)
                                ? vetHosDetail.keyEquipment!.equip.join(', \n')
                                : '정보 없음',
                            vetId: widget.vetId,
                          )
                        ],
                      ),
                      Category(title: '수의사정보', cards: [
                        CardData(
                          title: '학력 및 경력',
                          content: vetHosDetail.education
                                  ?.split('\r\n')
                                  .map((item) => item.trim())
                                  .where((item) => item.isNotEmpty)
                                  .join('\n') ??
                              '정보 없음',
                        ),
                        CardData(
                            title: '학술활동',
                            content:
                                vetHosDetail.researchActivities ?? "데이터 수집중"),
                        CardData(
                            title: '교직활동',
                            content:
                                vetHosDetail.teachingActivities ?? "데이터 수집중"),
                        CardData(
                          title: '자격',
                          content: vetHosDetail.qualification ?? '데이터 수집중',
                        ),
                      ]),
                    ];

                    return VerticalScrollableTabView(
                      autoScrollController: autoScrollController,
                      scrollbarThumbVisibility: false,
                      tabController: tabController,
                      listItemData: dynamicData,
                      verticalScrollPosition: VerticalScrollPosition.begin,
                      eachItemChild: (object, index) => AutoScrollTag(
                        key: ValueKey(index),
                        index: index,
                        controller: autoScrollController,
                        child: CategorySection(
                          category: object as Category,
                          vetId: widget.vetId,
                        ),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start, // 왼쪽 정렬
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 26, top: 37),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 38,
                                      child: CircleAvatar(
                                        radius: 38,
                                        foregroundImage: vetHosDetail
                                                        .vetImageUrl !=
                                                    null &&
                                                vetHosDetail
                                                    .vetImageUrl!.isNotEmpty
                                            ? NetworkImage(
                                                vetHosDetail.vetImageUrl!)
                                            : const AssetImage(
                                                    'assets/images/default_vet_image.png')
                                                as ImageProvider,
                                      ),
                                    ),
                                    const SizedBox(width: 33),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: vetHosDetail.vetName,
                                                style: const TextStyle(
                                                  color: Color(0xFF333D4B),
                                                  fontSize: 17,
                                                  fontFamily: 'PretendardDKTHK',
                                                  fontWeight: FontWeight.w700,
                                                  height: 1.5,
                                                ),
                                              ),
                                              const TextSpan(
                                                text: ' ', // 간격을 주기 위한 공백 추가
                                              ),
                                              TextSpan(
                                                text: vetHosDetail.vetRole,
                                                style: const TextStyle(
                                                  color: Color(0xFF333D4B),
                                                  fontSize: 17,
                                                  fontFamily: 'PretendardDKTHK',
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          '주요 진료과목',
                                          style: TextStyle(
                                            color: Color(0xFF333D4B),
                                            fontSize: 14,
                                            fontFamily: 'PretendardDKTHK',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          vetHosDetail.mainMedicalSubjects ??
                                              "아직 준비중입니다!",
                                          style: const TextStyle(
                                            color: Color(0xFF333D4B),
                                            fontSize: 14,
                                            fontFamily: 'PretendardDKTHK',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 33),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Card(
                                      color: const Color(0xFFF2F4F7),
                                      elevation: 0,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 17,
                                            top: 12,
                                            bottom: 15,
                                            right: 17),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '진료 스타일',
                                              style: TextStyle(
                                                color: Color(0xFF066AE5),
                                                fontSize: 15,
                                                fontFamily: 'PretendardDKTHK',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              vetHosDetail.oneLineReview ??
                                                  "아직 준비중입니다!",
                                              style: const TextStyle(
                                                color: Color(0xFF333D4B),
                                                fontSize: 15,
                                                fontFamily: 'PretendardDKTHK',
                                                fontWeight: FontWeight.w700,
                                                height: 1.45,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 47),
                            ],
                          ),
                        ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _SliverAppBarDelegate(
                            TabBar(
                              controller: tabController,
                              indicator: const UnderlineTabIndicator(
                                borderSide: BorderSide(
                                  width: 3.5,
                                  color: Color(0xFF333D4B),
                                ),
                                insets: EdgeInsets.only(right: 90, left: 90),
                              ),
                              labelStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'PretendardDKTHK',
                                color: Color(0xFF333D4B),
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                fontFamily: 'PretendardDKTHK',
                                color: Color(0xFF808799),
                              ),
                              unselectedLabelColor: const Color(0xFF333D4B),
                              labelPadding: const EdgeInsets.only(bottom: 9),
                              tabs: dynamicData
                                  .map((e) => Tab(text: e.title))
                                  .toList(),
                              onTap: (index) {
                                _scrollToIndex(index);
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54, // 배경을 어둡게
              child: const Center(
                child: CircularProgressIndicator(), // 로딩 스피너
              ),
            ),
        ],
      ),
    );
  }
}

class CategorySection extends StatelessWidget {
  final Category category;
  final int vetId;

  const CategorySection(
      {super.key, required this.category, required this.vetId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              ...category.cards.map(
                  (cardData) => _buildCardContent(context, cardData, vetId)),
              const SizedBox(height: 30),
            ],
          ),
        ),
        Container(
          height: 12,
          color: const Color(0xFFF3F4F6),
        ),
      ],
    );
  }

  Widget _buildCardContent(BuildContext context, CardData cardData, int vetId) {
    switch (cardData.title) {
      case '검사결과 및 처방':
      case '예후 및 기대수명':
      case '관리 및 케어방법':
        return _buildReviewCard(context, cardData, vetId);
      case '(초진) 기본 검사 항목/비용':
        return _buildChojinCard(context, cardData, vetId);
      case '단계별 약 처방':
        return _buildPrescriptionTable(context, cardData);
      case '진료 시간':
        return _buildOfficeHoursTable(context, cardData);
      default:
        return _buildDefaultCardContent(context, cardData, vetId);
    }
  }

  Widget _buildReviewCard(BuildContext context, CardData cardData, int vetId) {
    final reviewModel = Provider.of<ReviewViewModel>(context);
    String vetExplanationType = cardData.title;
    final reviewCount = reviewModel.getReviewCountByType(vetExplanationType);
    final authState = Provider.of<AuthStateProviderViewModel>(context);

    return FutureBuilder(
      future: authState.checkSurveyStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text(""));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('오류 발생: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final isSurveyCompleted = snapshot.data ?? false;

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 40.0),
            child: Card(
              color: Colors.white,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0)),
                side: BorderSide.none,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cardData.title,
                      style: const TextStyle(
                        fontFamily: 'PretendardDKTHK',
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cardData.content,
                      style: const TextStyle(
                        color: Color(0xFF434956),
                        fontSize: 15,
                        fontFamily: 'PretendardDKTHK',
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 1),
                    if (reviewCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: GestureDetector(
                            onTap: () async {
                              if (isSurveyCompleted) {
                                final reviews = reviewModel
                                    .getReviewsByType(cardData.title);
                                navigateToReviewScreen(
                                  context,
                                  sendingTitle: cardData.title,
                                  vetId: vetId,
                                  title: '${cardData.title} 진료 후기',
                                );
                              } else {
                                bool? loginSuccess = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(
                                      vetId: vetId,
                                      title: cardData.title,
                                    ),
                                    fullscreenDialog: true,
                                  ),
                                );

                                if (loginSuccess == true) {
                                  Provider.of<AuthStateProviderViewModel>(
                                    context,
                                    listen: false,
                                  ).completeSurvey();

                                  final reviews = reviewModel
                                      .getReviewsByType(cardData.title);
                                  navigateToReviewScreen(
                                    context,
                                    sendingTitle: cardData.title,
                                    vetId: vetId,
                                    title: '${cardData.title} 진료 후기',
                                  );
                                } else {
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   const SnackBar(content: Text('')),
                                  // );
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 1.0),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFF006AE5),
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: Text(
                                '진료 후기: $reviewCount개',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF006AE5),
                                  // TextDecoration 관련 속성은 제거합니다.
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        return const Center(child: Text('설문조사 상태를 확인할 수 없습니다.'));
      },
    );
  }

  Widget _buildChojinCard(BuildContext context, CardData cardData, int? vetId) {
    final reviewModel = Provider.of<ReviewViewModel>(context);
    final authState = Provider.of<AuthStateProviderViewModel>(context);
    String vetExplanationType = cardData.title;
    final reviewCount = reviewModel.getReviewCountByType(vetExplanationType);

    List<String> chojinFields = cardData.content.split(', ');

    bool isExpanded = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return FutureBuilder(
          future: authState.checkSurveyStatus(), // 설문조사 상태 확인
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Text(""));
            }

            if (snapshot.hasError) {
              return Center(child: Text('오류 발생: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              final isSurveyCompleted = snapshot.data ?? false;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cardData.title,
                      style: const TextStyle(
                        fontFamily: 'PretendardDKTHK',
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        color: const Color(0xFFF5F7F9),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide.none,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 23, right: 39, top: 21, bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(1),
                                  1: FlexColumnWidth(0.8),
                                },
                                children:
                                    _buildTableRows(chojinFields, isExpanded),
                              ),
                              const SizedBox(height: 5),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () async {
                          if (isSurveyCompleted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CostDetailScreen(
                                    vetId: cardData.vetId,
                                    reviewCount: reviewCount),
                              ),
                            );
                          } else {
                            bool? loginSuccess = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(
                                    vetId: vetId, title: cardData.title),
                                fullscreenDialog: true,
                              ),
                            );

                            if (loginSuccess == true) {
                              authState.completeSurvey();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CostDetailScreen(
                                      vetId: cardData.vetId,
                                      reviewCount: reviewCount),
                                ),
                              );
                            } else {
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   const SnackBar(content: Text('')),
                              // );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 1.0),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFF006AE5),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: const Text(
                            "비용 자세히보기",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF006AE5),
                              // TextDecoration 관련 속성은 제거됩니다.
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (reviewCount > 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () async {
                            bool? loginSuccess = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(
                                    vetId: vetId, title: cardData.title),
                                fullscreenDialog: true,
                              ),
                            );

                            if (loginSuccess == true) {
                              final reviews =
                                  reviewModel.getReviewsByType(cardData.title);
                              navigateToReviewScreen(
                                context,
                                vetId: vetId!,
                                sendingTitle: cardData.title,
                                reviewCount: reviewCount,
                                title: '${cardData.title} 진료 후기',
                              );
                            } else {
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   const SnackBar(content: Text('')),
                              // );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 1.0),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFF006AE5),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Text(
                              '진료 후기: $reviewCount개',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF006AE5),
                                // TextDecoration 관련 속성은 제거됩니다.
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }

            return const Center(child: Text('설문조사 상태를 확인할 수 없습니다.'));
          },
        );
      },
    );
  }

  List<TableRow> _buildTableRows(List<String> fields, bool isExpanded) {
    List<TableRow> rows = [];

    int limit =
        isExpanded ? fields.length : (fields.length > 4 ? 4 : fields.length);

    for (int i = 0; i < limit; i += 2) {
      rows.add(
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                fields[i],
                style: const TextStyle(
                  fontFamily: 'PretendardDKTHK',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF434956),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                i + 1 < fields.length ? fields[i + 1] : '',
                style: const TextStyle(
                  fontFamily: 'PretendardDKTHK',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF434956),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return rows;
  }

  Widget _buildPrescriptionTable(BuildContext context, CardData cardData) {
    final reviewModel = Provider.of<ReviewViewModel>(context);
    String vetExplanationType = cardData.title;
    final reviewCount = reviewModel.getReviewCountByType(vetExplanationType);

    List<String> prescriptionSteps = cardData.content.split('\n');
    bool isExpanded = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cardData.title,
                style: const TextStyle(
                  fontFamily: 'PretendardDKTHK',
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),

              const SizedBox(height: 8), // 간격 추가
              const Text(
                '-24년 평균 기준 자료\n-아이 상태 및 단계별 검사에 따라 상이',
                style: TextStyle(
                  fontFamily: 'PretendardDKTHK',
                  fontSize: 15,
                  fontWeight: FontWeight.w400, // w350이 없으므로 w400으로 사용
                  height: 1.448, // line-height: 21.72 / font-size: 15 ≈ 1.448
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: const Color(0xFFF5F7F9),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                    side: BorderSide.none,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 19),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Table(
                          border: const TableBorder(
                            verticalInside: BorderSide(color: Colors.black26),
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(3),
                          },
                          children: _buildPrescriptionRows(
                              prescriptionSteps, isExpanded),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 1.0),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF006AE5),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Text(
                      isExpanded ? '접기' : '더보기',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF006AE5),
                        // TextDecoration 관련 속성은 제거됩니다.
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (reviewCount > 0)
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      final reviews =
                          reviewModel.getReviewsByType(cardData.title);
                      navigateToReviewScreen(
                        context,
                        vetId: vetId,
                        sendingTitle: cardData.title,
                        title: '${cardData.title} 진료 후기',
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 1.0),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF006AE5),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Text(
                        '진료 후기: $reviewCount개',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF006AE5),
                          // TextDecoration 관련 속성은 제거됩니다.
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<TableRow> _buildPrescriptionRows(List<String> steps, bool isExpanded) {
    List<TableRow> rows = [];

    int limit =
        isExpanded ? steps.length : (steps.length > 2 ? 2 : steps.length);

    for (int i = 0; i < limit; i++) {
      String stageName;
      if (i == 0) {
        stageName = 'B1 단계';
      } else if (i == 1) {
        stageName = 'B2 단계';
      } else if (i == 2) {
        stageName = 'C 단계';
      } else {
        stageName = '처방전 발급';
      }

      rows.add(
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                stageName,
                style: const TextStyle(
                  fontFamily: 'PretendardDKTHK',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF479DFF),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
              child: Text(
                steps[i],
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontFamily: 'PretendardDKTHK',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF434956),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return rows;
  }

  Widget _buildDefaultCardContent(
      BuildContext context, CardData cardData, int vetId) {
    bool isExpanded = false;
    final authState = Provider.of<AuthStateProviderViewModel>(context);

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 40.0),
          child: Card(
            color: Colors.white,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0)),
              side: BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cardData.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // RichText와 TextSpan을 사용하여 텍스트와 더보기 배치
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // 본문 텍스트 스타일 정의
                      const TextStyle textStyle = TextStyle(
                        color: Color(0xFF434956),
                        fontSize: 15,
                        fontFamily: 'PretendardDKTHK',
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      );

                      // 전체 텍스트 Span 생성
                      final textSpan = TextSpan(
                        text: cardData.content,
                        style: textStyle,
                      );

                      // TextPainter를 사용하여 텍스트 레이아웃 정보 얻기
                      final textPainter = TextPainter(
                        text: textSpan,
                        maxLines: isExpanded ? null : 3,
                        textDirection: TextDirection.ltr,
                      );

                      textPainter.layout(maxWidth: constraints.maxWidth);

                      // 텍스트가 3줄을 초과하고 확장되지 않은 경우 처리
                      if (textPainter.didExceedMaxLines && !isExpanded) {
                        // '...더보기' Span 생성
                        const String moreText = '...더보기';
                        final moreSpan = TextSpan(
                          text: moreText,
                          style: textStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF434956),
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              // 설문조사 완료 여부 확인
                              if (await authState.checkSurveyStatus()) {
                                setState(() {
                                  isExpanded = true; // 확장 상태로 전환
                                });
                              } else {
                                // 로그인 화면으로 이동 후 설문조사 완료하면 돌아오게 설정
                                bool? loginSuccess = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(
                                      vetId: vetId,
                                      title: cardData.title,
                                    ),
                                    fullscreenDialog: true,
                                  ),
                                );

                                if (loginSuccess == true) {
                                  // 설문조사 완료 처리 후 "더보기" 적용
                                  authState.completeSurvey();
                                  setState(() {
                                    isExpanded = true; // 확장 상태로 전환
                                  });
                                } else {
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   const SnackBar(content: Text('')),
                                  // );
                                }
                              }
                            },
                        );

                        // '...더보기'의 너비 계산
                        final morePainter = TextPainter(
                          text: moreSpan,
                          textDirection: TextDirection.ltr,
                        );
                        morePainter.layout(maxWidth: constraints.maxWidth);

                        // 3번째 줄의 끝에서부터 '...더보기'를 추가해도 3줄을 넘지 않도록 텍스트를 자르기
                        int endIndex = textPainter
                            .getPositionForOffset(
                              Offset(
                                constraints.maxWidth,
                                textPainter.preferredLineHeight * 3,
                              ),
                            )
                            .offset;

                        int adjustedEndIndex = endIndex;
                        while (adjustedEndIndex > 0) {
                          final testSpan = TextSpan(
                            text: cardData.content
                                    .substring(0, adjustedEndIndex) +
                                moreText,
                            style: textStyle,
                          );
                          final testPainter = TextPainter(
                            text: testSpan,
                            maxLines: 3,
                            textDirection: TextDirection.ltr,
                          );
                          testPainter.layout(maxWidth: constraints.maxWidth);

                          if (testPainter.didExceedMaxLines) {
                            adjustedEndIndex--;
                          } else {
                            break;
                          }
                        }

                        // 최종 텍스트 Span 생성
                        final displayTextSpan = TextSpan(
                          text: cardData.content.substring(0, adjustedEndIndex),
                          style: textStyle,
                          children: [
                            moreSpan,
                          ],
                        );

                        return RichText(
                          text: displayTextSpan,
                        );
                      } else {
                        // 텍스트가 3줄 이하거나 확장된 경우 전체 텍스트 표시
                        return RichText(
                          text: TextSpan(
                            text: cardData.content,
                            style: textStyle,
                            children: isExpanded
                                ? [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.baseline,
                                      baseline: TextBaseline.alphabetic,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isExpanded = false; // 다시 접힘 상태로 전환
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              bottom: 1.0),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Color(0xFF006AE5),
                                                width: 1.0,
                                              ),
                                            ),
                                          ),
                                          child: const Text(
                                            ' 접기',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Color(0xFF006AE5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                                : null,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void navigateToReviewScreen(BuildContext context,
      {required String title,
      required int vetId,
      required String sendingTitle,
      int? reviewCount}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewScreen(
          vetId: vetId,
          title: sendingTitle,
          reviewCount: reviewCount,
        ),
      ),
    );
  }
}

Widget _buildOfficeHoursTable(BuildContext context, CardData cardData) {
  Map<String, String> allDays = {
    '월': '정보 없음',
    '화': '정보 없음',
    '수': '정보 없음',
    '목': '정보 없음',
    '금': '정보 없음',
    '토': '정보 없음',
    '일': '정보 없음',
  };

  List<String> lines = cardData.content.split('\n');

  for (String line in lines) {
    List<String> parts = line.split(': ');
    if (parts.length == 2 && allDays.containsKey(parts[0].trim())) {
      allDays[parts[0].trim()] = parts[1].trim();
    }
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cardData.title,
          style: const TextStyle(
            fontFamily: 'PretendardDKTHK',
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Card(
            color: const Color(0xFFF5F7F9),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
              side: BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 19),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Table(
                    border: const TableBorder(
                      verticalInside: BorderSide(color: Colors.black26),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(3),
                    },
                    children: allDays.entries.map((entry) {
                      // 오른쪽 열 텍스트 스타일 정의
                      TextStyle textStyle = const TextStyle(
                        fontFamily: 'PretendardDKTHK',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF434956),
                      );

                      // 왼쪽 열(요일) 텍스트 스타일 정의
                      TextStyle dayTextStyle = const TextStyle(
                        fontFamily: 'PretendardDKTHK',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF479DFF), // 기본 색상 (토요일 색상)
                      );

                      // 요일에 따라 왼쪽 열 색상 조정
                      if (entry.key == '월' ||
                          entry.key == '화' ||
                          entry.key == '수' ||
                          entry.key == '목' ||
                          entry.key == '금') {
                        dayTextStyle = dayTextStyle.copyWith(
                            color: const Color(0xFF434956));
                      } else if (entry.key == '일') {
                        dayTextStyle = dayTextStyle.copyWith(
                            color: const Color(0xFFF04452));
                      }
                      // 토요일은 기본 색상 유지 (Color(0xFF479DFF))

                      // 데이터가 '휴무'인 경우 오른쪽 텍스트 색상 변경 및 왼쪽 열 색상도 빨간색으로 변경
                      if (entry.value == '휴무') {
                        textStyle =
                            textStyle.copyWith(color: const Color(0xFFF04452));
                        dayTextStyle = dayTextStyle.copyWith(
                            color: const Color(0xFFF04452));
                      }

                      // 토요일의 시간에 해당하는 오른쪽 열의 텍스트 색상을 파란색으로 변경
                      if (entry.key == '토') {
                        textStyle =
                            textStyle.copyWith(color: const Color(0xFF479DFF));
                      }

                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Text(
                              '${entry.key}요일',
                              style: dayTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            child: Text(
                              entry.value.isNotEmpty ? entry.value : '정보 없음',
                              textAlign: TextAlign.center,
                              style: textStyle,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

import 'package:concrete_jaegaebal/view/s_no_data.dart';
import 'package:concrete_jaegaebal/viewmodel/vm_vet_info.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Future<void> gaEvent(String eventName, Map<String, dynamic> eventParams) async {
//   // Map<String, dynamic>을 Map<String, Object>로 변환
//   final params =
//       eventParams.map((key, value) => MapEntry(key, value as Object));

//   await FirebaseAnalytics.instance.logEvent(
//     name: eventName,
//     parameters: params,
//   );
// }

class CostDetailScreen extends StatefulWidget {
  final int? vetId;
  final int? reviewCount;

  const CostDetailScreen({super.key, required this.vetId, this.reviewCount});

  @override
  State<CostDetailScreen> createState() => _CostDetailScreenState();
}

class _CostDetailScreenState extends State<CostDetailScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(
      () {
        final viewModel = Provider.of<VetInfoViewModel>(context, listen: false);
        viewModel.fetchVetById(widget.vetId!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<VetInfoViewModel>(context);
    final vetHosDetail = viewModel.selectedVet;

    // initialCostMore와 그 안의 cost 데이터를 Map<String, String>으로 변환
    Map<String, String>? costData =
        vetHosDetail?.initialCostMore?.cost?.cast<String, String>();

    // 만약 costData가 null이면 빈 테이블을 출력
    costData ??= {};

    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

    Future<void> logCostMoreDetailEvent(int vetIdLog) async {
      await analytics.logEvent(
        name: 'hos_cost_more_detail',
        parameters: <String, Object>{
          'vetID': vetIdLog,
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '비용 자세히 보기',
          style: TextStyle(
            color: Color(0xFF333D4B),
            fontSize: 17,
            fontFamily: 'NotoSPretendardDKTHKansKR',
            fontWeight: FontWeight.w700,
            height: 0,
          ),
        ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 34), // Space below AppBar
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min, // Centers the row horizontally
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7F9),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: 33, left: 29, top: 11, bottom: 12),
                      child: Row(children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5, right: 20),
                          child: SizedBox(
                            width: 17,
                            height: 17,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 17,
                                  height: 17,
                                  decoration: const ShapeDecoration(
                                    color: Color(0xFFF04452),
                                    shape: OvalBorder(),
                                  ),
                                ),
                                const Text(
                                  'i',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontFamily: 'PretendardDKTHK',
                                    fontWeight: FontWeight.w700,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Text(
                          '- 24년 평균 초진 검사 및 비용 자료\n- 환축 상태 및 단계별 검사 항목 상이',
                          style: TextStyle(
                            color: Color(0xFF6B7684),
                            fontSize: 15,
                            fontFamily: 'PretendardDKTHK',
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 34), // Space between sections
            _buildCostList(costData), // 비용 테이블 표시
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 30.0, top: 0),
                child: GestureDetector(
                  onTap: () {
                    // print("영수증자세히보기");
                    logCostMoreDetailEvent(widget.vetId!);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NoDataScreen()),
                    );
                  },
                  child: const Text(
                    '영수증 자세히보기',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF006AE5),
                      decoration: TextDecoration.underline,
                      decorationThickness: 2.0,
                      decorationColor: Color(0xFF006AE5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostList(Map<String, String> costData) {
    String? totalAmount;
    Map<String, String> remainingItems = {};

    // Separate '합계' item from others
    costData.forEach((key, value) {
      if (key == '합계') {
        totalAmount = value;
      } else {
        remainingItems[key] = value;
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 항목과 비용을 리스트로 표시
          ListView.builder(
            physics:
                const NeverScrollableScrollPhysics(), // ListView 자체의 스크롤을 막고 외부 스크롤을 사용
            shrinkWrap: true,
            itemCount: remainingItems.length + 1, // 마지막 합계 항목 포함
            itemBuilder: (context, index) {
              if (index == remainingItems.length) {
                // 마지막 항목, 합계 표시
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7F9),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(color: const Color(0xFFF5F7F9)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 17),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        '합계  ',
                        style: TextStyle(
                          fontFamily: 'PretendardDKTHK',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFFF04452),
                        ),
                      ),
                      Text(
                        totalAmount ?? '0', // 합계가 없을 경우 0으로 표시
                        style: const TextStyle(
                          fontFamily: 'PretendardDKTHK',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFFF04452),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                );
              } else {
                String key = remainingItems.keys.elementAt(index);
                String value = remainingItems[key]!;

                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7F9),
                    borderRadius: index == 0
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          )
                        : BorderRadius.zero, // 첫 번째 항목에만 상단 둥근 모서리 적용
                    border: Border.all(color: const Color(0xFFF5F7F9)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                  // margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        key, // 항목 이름
                        style: const TextStyle(
                          fontFamily: 'PretendardDKTHK',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Color(0xFF333D4B),
                        ),
                      ),
                      Text(
                        value, // 항목 비용
                        style: const TextStyle(
                          fontFamily: 'NotoPretendardDKTHKSansKR',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Color(0xFF333D4B),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

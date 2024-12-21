import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/review.dart';

class ReviewRepository {
  final String baseUrl;

  ReviewRepository({required this.baseUrl});

  // 설명 타입을 영문 키로 변환하는 맵
  Map<String, String> explanationTypeMap = {
    '검사결과 및 처방': 'a',
    '예후 및 기대수명': 'b',
    '관리 및 케어방법': 'c',
  };

  Future<List<Review>> fetchFilteredReviews(
      int vetId, String explanationType) async {
    // 설명 타입을 영문 키로 변환
    String explanationKey =
        explanationTypeMap[explanationType] ?? explanationType;

    final url = '$baseUrl$vetId/$explanationKey/';

    // HTTP 요청 보내기
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // 응답 데이터를 UTF-8로 디코딩하여 JSON 파싱
      final data = jsonDecode(utf8.decode(response.bodyBytes)); // UTF-8 디코딩 추가
      return (data as List).map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reviews');
    }
  }
}

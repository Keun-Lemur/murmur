import 'package:dio/dio.dart';
import 'package:concrete_jaegaebal/model/people_list.dart';

class PeopleListRepository {
  final String albumUrl = "https://b1b2cd.up.railway.app/people-list/";

  Future<List<PeopleList>> fetchPeopleList(int albumId) async {
    final String url = "$albumUrl$albumId/"; // albumId를 사용하여 URL 생성
    try {
      final response = await Dio().get(url);

      // 서버로부터 받은 데이터를 리스트로 변환
      List<dynamic> jsonData = response.data;
      return jsonData.map((json) => PeopleList.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Failed to load people list: $e");
    }
  }
}

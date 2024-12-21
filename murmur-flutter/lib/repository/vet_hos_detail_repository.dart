import 'package:concrete_jaegaebal/model/vet_hos_detail_info.dart';
import 'package:concrete_jaegaebal/model/vet_info.dart';
import 'package:dio/dio.dart';

class VetHosDetailRepository {
  final String vetHosInfoUrl = "https://b1b2cd.up.railway.app/vets/";

  // 특정 vetId에 대한 VetHosInfoDetail 데이터를 가져오는 메서드
  Future<VetInfo> fetchVetHosInfoDetail(int vetId) async {
    final String url = "$vetHosInfoUrl$vetId"; // vetId를 사용하여 URL 생성
    try {
      final response = await Dio().get(url);

      // 서버로부터 받은 데이터를 VetHosInfoDetail 객체로 변환
      return VetInfo.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to load vet and hospital info: $e");
    }
  }
}

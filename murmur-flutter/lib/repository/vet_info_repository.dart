// repositories/vet_info_repository.dart

import 'package:concrete_jaegaebal/model/vet_info.dart';
import 'package:dio/dio.dart';

class VetInfoRepository {
  final String vetInfoUrl = "https://b1b2cd.up.railway.app/vets/";

  // 여러 Vet 데이터를 리스트로 가져오는 메서드
  Future<List<VetInfo>> fetchVets() async {
    try {
      final response = await Dio().get(vetInfoUrl);

      List<dynamic> jsonData = response.data; // 서버에서 데이터를 리스트로 받음
      return jsonData
          .map((json) => VetInfo.fromJson(json))
          .toList(); // 리스트의 각 항목을 Vet 객체로 변환
    } catch (e) {
      throw Exception("Failed to load vets: $e");
    }
  }

  // 특정 Vet 데이터를 가져오는 메서드
  Future<VetInfo> fetchVetById(int id) async {
    try {
      final response = await Dio().get('$vetInfoUrl$id/');
      Map<String, dynamic> jsonData = response.data;
      print(jsonData);
      print("Radiologist Data: ${jsonData['radiologist']}");
      return VetInfo.fromJson(jsonData);
    } catch (e) {
      throw Exception("Failed to load vet: $e");
    }
  }
}

// services/vet_info_service.dart

import 'package:concrete_jaegaebal/repository/vet_info_repository.dart';
import '../model/vet_info.dart';

class VetInfoService {
  final VetInfoRepository _vetInfoRepository = VetInfoRepository();

  Future<List<VetInfo>> getAllVets() async {
    return await _vetInfoRepository.fetchVets();
  }

  Future<VetInfo> getVetById(int id) async {
    return await _vetInfoRepository.fetchVetById(id);
  }
}

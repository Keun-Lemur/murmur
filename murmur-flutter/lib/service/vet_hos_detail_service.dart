import 'package:concrete_jaegaebal/model/vet_hos_detail_info.dart';
import 'package:concrete_jaegaebal/model/vet_info.dart';
import 'package:concrete_jaegaebal/repository/%08vet_hos_detail_repository.dart';

class VetHosDetailService {
  final VetHosDetailRepository _repository = VetHosDetailRepository();

  // 특정 ID의 VetHosInfoDetail 데이터를 가져오는 메서드
  Future<VetInfo> getVetHosInfoDetail(int vetId) async {
    return await _repository.fetchVetHosInfoDetail(vetId);
  }
}

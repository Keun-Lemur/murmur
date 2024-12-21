import 'package:concrete_jaegaebal/model/people_list.dart';
import 'package:concrete_jaegaebal/repository/people_list_repository.dart';

class PeopleListService {
  final PeopleListRepository _repository = PeopleListRepository();

  // 앨범 제목을 받아서 리스트 데이터를 가져오는 메서드
  Future<List<PeopleList>> getPeopleList(int albumId) async {
    return await _repository.fetchPeopleList(albumId);
  }
}

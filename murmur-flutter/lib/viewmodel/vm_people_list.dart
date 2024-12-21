import 'package:flutter/material.dart';
import 'package:concrete_jaegaebal/service/people_list_service.dart';
import 'package:concrete_jaegaebal/model/people_list.dart';

class PeopleListViewModel extends ChangeNotifier {
  final PeopleListService _peopleListService = PeopleListService();

  List<PeopleList> _peopleList = []; // 리스트로 데이터 관리
  List<PeopleList> get peopleList => _peopleList; // 외부에서 접근 가능

  bool _isLoading = false; // 로딩 상태
  bool get isLoading => _isLoading;

  String? _errorMessage; // 에러 메시지
  String? get errorMessage => _errorMessage;

  // 앨범 ID를 받아 데이터를 가져오는 메서드
  Future<void> fetchPeopleList(int albumId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _peopleList =
          await _peopleListService.getPeopleList(albumId); // 리스트로 데이터 로딩
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Error fetching people list: $e";
      // print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

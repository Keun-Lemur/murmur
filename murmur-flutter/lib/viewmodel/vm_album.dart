import 'package:flutter/material.dart';
import 'package:concrete_jaegaebal/service/album_service.dart';
import 'package:concrete_jaegaebal/model/album.dart';

//TODO 다시 확인 필요.
class AlbumViewModel extends ChangeNotifier {
  final AlbumService _albumService = AlbumService();

  List<Album> _albums = []; // 앨범 리스트 관리
  List<Album> get albums => _albums; // 외부에서 접근 가능하게 함

  bool _isLoading = false; // 로딩 상태
  bool get isLoading => _isLoading;

  String? _errorMessage; // 에러 메시지
  String? get errorMessage => _errorMessage;

  // 앨범 리스트를 가져오는 메서드
  Future<void> fetchAlbums() async {
    _isLoading = true; // 로딩 상태 시작
    _errorMessage = null; // 에러 메시지 초기화
    notifyListeners(); // 상태 변화 알림

    try {
      _albums = (await _albumService.fetchAlbums()); // 여러 앨범 데이터를 서비스에서 가져옴
      // print('Albums loaded: ${_albums.length}');
      _errorMessage = null; // 성공 시 에러 메시지 null로 설정
    } catch (e) {
      _errorMessage = "Error fetching albums: $e"; // 에러 발생 시 처리
    } finally {
      _isLoading = false; // 로딩 완료
      notifyListeners(); // 상태 변화 알림
    }
  }
}

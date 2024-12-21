import 'dart:developer';
import 'package:concrete_jaegaebal/model/album.dart';
import 'package:concrete_jaegaebal/repository/album_repository.dart';

class AlbumService {
  final AlbumRepository _albumRepository = AlbumRepository();

  // 여러 앨범 데이터를 가져옴
  Future<List<Album>> fetchAlbums() async {
    try {
      final albums = await _albumRepository.fetchAlbums();

      return await _albumRepository.fetchAlbums(); // 앨범 리스트 가져오기
    } catch (e, s) {
      log('Error fetching albums: $e, $s');
      rethrow;
    }
  }
}

import 'package:concrete_jaegaebal/model/album.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class AlbumRepository {
  final String albumUrl = "https://b1b2cd.up.railway.app/albums/";

  Future<List<Album>> fetchAlbums() async {
    try {
      final response = await Dio().get(
        albumUrl,
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode == 200) {
        String responseBody = response.data;
        List<dynamic> jsonData = jsonDecode(responseBody);

        return jsonData.map((item) {
          if (item is Map<String, dynamic>) {
            return Album.fromJson(item);
          } else {
            throw Exception("Unexpected item type: ${item.runtimeType}");
          }
        }).toList();
      } else {
        throw Exception('Failed to load albums: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("Failed to load albums: $e");
    }
  }
}

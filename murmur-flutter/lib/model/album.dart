import 'package:concrete_jaegaebal/model/vet_info.dart';

class Album {
  final int id;
  final String albumTitle;
  final String? albumSubtitle;
  final String? albumImage;
  final List<VetInfo> vets;

  Album({
    required this.id,
    required this.albumTitle,
    this.albumSubtitle,
    this.albumImage,
    required this.vets,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    var vetList = json['vet'] as List;
    List<VetInfo> vets =
        vetList.map((vetJson) => VetInfo.fromJson(vetJson)).toList();

    return Album(
      id: json['id'],
      albumTitle: json['album_title'],
      albumSubtitle: json['album_subtitle'],
      albumImage: json['album_image'],
      vets: vets,
    );
  }
}

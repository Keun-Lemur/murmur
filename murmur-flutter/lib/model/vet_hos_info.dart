class VetHosInfo {
  final int id;
  final String albumTitle;
  final String? albumImage; // null 허용

  const VetHosInfo({
    required this.id,
    required this.albumTitle,
    this.albumImage, // nullable 필드
  });

  factory VetHosInfo.fromJson(Map<String, dynamic> json) {
    return VetHosInfo(
      id: json["id"],
      albumTitle: json["album_title"],
      albumImage: json["album_image"] ?? 'default_image.png', // 기본 이미지 제공
    );
  }
}

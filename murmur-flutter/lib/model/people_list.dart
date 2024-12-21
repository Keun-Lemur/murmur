class PeopleList {
  final int id;
  final String hos;
  final String vet;
  final String oneLineReview;
  final String vetImageUrl;
  final List<int> albums; // albums는 리스트로 처리
  final int vetId;

  PeopleList({
    required this.id,
    required this.hos,
    required this.vet,
    required this.oneLineReview,
    required this.vetImageUrl,
    required this.albums,
    required this.vetId,
  });

  factory PeopleList.fromJson(Map<String, dynamic> json) {
    return PeopleList(
        id: json['id'],
        hos: json['hos'],
        vet: json['vet'],
        oneLineReview: json['one_line_review'],
        vetImageUrl: json['vet_image_url'],
        albums: List<int>.from(json['albums']),
        vetId: json['vet_id'] // List<int>로 변환
        );
  }
}

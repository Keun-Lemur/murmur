class Review {
  final int id;
  final Vet vet;
  final String vetExplanationType;
  final String writtenDate;
  final String contentSummary;
  final String content;

  Review({
    required this.id,
    required this.vet,
    required this.vetExplanationType,
    required this.writtenDate,
    required this.contentSummary,
    required this.content,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      vet: Vet.fromJson(json['vet']),
      vetExplanationType: json['vet_explanation_type'],
      writtenDate: json['written_date'],
      contentSummary: json['content_summary'],
      content: json['content'],
    );
  }
}

class Vet {
  final int id;
  final String vetName;
  final String hospitalName;

  Vet({
    required this.id,
    required this.vetName,
    required this.hospitalName,
  });

  factory Vet.fromJson(Map<String, dynamic> json) {
    return Vet(
      id: json['id'],
      vetName: json['vet_name'],
      hospitalName: json['hospital_name'],
    );
  }
}

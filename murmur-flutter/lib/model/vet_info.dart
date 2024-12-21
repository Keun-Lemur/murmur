class VetInfo {
  final int id;
  final String? vetImageUrl;
  final String? hospitalName;
  final String? vetName;
  final String? vetRole;
  final String? mainMedicalSubjects;
  final String? oneLineReview;
  final String? examResultExplanation;
  final String? prognosisExplanation;
  final String? careMethodExplanation;
  final String? heartDiseaseDiagnosisMetrics;
  final HeartDiseaseStageMedications? heartDiseaseStageMedications;
  final String? prescriptionPossible;
  final String? education;
  final String? researchActivities;
  final String? teachingActivities;
  final String? qualification;
  final InitialCost? initialCost;
  final InitialCostMore? initialCostMore;
  final String? hospitalAddress;
  final String? parking;
  final OfficeHours? officeHours;
  final String? examTime;
  final String? initialReservationWaitTime;
  final String? teleConsultation;
  final Radiologist? radiologist;
  final KeyEquipment? keyEquipment;

  VetInfo({
    required this.id,
    this.vetImageUrl,
    this.hospitalName,
    this.vetName,
    this.vetRole,
    this.mainMedicalSubjects,
    this.oneLineReview,
    this.examResultExplanation,
    this.prognosisExplanation,
    this.careMethodExplanation,
    this.heartDiseaseDiagnosisMetrics,
    this.heartDiseaseStageMedications,
    this.prescriptionPossible,
    this.education,
    this.researchActivities,
    this.teachingActivities,
    this.qualification,
    this.initialCost,
    this.initialCostMore,
    this.hospitalAddress,
    this.parking,
    this.officeHours,
    this.examTime,
    this.initialReservationWaitTime,
    this.teleConsultation,
    this.radiologist,
    this.keyEquipment,
  });

  factory VetInfo.fromJson(Map<String, dynamic> json) {
    return VetInfo(
      id: json['id'],
      vetImageUrl: json['vet_image_url'] ?? '',
      hospitalName: json['hospital_name'] ?? '',
      vetName: json['vet_name'] ?? '',
      vetRole: json['vet_role'] ?? '',
      mainMedicalSubjects: json['main_medical_subjects'] ?? '',
      oneLineReview: json['one_line_review'] ?? '',
      examResultExplanation: json['exam_result_explanation'] ?? '',
      prognosisExplanation: json['prognosis_explanation'] ?? '',
      careMethodExplanation: json['care_method_explanation'] ?? '',
      heartDiseaseDiagnosisMetrics:
          json['heart_disease_diagnosis_metrics'] ?? '',
      heartDiseaseStageMedications:
          json['heart_disease_stage_medications'] != null
              ? HeartDiseaseStageMedications.fromJson(
                  json['heart_disease_stage_medications'])
              : null,
      prescriptionPossible: json['prescription_possible'] ?? '',
      education: json['education'] ?? '',
      researchActivities: json['research_activities'] ?? '',
      teachingActivities: json['teaching_activities'] ?? '',
      qualification: json['qualification'] ?? '',
      initialCost: json['initial_cost'] != null
          ? InitialCost.fromJson(json['initial_cost'])
          : null,
      initialCostMore: json['initial_cost_more'] != null
          ? InitialCostMore.fromJson(json['initial_cost_more'])
          : null,
      hospitalAddress: json['hospital_address'] ?? '',
      parking: json['parking'] ?? '',
      officeHours: json['office_hours'] != null
          ? OfficeHours.fromJson(json['office_hours'])
          : null,
      examTime: json['exam_time'] ?? '',
      initialReservationWaitTime: json['initial_reservation_wait_time'] ?? '',
      teleConsultation: json['tele_consultation'] ?? '',
      radiologist: json['radiologist'] != null
          ? Radiologist.fromJson(json['radiologist'])
          : null,
      keyEquipment: json['key_equipment'] != null
          ? KeyEquipment.fromJson(json['key_equipment'])
          : null,
    );
  }
}

class HeartDiseaseStageMedications {
  final Pill? pill;

  HeartDiseaseStageMedications({this.pill});

  factory HeartDiseaseStageMedications.fromJson(dynamic json) {
    if (json == null) {
      return HeartDiseaseStageMedications(pill: null);
    } else if (json is Map<String, dynamic>) {
      return HeartDiseaseStageMedications(
        pill: json['pill'] != null ? Pill.fromJson(json['pill']) : null,
      );
    } else {
      return HeartDiseaseStageMedications(pill: null);
    }
  }
}

class Pill {
  final String? c;
  final String? d;
  final String? b1;
  final String? b2;
  final String? pre;

  Pill({this.c, this.d, this.b1, this.b2, this.pre});

  factory Pill.fromJson(dynamic json) {
    if (json == null || json == '데이터 수집중') {
      return Pill();
    } else if (json is Map<String, dynamic>) {
      return Pill(
          c: json['c']?.toString(),
          d: json['d']?.toString(),
          b1: json['b1']?.toString(),
          b2: json['b2']?.toString(),
          pre: json['pre']?.toString());
    } else {
      return Pill();
    }
  }
}

class InitialCost {
  final List<String>? details;

  InitialCost({this.details});

  factory InitialCost.fromJson(dynamic json) {
    if (json == null || json == '데이터 수집중') {
      return InitialCost(details: null);
    } else if (json is Map<String, dynamic>) {
      var detailsFromJson = json['details'];
      if (detailsFromJson != null && detailsFromJson is List) {
        List<String> detailsList = List<String>.from(detailsFromJson);
        return InitialCost(details: detailsList);
      } else {
        return InitialCost(details: null);
      }
    } else {
      return InitialCost(details: null);
    }
  }
}

class InitialCostMore {
  final Map<String, String>? cost;

  InitialCostMore({this.cost});

  factory InitialCostMore.fromJson(dynamic json) {
    if (json == null || json == '데이터 수집중') {
      return InitialCostMore(cost: null);
    } else if (json is Map<String, dynamic>) {
      var costFromJson = json['cost'];
      if (costFromJson != null && costFromJson is Map<String, dynamic>) {
        Map<String, String> costMap = {};
        costFromJson.forEach((key, value) {
          costMap[key.toString()] = value.toString();
        });
        return InitialCostMore(cost: costMap);
      } else {
        return InitialCostMore(cost: null);
      }
    } else {
      return InitialCostMore(cost: null);
    }
  }
}

class OfficeHours {
  final Map<String, String>? hours;

  OfficeHours({this.hours});

  factory OfficeHours.fromJson(dynamic json) {
    if (json == null || json == '데이터 수집중') {
      return OfficeHours(hours: null);
    } else if (json is Map<String, dynamic>) {
      Map<String, String> hoursMap = {};
      json.forEach((key, value) {
        hoursMap[key.toString()] = value.toString();
      });
      return OfficeHours(hours: hoursMap);
    } else {
      return OfficeHours(hours: null);
    }
  }

  // 요일을 순서대로 정렬해서 보기 좋은 형식으로 변환하는 메서드
  String getFormattedHours() {
    if (hours == null || hours!.isEmpty) {
      return '정보 없음';
    }

    // 요일 순서 배열
    final List<String> dayOrder = ['월', '화', '수', '목', '금', '토', '일'];

    // 요일 순서대로 정렬하고 각 항목을 출력 형식으로 변환
    return dayOrder
        .where((day) => hours!.containsKey(day)) // 주어진 요일 중에 존재하는 것만 필터링
        .map((day) => "$day: ${hours![day]}") // 각 요일의 시간을 문자열로 변환
        .join("\n"); // 줄바꿈으로 연결
  }
}

class Radiologist {
  final List<String>? radiologist;

  Radiologist({this.radiologist});

  factory Radiologist.fromJson(Map<String, dynamic> json) {
    // JSON이 Map 형식이므로 먼저 'radiologist' 필드를 가져옴
    if (json['radiologist'] != null && json['radiologist'] is List) {
      return Radiologist(
        radiologist: List<String>.from(json['radiologist']),
      );
    } else {
      return Radiologist(radiologist: null);
    }
  }
}

class KeyEquipment {
  final List<String> equip;

  KeyEquipment({required this.equip});

  factory KeyEquipment.fromJson(Map<String, dynamic> json) {
    List<dynamic> equipFromJson = json['equip'];
    List<String> equipList = List<String>.from(equipFromJson);

    return KeyEquipment(
      equip: equipList,
    );
  }
}

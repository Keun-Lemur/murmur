class VetHosDetail {
  final String? mainMedicalSubjects;
  final String? examResultExplanation;
  final String? prognosisExplanation;
  final String? careMethodExplanation;
  final String? heartDiseaseDiagnosisMetrics;
  final Map<String, dynamic>? heartDiseaseStageMedications;
  final String? prescriptionPossible;
  final Education? education;
  final List<String>? researchActivities;
  final List<String>? qualification;
  final Map<String, dynamic>? teachingActivities;
  final Hospital? hospital;

  VetHosDetail(
      {this.mainMedicalSubjects,
      this.examResultExplanation,
      this.prognosisExplanation,
      this.careMethodExplanation,
      this.heartDiseaseDiagnosisMetrics,
      this.heartDiseaseStageMedications,
      this.prescriptionPossible,
      this.education,
      this.researchActivities,
      this.qualification,
      this.hospital,
      this.teachingActivities});

  factory VetHosDetail.fromJson(Map<String, dynamic> json) {
    return VetHosDetail(
      mainMedicalSubjects: json['main_medical_subjects'] as String?,
      examResultExplanation: json['exam_result_explanation'] as String?,
      prognosisExplanation: json['prognosis_explanation'] as String?,
      careMethodExplanation: json['care_method_explanation'] as String?,
      heartDiseaseDiagnosisMetrics:
          json['heart_disease_diagnosis_metrics'] as String?,

      // heart_disease_stage_medications 처리
      heartDiseaseStageMedications: json['heart_disease_stage_medications'] !=
              null
          ? (json['heart_disease_stage_medications'] as Map<String, dynamic>)
              .map((key, value) {
              if (value is List) {
                return MapEntry(key, List<String>.from(value));
              } else {
                return MapEntry(key, [value.toString()]);
              }
            })
          : null,

      prescriptionPossible: json['prescription_possible'] as String?,
      education: json['education'] != null
          ? Education.fromJson(json['education'] as Map<String, dynamic>)
          : null,

      // research_activities 처리
      researchActivities: json['research_activities'] != null
          ? (json['research_activities'] is Map &&
                  json['research_activities']['publications'] is List
              ? List<String>.from(json['research_activities']['publications'])
              : [json['research_activities']['publications'] as String])
          : [],

      qualification: (json['qualification'] != null &&
              json['qualification']['qualification'] != null)
          ? List<String>.from(json['qualification']['qualification'] as List)
          : [],

      hospital: json['hospital'] != null
          ? Hospital.fromJson(json['hospital'] as Map<String, dynamic>)
          : null,
      teachingActivities: json['teaching_activities'] as Map<String, dynamic>?,
    );
  }
}

class Hospital {
  final int? id;
  final Map<String, dynamic>? initialCost;
  final Map<String, dynamic>? initialCostMore;
  final String? hospitalAddress;
  final String? parking;
  final Map<String, dynamic>? officeHours;
  final String? examTime;
  final String? initialReservationWaitTime;
  final String? teleConsultation;
  final List<String>? radiologist;
  final List<String>? keyEquipment;

  Hospital({
    this.id,
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

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] ?? 0,
      initialCost: json['initial_cost'] as Map<String, dynamic>? ?? {},
      initialCostMore: json['initial_cost_more'] as Map<String, dynamic>? ?? {},
      hospitalAddress: json['hospital_address'] as String? ?? '',
      parking: json['parking'] as String? ?? '',
      officeHours: json['office_hours'] as Map<String, dynamic>? ?? {},
      examTime: json['exam_time'] as String? ?? '',
      initialReservationWaitTime:
          json['initial_reservation_wait_time'] as String? ?? '',
      teleConsultation: json['tele_consultation'] as String? ?? '',

      // radiologist는 리스트이므로 배열로 처리
      radiologist:
          (json['radiologist'] != null && json['radiologist']['영상'] != null)
              ? List<String>.from(json['radiologist']['영상'] as List)
              : [],

      // key_equipment 필드도 배열로 처리
      keyEquipment: (json['key_equipment'] != null &&
              json['key_equipment']['장비목록'] != null)
          ? List<String>.from(json['key_equipment']['장비목록'] as List)
          : [],
    );
  }
}

class Education {
  final String? doctorate;
  final String? residency;
  final String? university;
  final String? mastersDegree;

  Education({
    this.doctorate,
    this.residency,
    this.university,
    this.mastersDegree,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      doctorate: json['doctorate'] as String? ?? '',
      residency: json['residency'] as String? ?? '',
      university: json['university'] as String? ?? '',
      mastersDegree: json['mastersDegree'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorate': doctorate,
      'residency': residency,
      'university': university,
      'mastersDegree': mastersDegree,
    };
  }
}

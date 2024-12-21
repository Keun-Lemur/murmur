import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concrete_jaegaebal/view/s_hos_detail.dart';
import 'package:concrete_jaegaebal/view/s_review.dart';
import 'package:concrete_jaegaebal/viewmodel/vm_auth_state_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  final int? vetId;
  final String? title;
  const SignupScreen({super.key, this.vetId, this.title});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final picker = ImagePicker();
  List<XFile> multiImage = [];
  List<XFile> images = []; // 선택된 이미지들을 저장할 리스트
  List<String> imageNames = []; // 선택된 이미지의 파일명을 저장할 리스트
  bool _isUploading = false;
  bool _loading = false;

  XFile? file;

  // 설문 데이터를 저장할 Firestore 참조
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 질문 데이터
  final List<Map<String, dynamic>> questions = [
    {
      'question': '저희의 심장병원 정보 링크를 어디서 알게 되셨나요?',
      'required': true,
      'type': 'radio',
      'options': ['아반강고 카페', '카카오톡 오픈채팅방', '인스타그램', '지인', '기타']
    },
    {
      'question': '심장병으로 다녔던 🏥병원들을\n순서대로 작성해주세요',
      'description': '(동네병원포함)\nex. 방이동물병원 > 샤인 > 수호천사 > 더케어 ',
      'required': true,
      'type': 'text'
    },
    {
      'question': '현재, 병원 선택에 고민이 있나요?',
      'description': '(그 이유도 설명 부탁드려요)',
      'required': true,
      'type': 'radio',
      'options': ['고민이 있다', '고민이 없다']
    },
    {
      'question': '지금 보호자님께서\n가장 알고싶은 정보는 어떤 것인가요?',
      'required': true,
      'minLength': 5,
      'type': 'text'
    },
    {
      'question': '아이의 이름과 나이, 견종과 거주중인 지역을 알려주세요~',
      'description': 'ex. 몬드, 12, 말티즈, 인천',
      'required': true,
      'minLength': 7,
      'type': 'text'
    },
    {
      'question': '현재 다니고 있는 병원을 알려주세요!',
      'required': true,
      'minLength': 3,
      'type': 'text'
    },
    {
      'question': '지금 다니는 병원에 아쉬운 점이 있나요?',
      'description': '(있다면, 그 이유도 설명 부탁드려요)',
      'required': true,
      'type': 'text'
    },
    {
      'question': '담당 수의사의 이름은 무엇인가요?',
      'required': true,
      'minLength': 3,
      'type': 'text'
    },
    {
      'question': '지금 다니는 병원은 어떻게 알게 되었나요?',
      'required': true,
      'minLength': 3,
      'type': 'text'
    },
    {
      'question': '다니는 병원의 수의사에게\n가장 바라는 점을 알려주세요',
      'required': true,
      'minLength': 10,
      'type': 'text'
    },
    {
      'question': '🐶아이의 현재 심장병 진행도를 알려주세요',
      'required': true,
      'minLength': 2,
      'type': 'text'
    },
    {
      'question': '병원에서 아이의 심장병에 대해\n예후와 기대수명을 어떻게 설명해주었나요?',
      'description': '(자세한 설명 부탁드려요~)',
      'required': true,
      'minLength': 5,
      'type': 'text'
    },
    {
      'question': '다니는 병원에서 심장병 진료 후 받은\n🧾진료비 영수증을 업로드해주세요',
      'description': '여러장 업로드도 가능해요!',
      'required': true,
      'type': 'file'
    },
    {
      'question': '업로드 해주신 영수증이 초진 영수증인가요?\n재진 영수증인가요?',
      'required': true,
      'type': 'radio',
      'options': ['초진', '재진', '초진 재진 둘다', '기타']
    },
    {
      'question': '영수증에 나와있는 항목들중\n이해가 가지 않는 부분을 말씀해주세요',
      'required': true,
      'minLength': 5,
      'type': 'text'
    },
    {
      'question': '수의사에게 들었던 진료와 처방내용을\n자세히 적어주세요',
      'required': true,
      'minLength': 10,
      'type': 'text'
    },
    {
      'question': '아이가 현재 복용중인\n처방약을 알려주세요',
      'required': true,
      'type': 'checkbox',
      'options': [
        '피모벤단',
        '스피로락톤',
        '클로피도그렐',
        '실데나필',
        '암로디핀',
        '토르세미드',
        '푸로세미드',
        '스피로놀락톤',
        '에나프릴',
        '베나제프릴',
        '기타'
      ]
    },
    {
      'question': '수의사에게 들었던\n심장병의 관리 및 케어 방법을\n자세하게 적어주세요',
      'required': true,
      'minLength': 5,
      'type': 'text'
    },
    {
      'question': '심장병으로 🚨응급상황이\n생겼을때 병원의 대처는 어땠나요?',
      'description': '(경험 없으시면 공란으로 두셔도 됩니다~)',
      'required': false,
      'type': 'text'
    },
    {
      'question': '🏥병원을 방문하지 않고도 수의사와 소통할 수 있는 방법은 무엇인가요?',
      'description': '(보기에 해당하지 않을 경우 "기타" 선택 후에 직접 작성 부탁드려요~)',
      'required': true,
      'type': 'checkbox',
      'options': ['카톡 및 메세지', '전화', '메일', '없음', '기타']
    },
    {
      'question': '아래 보기들중\n병원에서 설명받은 수치는 무엇인가요?',
      'description': '(보기에 해당하지 않을 경우 "기타" 선택 후에 직접 작성 부탁드려요~)',
      'required': true,
      'type': 'checkbox',
      'options': [
        'ProBNP',
        'E peak',
        'E/A',
        'Troponin I',
        'LA/Ao',
        'VHS',
        'VLAS',
        'LVIDDn',
        '기타'
      ]
    },
    {
      'question': '다니는 병원 첫 예약시에\n대기가 있었나요?',
      'required': true,
      'type': 'radio',
      'options': ['당일', '1주일 이내', '2주일 이내', '2주~한달사이', '한달 이상', '기타']
    },
    {
      'question': '병원에서 전달해주는 자료들을\n✔️체크해주세요~',
      'required': true,
      'type': 'checkbox',
      'options': ['엑스레이 결과', '혈액검사 결과지', '초음파 영상', '진료내용 요약본', '기타']
    },
    {
      'question': '다니고 있는 🏥병원에 대한 후기를 자유롭게 작성해주세요~',
      'required': true,
      'minLength': 30,
      'type': 'text'
    },
    {'question': '📞휴대폰 번호를 작성해 주세요', 'required': true, 'type': 'number'}
  ];

  List<TextEditingController> _controllers = [];
  List<bool> errors = [];
  Map<int, String?> selectedRadioValues = {};
  Map<int, List<String>> selectedCheckboxValues = {};
  Map<int, bool> showOtherTextField = {}; // '기타' 선택 시 텍스트 필드 노출 여부
  Map<int, bool> showCustomTextField = {}; // 선택에 따라 텍스트 필드 노출 여부

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(questions.length, (index) => TextEditingController());
    errors = List.generate(questions.length, (index) => false);
    showOtherTextField = {
      for (var index in List.generate(questions.length, (index) => index))
        index: false
    };
    showCustomTextField = {
      for (var index in List.generate(questions.length, (index) => index))
        index: false
    };
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  final storageRef =
      FirebaseStorage.instanceFor(bucket: "concrete-mvp.appspot.com");

  Future<void> _uploadImages() async {
    for (XFile image in images) {
      try {
        File file = File(image.path); // XFile을 File로 변환
        String fileName = image.name; // 파일명 가져오기

        // Storage의 경로 설정
        final ref =
            storageRef.ref().child('heartb2/$fileName'); // heartb2 디렉토리 내에 저장

        // 파일을 Firebase Storage에 업로드
        TaskSnapshot snapshot = await ref.putFile(file);

        // 업로드된 파일의 URL 가져오기
        String downloadUrl = await snapshot.ref.getDownloadURL();
        // print("Uploaded: $downloadUrl");
      } catch (e) {
        // print("Upload failed: $e");
      }
    }
  }

  Future<void> markSurveyAsCompleted() async {
    try {
      // 현재 로그인한 사용자의 UID 가져오기
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        // print("사용자가 로그인되지 않았습니다.");
        return;
      }

      String userId = currentUser.uid;

      // Firestore에서 해당 유저의 문서가 존재하는지 확인하고, 없으면 생성
      await FirebaseFirestore.instance.collection('logins').doc(userId).set({
        'isSurveyCompleted': true, // 설문 완료로 상태 업데이트
      }, SetOptions(merge: true)); // 기존 데이터와 병합

      // print("Survey completion status updated for user: $userId");
    } catch (e) {
      // print("Error marking survey as completed: $e");
    }
  }

  Future<void> submitSurveyToFirestore(Map<String, dynamic> surveyData) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;

        await FirebaseFirestore.instance
            .collection('surveys')
            .doc(userId) // userId를 문서 ID로 사용
            .set(surveyData); // surveyData 저장
        // print("Survey submitted successfully for user: $userId");
      } else {
        // print("No user is logged in.");
      }
    } catch (e) {
      // print("Error submitting survey: $e");
    }
  }

  void _handleSubmit(vetId, title) async {
    bool hasErrors = false;
    Map<String, dynamic> surveyData = {};

    setState(() {
      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        if (question['required'] == true) {
          if (question['type'] == 'text' && _controllers[i].text.isEmpty) {
            errors[i] = true;
            hasErrors = true;
          } else if (question['type'] == 'radio' &&
              selectedRadioValues[i] == null) {
            errors[i] = true;
            hasErrors = true;
          } else if (question['type'] == 'checkbox' &&
              (selectedCheckboxValues[i]?.isEmpty ?? true)) {
            errors[i] = true;
            hasErrors = true;
          } else {
            errors[i] = false;
            // 설문 데이터를 저장
            if (question['type'] == 'text') {
              surveyData[question['question']] = _controllers[i].text;
            } else if (question['type'] == 'radio') {
              surveyData[question['question']] = selectedRadioValues[i];
            } else if (question['type'] == 'checkbox') {
              surveyData[question['question']] = selectedCheckboxValues[i];
            } else if (question['type'] == 'number') {
              if (_controllers[i].text.isEmpty) {
                errors[i] = true;
                hasErrors = true;
              } else {
                errors[i] = false;
                // 문자열로 처리하여 저장
                surveyData[question['question']] = _controllers[i].text;
              }
            }
          }
        }
      }
    });

    if (!hasErrors) {
      // print("Form Submitted Successfully!");

      // Firebase Firestore에 설문 데이터 저장
      await submitSurveyToFirestore(surveyData);

      setState(() {
        _isUploading = true;
      });

      // 이미지 업로드
      await _uploadImages();

      // 설문조사 완료 상태 저장
      await markSurveyAsCompleted();

      //프로바이더 상태관리
      Provider.of<AuthStateProviderViewModel>(context, listen: false)
          .completeSurvey();

      setState(() {
        _isUploading = false;
      });

      // print("Survey and images uploaded.");

      // Navigator.pop(context);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => ReviewScreen(vetId: vetId, title: title)),
      );
    } else {
      // print("Validation failed.");
      // print(errors);
    }
  }

  Widget _buildRadioGroup(int index, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...options.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: selectedRadioValues[index],
            onChanged: (value) {
              setState(() {
                selectedRadioValues[index] = value;

                // '기타' 선택 시 텍스트 입력 필드 노출
                if (value == '기타') {
                  showOtherTextField[index] = true;
                } else {
                  showOtherTextField[index] = false;
                }

                // 질문에 따른 선택 필드 처리 (index == 2는 "고민이 있다/없다"에 대한 질문일 때)
                if (index == 2 && value == '고민이 있다') {
                  showCustomTextField[index] = true;
                } else if (index == 2 && value == '고민이 없다') {
                  showCustomTextField[index] = true;
                } else {
                  showCustomTextField[index] = false;
                }
              });
            },
            contentPadding: EdgeInsets.zero, // 패딩을 완전히 제거
            visualDensity:
                const VisualDensity(horizontal: -4.0, vertical: -4.0),
          );
        }),

        // '기타'를 선택한 경우 텍스트 입력 필드 표시
        if (showOtherTextField[index] == true)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '직접 입력해주세요',
                filled: true,
                fillColor: const Color(0xFFF2F4F7),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

        // "고민이 있다/없다"를 선택한 경우 텍스트 입력 필드 표시
        if (showCustomTextField[index] == true)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: selectedRadioValues[index] == '고민이 있다'
                    ? '고민이 있는 이유를 입력해주세요'
                    : '고민이 없는데도 병원을 찾고있는 이유가 무엇인가요?',
                filled: true,
                fillColor: const Color(0xFFF2F4F7),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCheckboxGroup(int index, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...options.map((option) {
          return CheckboxListTile(
            title: Text(option),
            value: selectedCheckboxValues[index]?.contains(option) ?? false,
            onChanged: (bool? checked) {
              setState(() {
                if (checked == true) {
                  selectedCheckboxValues
                      .putIfAbsent(index, () => [])
                      .add(option);
                } else {
                  selectedCheckboxValues[index]?.remove(option);
                }

                // '기타' 체크 시 텍스트 필드 노출
                if (option == '기타' && checked == true) {
                  showOtherTextField[index] = true;
                } else if (option == '기타' && checked == false) {
                  showOtherTextField[index] = false;
                }
              });
            },
            controlAffinity: ListTileControlAffinity.leading, // 체크박스가 왼쪽에 위치
            contentPadding: EdgeInsets.zero, // 패딩을 완전히 제거
            visualDensity:
                const VisualDensity(horizontal: -4.0, vertical: -4.0),
          );
        }),

        // '기타'를 선택한 경우 텍스트 입력 필드 표시
        if (showOtherTextField[index] == true)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '직접 입력해주세요',
                filled: true,
                fillColor: const Color(0xFFF2F4F7),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFormField(int index, Map<String, dynamic> question) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDBDCE0), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (question['required'] == true)
                const Baseline(
                  baseline: 17,
                  baselineType: TextBaseline.alphabetic,
                  child: Text(
                    '*',
                    style: TextStyle(
                      color: Color(0xFF0073FA),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (question['required'] == true) const SizedBox(width: 4),
              Expanded(
                child: Baseline(
                  baseline: 17,
                  baselineType: TextBaseline.alphabetic,
                  child: Text(
                    question['question'],
                    style: const TextStyle(
                      fontSize: 17,
                      color: Color(0xFF222225),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (question['description'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                question['description'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8B8D97),
                ),
              ),
            ),
          const SizedBox(height: 10),

          // 'file' 타입에 대한 처리
          if (question['type'] == 'file')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      multiImage = await picker.pickMultiImage();
                      setState(() {
                        images.addAll(multiImage); // 선택된 이미지를 추가
                        imageNames.addAll(multiImage.map((img) => img.name));

                        // 이미지 경로와 이름을 콘솔에 출력
                        for (var image in multiImage) {
                          // print('Image Path: ${image.path}');
                          // print('Image Name: ${image.name}');
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
                      backgroundColor: const Color(0xFF0073FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '영수증 업로드',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),

                // 선택된 이미지의 파일명을 표시
                if (imageNames.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: imageNames.map((imageName) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '영수증: $imageName', // '영수증: 파일이름' 형식으로 표시
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333D4B),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                // 업로드 중 로딩 표시
                if (_isUploading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),

          // 'text' 타입에 대한 처리
          if (question['type'] == 'text')
            TextField(
              controller: _controllers[index],
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF2F4F7),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide.none,
                ),
                errorText: errors[index] ? '필수 항목입니다' : null,
              ),
              style: const TextStyle(
                color: Color(0xFF6A6A6A),
                fontWeight: FontWeight.w500,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            )
          else if (question['type'] == 'radio')
            _buildRadioGroup(index, question['options'])
          else if (question['type'] == 'checkbox')
            _buildCheckboxGroup(index, question['options'])
          else if (question['type'] == 'number')
            TextField(
              controller: _controllers[index],
              keyboardType: TextInputType.number, // 숫자 입력 가능하도록 설정
              decoration: InputDecoration(
                hintText: question['description'] ?? '휴대폰 번호를 입력해주세요',
                filled: true,
                fillColor: const Color(0xFFF2F4F7),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF2F4F7),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 35.0),
          child: Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(8),
                      border: const Border(
                        top: BorderSide(color: Color(0xFF0073FA), width: 7.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          '5분만 시간을 내서',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: Color(0xFF1B1F25),
                          ),
                        ),
                        const SizedBox(height: 15),
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: '신랄한 비판, 진솔한 얘기',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFF04452),
                                ),
                              ),
                              TextSpan(
                                text: '까지\n',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1B1F25),
                                ),
                              ),
                              TextSpan(
                                text: '전부 확인하세요.',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1B1F25),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '🔒모든 답변은 철저히 비밀로 보관돼요',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF333D4B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    '* 표시가 있는 항목은 필수로 답변해주셔야 해요',
                    style: TextStyle(
                      color: Color(0xFF0073FA),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 15),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      return _buildFormField(index, questions[index]);
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => {
                      _handleSubmit(widget.vetId, widget.title),
                      setState(() => _loading = true)
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
                      backgroundColor: const Color(0xFF0073FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '완료',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                  if (_loading)
                    Container(
                      color: Colors.black.withOpacity(0.7),
                      width: double.maxFinite,
                      height: double.maxFinite,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

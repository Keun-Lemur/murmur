import 'package:concrete_jaegaebal/model/vet_info.dart';
import 'package:flutter/material.dart';
import '../service/vet_info_service.dart';

class VetInfoViewModel extends ChangeNotifier {
  final VetInfoService _vetInfoService = VetInfoService();

  List<VetInfo>? vets;
  VetInfo? selectedVet;
  bool isLoading = false;
  String? errorMessage;

  bool _isDataLoaded =
      false; // This flag checks if data has already been loaded.
  bool get isDataLoaded => _isDataLoaded; // Getter for the flag.

  VetInfo? get vetHosDetail => selectedVet;

  // 모든 Vet 데이터를 가져오는 메서드
  Future<void> fetchVets() async {
    // If data is already loaded, no need to fetch again
    if (_isDataLoaded) return;

    isLoading = true;
    notifyListeners();

    try {
      vets = await _vetInfoService.getAllVets();
      _isDataLoaded = true; // Data has been loaded
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 특정 Vet 데이터를 가져오는 메서드
  Future<void> fetchVetById(int id) async {
    // If data for the specific vet is already loaded, no need to fetch again
    if (_isDataLoaded && selectedVet != null && selectedVet!.id == id) {
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      selectedVet = await _vetInfoService.getVetById(id);
      _isDataLoaded = true; // Data for the specific vet has been loaded
      print("Selected Vet: ${selectedVet?.vetName}");
      print("selected vet id: ${selectedVet?.id}");
      print(
          "Fetched Vet radiologist: ${selectedVet?.radiologist?.radiologist}"); // 데이터를 가져왔는지 확인
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Method to reset the data when necessary (e.g., when switching vets)
  void resetData() {
    selectedVet = null;
    _isDataLoaded = false;
    notifyListeners();
  }
}

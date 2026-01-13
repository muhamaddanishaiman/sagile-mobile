import 'package:flutter/material.dart';
import 'nfr_model.dart';
import 'nfr_service.dart';

class UserStoryController with ChangeNotifier {
  final NFRService _nfrService = NFRService();
  
  List<NFR> _linkedNFRs = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasFetched = false;

  List<NFR> get linkedNFRs => _linkedNFRs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasFetched => _hasFetched;

  Future<void> getLinkedNFR(int userStoryId) async {
    _isLoading = true;
    _errorMessage = null;
    _hasFetched = true;
    notifyListeners();

    try {
      _linkedNFRs = await _nfrService.fetchLinkedNFR(userStoryId);
    } catch (e) {
      _errorMessage = e.toString();
      _linkedNFRs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

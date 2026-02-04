import 'package:flutter/material.dart';
import 'package:fitness_mobile/services/api_service.dart';

class WodProvider extends ChangeNotifier {
  List<dynamic> _wods = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get wods => _wods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _wods = await ApiService.getWods();
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }
}

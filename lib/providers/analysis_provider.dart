import 'dart:io';
import 'package:flutter/material.dart';
import '../models/analysis_request.dart';
import '../models/analysis_result.dart';
import '../models/comparison_type.dart';
import '../services/api_service.dart';

class AnalysisProvider extends ChangeNotifier {
  final ApiService _apiService;

  AnalysisProvider({required ApiService apiService}) : _apiService = apiService;

  // State variables
  File? _selectedImage;
  ComparisonType _selectedComparisonType = ComparisonType.temperature;
  String _referenceValue = '';
  String _additionalContext = '';
  bool _isLoading = false;
  AnalysisResult? _result;
  String? _error;

  // Getters
  File? get selectedImage => _selectedImage;
  ComparisonType get selectedComparisonType => _selectedComparisonType;
  String get referenceValue => _referenceValue;
  String get additionalContext => _additionalContext;
  bool get isLoading => _isLoading;
  AnalysisResult? get result => _result;
  String? get error => _error;
  bool get canAnalyze => _selectedImage != null && _referenceValue.isNotEmpty;

  // Setters
  void setSelectedImage(File? image) {
    _selectedImage = image;
    _clearResults();
    notifyListeners();
  }

  void setComparisonType(ComparisonType type) {
    _selectedComparisonType = type;
    _clearResults();
    notifyListeners();
  }

  void setReferenceValue(String value) {
    _referenceValue = value;
    _clearResults();
    notifyListeners();
  }

  void setAdditionalContext(String context) {
    _additionalContext = context;
    notifyListeners();
  }

  void _clearResults() {
    _result = null;
    _error = null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _selectedImage = null;
    _selectedComparisonType = ComparisonType.temperature;
    _referenceValue = '';
    _additionalContext = '';
    _isLoading = false;
    _result = null;
    _error = null;
    notifyListeners();
  }

  Future<void> analyzeImage() async {
    if (!canAnalyze) return;

    _isLoading = true;
    _error = null;
    _result = null;
    notifyListeners();

    try {
      final request = AnalysisRequest(
        image: _selectedImage!,
        comparisonType: _selectedComparisonType.value,
        referenceValue: _referenceValue,
        additionalContext: _additionalContext.isEmpty ? null : _additionalContext,
      );

      _result = await _apiService.analyzeImage(request);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkServerConnection() async {
    return await _apiService.checkServerHealth();
  }
}

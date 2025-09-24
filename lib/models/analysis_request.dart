import 'dart:io';

class AnalysisRequest {
  final File image;
  final String comparisonType;
  final String referenceValue;
  final String? additionalContext;

  AnalysisRequest({
    required this.image,
    required this.comparisonType,
    required this.referenceValue,
    this.additionalContext,
  });

  Map<String, String> toMap() {
    return {
      'comparison_type': comparisonType,
      'reference_value': referenceValue,
      if (additionalContext != null && additionalContext!.isNotEmpty)
        'additional_context': additionalContext!,
    };
  }
}

class AnalysisResult {
  final String description;
  final String extractedInfo;
  final String comparisonTitle;
  final String imageLabel;
  final String imageValue;
  final String referenceLabel;
  final String referenceValueDisplay;
  final String referenceSource;
  final String comparison;

  AnalysisResult({
    required this.description,
    required this.extractedInfo,
    required this.comparisonTitle,
    required this.imageLabel,
    required this.imageValue,
    required this.referenceLabel,
    required this.referenceValueDisplay,
    required this.referenceSource,
    required this.comparison,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      description: json['description'] ?? '',
      extractedInfo: json['extracted_info'] ?? '',
      comparisonTitle: json['comparison_title'] ?? '',
      imageLabel: json['image_label'] ?? '',
      imageValue: json['image_value'] ?? '',
      referenceLabel: json['reference_label'] ?? '',
      referenceValueDisplay: json['reference_value_display'] ?? '',
      referenceSource: json['reference_source'] ?? '',
      comparison: json['comparison'] ?? '',
    );
  }
}

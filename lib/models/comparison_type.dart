enum ComparisonType {
  temperature('temperature', 'Temperature Comparison', 'e.g., London, New York'),
  price('price', 'Price Comparison', 'e.g., iPhone 13, Samsung Galaxy'),
  product('product', 'Product Comparison', 'e.g., Product name to search'),
  dateTime('date_time', 'Date/Time Comparison', 'e.g., Current date, specific date'),
  location('location', 'Location Analysis', 'e.g., Paris, Tokyo'),
  currency('currency', 'Currency Comparison', 'e.g., USD, EUR, GBP'),
  weather('weather', 'Weather Comparison', 'e.g., London, weather location'),
  general('general', 'General Comparison', 'e.g., Any reference value for comparison');

  const ComparisonType(this.value, this.displayName, this.placeholder);

  final String value;
  final String displayName;
  final String placeholder;

  static ComparisonType fromValue(String value) {
    return ComparisonType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ComparisonType.general,
    );
  }
}

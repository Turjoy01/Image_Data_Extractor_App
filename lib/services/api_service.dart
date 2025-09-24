import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/analysis_request.dart';
import '../models/analysis_result.dart';
import '../utils/constants.dart';

class ApiService {
  static const Set<String> supportedImageFormats = {
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/bmp',
    'image/tiff',
    'image/tif',
    'image/webp',
    'image/svg+xml',
    'image/ico',
    'image/heic',
    'image/heif',
    'image/avif',
    'image/jfif'
  };

  static const int maxRetries = 3;
  static const int baseDelayMs = 1000;
  static const int maxDelayMs = 10000;

  Future<AnalysisResult> analyzeImage(AnalysisRequest request) async {
    try {
      // Convert image to base64
      final imageBytes = await request.image.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      return await _performAnalysis(request, base64Image);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Network error: $e', null);
    }
  }

  Future<AnalysisResult> _performAnalysis(AnalysisRequest request, String base64Image) async {
    String prompt = '''
Perform a comprehensive analysis of this image with focus on ${request.comparisonType} comparison:

1. VISUAL DESCRIPTION: Describe everything you see in the image - objects, people, scenery, colors, composition, etc.

2. TEXT EXTRACTION: Extract ALL text visible in the image including signs, labels, numbers, dates, prices, etc.

3. SPECIFIC FOCUS: ${_getComparisonInstruction(request.comparisonType)}

4. CONTEXTUAL INFORMATION: Any additional relevant details

Additional context provided: ${request.additionalContext ?? 'None provided'}

Format your response EXACTLY as follows:
DESCRIPTION: [comprehensive visual description]
EXTRACTED_INFO: [all text, objects, and information found]
TARGET_VALUE: [specific value related to ${request.comparisonType} or "not found"]
''';

    final analysisText = await _callGeminiAPIWithRetry(prompt, base64Image);

    final parsedResponse = _parseAIResponse(analysisText);

    final comparisonResult = await _performComparison(
      request.comparisonType.toLowerCase(),
      parsedResponse['target_value'] ?? 'Not found',
      request.referenceValue,
      request.additionalContext ?? '',
    );

    return AnalysisResult(
      description: parsedResponse['description'] ?? 'Comprehensive image analysis completed',
      extractedInfo: parsedResponse['extracted_info'] ??
          'Various visual elements and content detected in the image',
      comparisonTitle: comparisonResult['title']!,
      imageLabel: comparisonResult['image_label']!,
      imageValue: comparisonResult['image_value']!,
      referenceLabel: comparisonResult['reference_label']!,
      referenceValueDisplay: comparisonResult['reference_value_display']!,
      referenceSource: comparisonResult['reference_source']!,
      comparison: comparisonResult['comparison']!,
    );
  }

  Future<String> _callGeminiAPIWithRetry(String prompt, String base64Image) async {
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        return await _callGeminiAPI(prompt, base64Image);
      } catch (e) {
        if (e is ApiException && e.statusCode == 429) {
          attempt++;
          if (attempt >= maxRetries) {
            throw ApiException(
              'Rate limit exceeded. Please wait a moment and try again. The service is temporarily busy.',
              429,
            );
          }

          // Exponential backoff with jitter
          final delay = min(
            baseDelayMs * pow(2, attempt - 1).toInt() + Random().nextInt(1000),
            maxDelayMs,
          );

          print(
              '[Tur] Rate limited (attempt $attempt/$maxRetries), waiting ${delay}ms before retry...');
          await Future.delayed(Duration(milliseconds: delay));
        } else {
          rethrow;
        }
      }
    }

    throw ApiException('Failed after $maxRetries attempts', null);
  }

  String _getComparisonInstruction(String comparisonType) {
    final instructions = {
      'temperature':
          'Look for temperature readings, thermometers, weather displays, or any temperature-related information',
      'price':
          'Look for prices, price tags, receipts, bills, cost information, currency symbols, and monetary values',
      'product':
          'Identify product names, brands, model numbers, product labels, and any product-related information',
      'date_time':
          'Look for dates, times, timestamps, calendars, clocks, schedules, and time-related information',
      'location':
          'Identify location names, addresses, landmarks, city names, country names, and geographical information',
      'currency':
          'Look for currency symbols, monetary amounts, exchange rates, and financial information',
      'weather':
          'Look for weather conditions, weather apps, forecasts, and weather-related information for comparison',
      'general':
          'Extract all visible information including text, numbers, objects, and contextual details for comparison analysis'
    };
    return instructions[comparisonType.toLowerCase()] ?? instructions['general']!;
  }

  Map<String, String> _parseAIResponse(String aiResponse) {
    final lines = aiResponse.split('\n');
    String description = '';
    String extractedInfo = '';
    String targetValue = 'Not found';

    String? currentSection;
    for (String line in lines) {
      line = line.trim();
      if (line.startsWith('DESCRIPTION:')) {
        currentSection = 'description';
        description = line.replaceFirst('DESCRIPTION:', '').trim();
      } else if (line.startsWith('EXTRACTED_INFO:')) {
        currentSection = 'extracted_info';
        extractedInfo = line.replaceFirst('EXTRACTED_INFO:', '').trim();
      } else if (line.startsWith('TARGET_VALUE:')) {
        currentSection = 'target_value';
        targetValue = line.replaceFirst('TARGET_VALUE:', '').trim();
      } else if (line.isNotEmpty && currentSection != null) {
        switch (currentSection) {
          case 'description':
            description += ' $line';
            break;
          case 'extracted_info':
            extractedInfo += ' $line';
            break;
          case 'target_value':
            targetValue += ' $line';
            break;
        }
      }
    }

    return {
      'description':
          description.isNotEmpty ? description : 'Comprehensive image analysis completed',
      'extracted_info': extractedInfo.isNotEmpty
          ? extractedInfo
          : 'Various visual elements and content detected in the image',
      'target_value': targetValue,
    };
  }

  Future<Map<String, String>> _performComparison(
    String comparisonType,
    String targetValue,
    String referenceValue,
    String additionalContext,
  ) async {
    switch (comparisonType) {
      case 'temperature':
        return await _compareTemperature(targetValue, referenceValue);
      case 'price':
        return await _comparePrice(targetValue, referenceValue);
      case 'product':
        return _compareProduct(targetValue, referenceValue);
      case 'date_time':
        return _compareDateTime(targetValue, referenceValue);
      case 'location':
        return _compareLocation(targetValue, referenceValue);
      case 'currency':
        return await _compareCurrency(targetValue, referenceValue);
      case 'weather':
        return await _compareWeather(targetValue, referenceValue);
      default:
        return _compareGeneral(targetValue, referenceValue, additionalContext);
    }
  }

  Future<Map<String, String>> _compareTemperature(String targetValue, String referenceValue) async {
    final tempMatch = RegExp(r'-?\d+\.?\d*').firstMatch(targetValue);
    final imageTemp = tempMatch != null ? double.tryParse(tempMatch.group(0)!) : null;

    try {
      final weatherData = await _getWeatherDataForCity(referenceValue);
      final liveTemp =
          double.tryParse(weatherData['temperature']?.replaceAll('°C', '') ?? '0') ?? 0;
      final weatherCondition = weatherData['description'] ?? 'clear sky';

      String comparison;
      if (imageTemp != null) {
        final tempDiff = (imageTemp - liveTemp).abs();
        if (tempDiff < 2) {
          comparison =
              'The temperature in the image ($imageTemp°C) matches closely with the current weather in $referenceValue (${liveTemp.round()}°C). Excellent match!';
        } else {
          comparison =
              'The temperature in the image ($imageTemp°C) differs by ${tempDiff.toStringAsFixed(1)}°C from the current weather in $referenceValue (${liveTemp.round()}°C).';
        }
      } else {
        comparison =
            'No clear temperature found in image. Current weather in $referenceValue is ${liveTemp.round()}°C with $weatherCondition.';
      }

      return {
        'title': 'Temperature Comparison',
        'image_label': 'Image Temperature',
        'image_value': imageTemp != null ? '$imageTemp°C' : 'Not found',
        'reference_label': 'Live Weather',
        'reference_value_display': '${liveTemp.round()}°C',
        'reference_source': '$referenceValue ($weatherCondition)',
        'comparison': comparison,
      };
    } catch (e) {
      return {
        'title': 'Temperature Comparison',
        'image_label': 'Image Temperature',
        'image_value': targetValue,
        'reference_label': 'Reference',
        'reference_value_display': 'Weather data unavailable',
        'reference_source': referenceValue,
        'comparison':
            'Found in image: $targetValue. Unable to fetch weather data for $referenceValue.',
      };
    }
  }

  Future<Map<String, String>> _comparePrice(String targetValue, String referenceValue) async {
    final priceMatch = RegExp(r'[\$€£¥]?\d+\.?\d*').firstMatch(targetValue);
    final imagePrice = priceMatch?.group(0) ?? targetValue;

    final productData = await _searchProductPrice(referenceValue);

    String comparison = 'Found price in image: $imagePrice. ';
    if (productData['price'] != 'Not found') {
      comparison +=
          'Online reference price for $referenceValue: \$${productData['price']} from ${productData['source']}.';
    } else {
      comparison += 'Could not find online price reference for \'$referenceValue\'.';
    }

    return {
      'title': 'Price Comparison',
      'image_label': 'Image Price',
      'image_value': imagePrice,
      'reference_label': 'Online Price',
      'reference_value_display':
          productData['price'] != 'Not found' ? '\$${productData['price']}' : 'Not found',
      'reference_source': productData['source']!,
      'comparison': comparison,
    };
  }

  Map<String, String> _compareProduct(String targetValue, String referenceValue) {
    String comparison =
        'Product identified in image: $targetValue. Reference product: $referenceValue.';

    if (referenceValue.toLowerCase().contains(targetValue.toLowerCase()) ||
        targetValue.toLowerCase().contains(referenceValue.toLowerCase())) {
      comparison += ' Products appear to match!';
    } else {
      comparison += ' Products appear to be different.';
    }

    return {
      'title': 'Product Comparison',
      'image_label': 'Image Product',
      'image_value': targetValue,
      'reference_label': 'Reference Product',
      'reference_value_display': referenceValue,
      'reference_source': 'User provided',
      'comparison': comparison,
    };
  }

  Map<String, String> _compareDateTime(String targetValue, String referenceValue) {
    final currentTime = DateTime.now().toString().substring(0, 19);

    String comparison = 'Date/time found in image: $targetValue. Current date/time: $currentTime.';

    if (referenceValue.toLowerCase() == 'current') {
      comparison += ' Comparing with current date/time.';
    } else {
      comparison += ' Reference date/time: $referenceValue.';
    }

    return {
      'title': 'Date/Time Comparison',
      'image_label': 'Image Date/Time',
      'image_value': targetValue,
      'reference_label': 'Reference Time',
      'reference_value_display':
          referenceValue.toLowerCase() == 'current' ? currentTime : referenceValue,
      'reference_source':
          referenceValue.toLowerCase() == 'current' ? 'System time' : 'User provided',
      'comparison': comparison,
    };
  }

  Map<String, String> _compareLocation(String targetValue, String referenceValue) {
    String comparison =
        'Location found in image: $targetValue. Reference location: $referenceValue.';

    if (referenceValue.toLowerCase().contains(targetValue.toLowerCase()) ||
        targetValue.toLowerCase().contains(referenceValue.toLowerCase())) {
      comparison += ' Locations appear to match!';
    } else {
      comparison += ' Locations appear to be different.';
    }

    return {
      'title': 'Location Comparison',
      'image_label': 'Image Location',
      'image_value': targetValue,
      'reference_label': 'Reference Location',
      'reference_value_display': referenceValue,
      'reference_source': 'User provided',
      'comparison': comparison,
    };
  }

  Future<Map<String, String>> _compareCurrency(String targetValue, String referenceValue) async {
    final amountMatch = RegExp(r'\d+\.?\d*').firstMatch(targetValue);
    final currencyMatch = RegExp(r'[\$€£¥]|USD|EUR|GBP|JPY').firstMatch(targetValue);

    if (amountMatch != null) {
      final amount = double.tryParse(amountMatch.group(0)!) ?? 0;
      String fromCurrency = 'USD'; // Default
      if (currencyMatch != null) {
        final currencyMap = {'\$': 'USD', '€': 'EUR', '£': 'GBP', '¥': 'JPY'};
        fromCurrency = currencyMap[currencyMatch.group(0)] ?? currencyMatch.group(0)!;
      }

      final toCurrency = referenceValue.toUpperCase();
      final rate = await _getCurrencyRate(fromCurrency, toCurrency);
      final convertedAmount = amount * rate;

      final comparison =
          'Found $amount $fromCurrency in image. Compared to $toCurrency: ${convertedAmount.toStringAsFixed(2)} (rate: ${rate.toStringAsFixed(4)}).';

      return {
        'title': 'Currency Comparison',
        'image_label': 'Image Currency',
        'image_value': targetValue,
        'reference_label': 'Compared to $toCurrency',
        'reference_value_display': convertedAmount.toStringAsFixed(2),
        'reference_source': 'Exchange rate API',
        'comparison': comparison,
      };
    } else {
      final comparison =
          'Currency information in image: $targetValue. Comparing with currency: $referenceValue.';

      return {
        'title': 'Currency Comparison',
        'image_label': 'Image Currency',
        'image_value': targetValue,
        'reference_label': 'Compared to ${referenceValue.toUpperCase()}',
        'reference_value_display': 'N/A',
        'reference_source': 'Exchange rate API',
        'comparison': comparison,
      };
    }
  }

  Future<Map<String, String>> _compareWeather(String targetValue, String referenceValue) async {
    try {
      final weatherData = await _getWeatherDataForCity(referenceValue);
      final currentWeather = weatherData['description'] ?? 'clear sky';
      final temp = weatherData['temperature'] ?? 'N/A';

      String comparison =
          'Weather condition in image: $targetValue. Current weather in $referenceValue: $currentWeather at $temp.';

      if (targetValue.toLowerCase().contains(currentWeather.toLowerCase()) ||
          currentWeather.toLowerCase().contains(targetValue.toLowerCase())) {
        comparison += ' Weather conditions match closely for comparison!';
      } else {
        comparison += ' Weather conditions show differences in comparison.';
      }

      return {
        'title': 'Weather Comparison',
        'image_label': 'Image Weather',
        'image_value': targetValue,
        'reference_label': 'Current Weather',
        'reference_value_display': '$currentWeather, $temp',
        'reference_source': 'Live data for $referenceValue',
        'comparison': comparison,
      };
    } catch (e) {
      return {
        'title': 'Weather Comparison',
        'image_label': 'Image Weather',
        'image_value': targetValue,
        'reference_label': 'Reference Weather',
        'reference_value_display': 'Weather data unavailable',
        'reference_source': referenceValue,
        'comparison':
            'Weather in image: $targetValue. Unable to fetch current weather for comparison with $referenceValue.',
      };
    }
  }

  Map<String, String> _compareGeneral(
      String targetValue, String referenceValue, String additionalContext) {
    String comparison =
        'Information extracted from image: $targetValue. Reference value for comparison: $referenceValue.';

    if (additionalContext.isNotEmpty) {
      comparison += ' Additional context for comparison: $additionalContext.';
    }

    if (referenceValue.toLowerCase().contains(targetValue.toLowerCase()) ||
        targetValue.toLowerCase().contains(referenceValue.toLowerCase())) {
      comparison += ' Values show similarities in comparison analysis.';
    } else {
      comparison += ' Values show differences in comparison analysis.';
    }

    return {
      'title': 'General Comparison',
      'image_label': 'Extracted Info',
      'image_value': targetValue,
      'reference_label': 'Reference Value',
      'reference_value_display': referenceValue,
      'reference_source': 'User provided',
      'comparison': comparison,
    };
  }

  Future<Map<String, String>> _searchProductPrice(String productName) async {
    final mockPrices = {
      'iphone': {'price': '999', 'currency': 'USD', 'source': 'Online Store'},
      'samsung': {'price': '799', 'currency': 'USD', 'source': 'Online Store'},
      'laptop': {'price': '1299', 'currency': 'USD', 'source': 'Online Store'},
      'coffee': {'price': '4.99', 'currency': 'USD', 'source': 'Online Store'},
      'book': {'price': '19.99', 'currency': 'USD', 'source': 'Online Store'},
    };

    for (final entry in mockPrices.entries) {
      if (productName.toLowerCase().contains(entry.key)) {
        return {
          'price': entry.value['price']!,
          'currency': entry.value['currency']!,
          'source': entry.value['source']!,
        };
      }
    }

    return {
      'price': 'Not found',
      'currency': 'USD',
      'source': 'Online Search',
    };
  }

  Future<double> _getCurrencyRate(String fromCurrency, String toCurrency) async {
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        final response = await http
            .get(
              Uri.parse('https://api.exchangerate-api.com/v4/latest/$fromCurrency'),
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return (data['rates'][toCurrency] ?? 1.0).toDouble();
        } else if (response.statusCode == 429) {
          attempt++;
          if (attempt >= maxRetries) break;

          final delay = min(baseDelayMs * attempt, maxDelayMs);
          await Future.delayed(Duration(milliseconds: delay));
          continue;
        } else {
          break;
        }
      } catch (e) {
        print('Currency API error: $e');
        break;
      }
    }
    return 1.0;
  }

  Future<String> _callGeminiAPI(String prompt, String base64Image) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConstants.geminiApiUrl}?key=${AppConstants.geminiApiKey}'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                    {
                      'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image}
                    }
                  ]
                }
              ]
            }),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['candidates'][0]['content']['parts'][0]['text'];
      } else if (response.statusCode == 429) {
        throw ApiException(
          'Rate limit exceeded. Please wait a moment before trying again.',
          429,
        );
      } else if (response.statusCode >= 500) {
        throw ApiException(
          'Server temporarily unavailable. Please try again in a moment.',
          response.statusCode,
        );
      } else {
        String errorMessage = 'Analysis failed';
        try {
          final errorData = json.decode(response.body);
          if (errorData['error'] != null && errorData['error']['message'] != null) {
            errorMessage = errorData['error']['message'];
          }
        } catch (_) {
          // Use default message if can't parse error
        }

        throw ApiException(
          '$errorMessage (Status: ${response.statusCode})',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiException(
        'No internet connection. Please check your network and try again.',
        null,
      );
    } on HttpException {
      throw ApiException(
        'Network error occurred. Please try again.',
        null,
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        'Unexpected error: ${e.toString()}',
        null,
      );
    }
  }

  Future<Map<String, String>> _getWeatherDataForCity(String cityName) async {
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        final response = await http
            .get(
              Uri.parse(
                  '${AppConstants.openWeatherApiUrl}?q=$cityName&appid=${AppConstants.openWeatherApiKey}&units=metric'),
            )
            .timeout(AppConstants.apiTimeout);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return {
            'temperature': '${data['main']['temp'].round()}°C',
            'description': data['weather'][0]['description'],
            'city': cityName,
          };
        } else if (response.statusCode == 429) {
          attempt++;
          if (attempt >= maxRetries) break;

          final delay = min(baseDelayMs * attempt, maxDelayMs);
          await Future.delayed(Duration(milliseconds: delay));
          continue;
        } else {
          break;
        }
      } catch (e) {
        print('Weather API error: $e');
        break;
      }
    }

    return {
      'temperature': 'N/A',
      'description': 'Weather data unavailable',
      'city': cityName,
    };
  }

  Future<bool> checkServerHealth() async {
    try {
      final response = await http
          .get(
            Uri.parse('${AppConstants.geminiApiUrl}?key=${AppConstants.geminiApiKey}'),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 400;
    } catch (e) {
      return false;
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

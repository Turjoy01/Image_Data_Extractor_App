class AppConstants {
  // API Configuration
  static const String geminiApiKey = 'AIzaSyCCIvlGKF0155tqLyeflPzdg-NTav-qlD4';
  static const String openWeatherApiKey = '81a695c7f8b96ec8e214f9aba349a9d5'; // Replace with your OpenWeather API key
  static const String geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  static const String openWeatherApiUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Image Configuration
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1920;
  static const int imageQuality = 85;
  
  static const List<String> supportedImageFormats = [
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff', 'tif', 
    'webp', 'svg', 'ico', 'heic', 'heif', 'avif', 'jfif'
  ];
  
  // App Information
  static const String appName = 'Turjoy\'s Image Analysis & Universal Comparison App';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered image analysis and universal comparison tool';
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String imageError = 'Failed to process image. Please try another image.';
  static const String permissionError = 'Permission denied. Please grant required permissions.';
}

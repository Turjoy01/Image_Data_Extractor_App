🌦️ Image Analysis Application – By Md Mahedi Hasan Turjoy
A cross-platform mobile application built with Flutter that uses AI-powered image analysis (Google Gemini API) and real-time weather data (OpenWeather API) to compare extracted values with live conditions.

✨ Features
📸 AI Image Analysis – Upload or capture an image and analyze with Google Gemini AI
🔍 Smart Comparison – Weather, product labels, quality assessment, and more
🌍 Live Weather Data – Real-time updates from OpenWeather API
📱 Cross-Platform – Works seamlessly on Android & iOS
🎨 Clean UI – Simple, modern, and intuitive user interface
✅ Result Highlighting – Clear match ✅ or mismatch ❌ between extracted and live values

🚀 Quick Start
Prerequisites
Flutter SDK 3.10.0+
Android Studio or VS Code with Flutter extensions
Google Gemini API Key → Get Key
OpenWeather API Key → Get Key

Setup
1️⃣ Install dependencies:
flutter pub get

2️⃣ Configure API keys in lib/utils/constants.dart:
static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
static const String openWeatherApiKey = 'YOUR_OPENWEATHER_API_KEY';

3️⃣ Run the app:
flutter run


🔑 API Keys Setup
Google Gemini API Key
Visit Google AI Studio
Sign in with Google account
Click Create API Key
Copy and save your key
OpenWeather API Key
Sign up at OpenWeatherMap
Go to API Keys section
Copy your default key


📂 Project Structure
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── analysis_request.dart # Request structure
│   ├── analysis_result.dart  # Response structure
│   └── comparison_type.dart  # Enum definitions
├── screens/                  # UI screens
│   └── home_screen.dart     # Main application screen
├── services/                 # Business logic
│   └── api_service.dart     # API integration service
└── widgets/                 # Reusable components
    ├── image_upload_widget.dart
    ├── loading_overlay.dart
    └── result_display_widget.dart


📦 Key Dependencies
flutter – Core framework
provider – State management
http – API communication
image_picker – Camera/gallery image selection
permission_handler – Runtime permissions


🛠️ Usage
Launch the app
📸 Take a photo or select from gallery
Choose comparison type (Weather / Product / Quality)
Enter reference value (e.g., “28°C”)
Add optional context (e.g., city name).
Tap Analyze & Compare
View results → with ✅ match / ❌ mismatch highlighted


⚡ Troubleshooting
🔌 API Issues
Verify valid API keys in constants.dart
Check internet connection
Ensure keys are not expired / rate-limited

🖼️ Image Issues
Grant camera & storage permissions
Use supported formats (JPG, PNG/any type)
Avoid oversized files


🤖 Analysis Errors
Use clear images with visible text
Recheck API key validity
Try different images if one fails


🏗️ Architecture
✅ Direct Google Gemini API calls for AI image analysis
 ✅ Integrated OpenWeather API for live weather data
 ✅ Uses Base64 image encoding for API compatibility
 ✅ Robust error handling & timeouts
 ✅ No backend required – cloud-based processing
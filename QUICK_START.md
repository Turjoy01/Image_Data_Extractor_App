# Quick Start Guide

## Skip Docker - Run Directly!

Since Docker Desktop isn't working, here are 3 simple ways to run the app:

### Option 1: Windows (Easiest)
1. Double-click `start_app.bat`
2. Wait for installation to complete
3. Open browser to `http://localhost:8000`

### Option 2: Command Line
\`\`\`bash
python run_app.py
\`\`\`

### Option 3: Manual
\`\`\`bash
pip install fastapi uvicorn google-generativeai requests Pillow python-multipart
python main.py
\`\`\`

## Your API Keys Are Already Configured!
- ✅ Gemini API: AIzaSyBQ4P5BtlSgqB59Hwk3_PuFeUu5WBpRsM8
- ✅ OpenWeather API: 81a695c7f8b96ec8e214f9aba349a9d5

## What the App Does
1. Upload an image with temperature display
2. Enter a city name
3. AI analyzes the image temperature
4. Compares with live weather data
5. Shows detailed comparison results

No Docker needed - just run and go! 🚀

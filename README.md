# FarmVision AI — Intelligent Livestock Monitoring & Classification System

An advanced artificial intelligence-powered platform developed to identify, classify, and analyze cattle, buffaloes, and other animals using image processing, deep learning, and computer vision techniques.

## 🚀 Features

- **Animal Type Classification**: Instantly detects whether the uploaded image belongs to a **Cattle**, **Buffalo**, or **Other** category.
- **Gender Detection**: Automatically predicts the gender as **Male** or **Female** for cattle and buffaloes by analyzing visual cues (body shape, horn structure, facial appearance, skin texture, and udder presence).
- **Multi-Variable Analytics**:
  - Breed Identification (Holstein Friesian, Gir, Jersey, Sahiwal, Murrah Buffalo, Surti, etc.)
  - Health Condition Analysis (detects tick infestations, dermatitis/scabies, and weight abnormalities)
  - Age Prediction
  - Weight Estimation
  - Milk Production Prediction (automatically set to `Not Applicable` for male animals)
  - Intelligent Feed Recommendations (customized nutritional plans based on breed, age, gender, and health status)
- **Multi-Animal Detection**: Supports counting and highlighting multiple animals in a single frame.
- **Voice Feedback (TTS)**: Synthesizes voice outputs such as *"This is Cattle,"* *"This is Buffalo,"* or *"This belongs to Others"* for enhanced user accessibility.
- **Hybrid AI Engine**:
  - *Online Mode*: Connects to a Python Flask backend powered by TensorFlow (MobileNetV2), OpenCV, and SQLite.
  - *Offline Fallback*: Gracefully degrades to a client-side TF.js and heuristic processing engine so the application remains fully functional without a backend server.

## 🛠️ Technology Stack

- **Frontend**: HTML5, CSS3 (Vanilla), JavaScript (ES6+), FontAwesome Icons, Google Fonts (Outfit & Inter)
- **Client Inference**: TensorFlow.js, MobileNet V2
- **Backend**: Python Flask, OpenCV, TensorFlow/Keras, SQLite (MySQL-compatible)
- **Scripting**: PowerShell (for easy setup)

## 📂 Project Structure

- `index.html`: Modern dashboard layout with camera canvas overlay and insights panel.
- `styles.css`: Dark-themed visual design with glassmorphic cards and glowing accents.
- `app.js`: Frontend logic, state management, webcam stream handling, TF.js pipeline, and TTS execution.
- `app.py`: Flask application, OpenCV contour counting, MobileNet image preprocessing, and SQLite database persistence.
- `start_server.ps1`: Simple helper PowerShell script to start the local environment.

## ⚙️ How to Run

1. **Standalone (Frontend only)**:
   - Double-click `index.html` or start the local server using `start_server.ps1`.
   - The application will run entirely client-side using WebGL-accelerated TF.js.

2. **Full Hybrid Mode (Frontend + Backend)**:
   - Start the Flask backend:
     ```bash
     python app.py
     ```
   - Start the local HTTP server to view the frontend (on port 8000).

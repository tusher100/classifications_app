# 🚦 Traffic Sign Classifier (Flutter + TensorFlow Lite)

This is a **Flutter application** that allows users to classify traffic signs from images using a pre-trained **TensorFlow Lite** model. Built with a clean UI and real-time inference, the app loads a `.tflite` model and predicts the class of traffic signs from gallery images.

---

## ✨ Features

- 📱 Built with **Flutter**
- 🤖 Runs inference using **TFLite** (`tflite_flutter`)
- 🖼️ Image selection from gallery
- 🧠 Real-time traffic sign prediction
- 📊 Displays label and prediction confidence
- 🎨 Beautiful and minimal UI with **Google Fonts**

## Classification Code and dataset
Link: **https://github.com/tusher100/Traffic_Sign_Recognition**

## 📸 Demo
<img width="350" alt="Screenshot_1" src="https://github.com/user-attachments/assets/64914a3e-8c78-4d21-ba6e-911e19c381d4" style="margin-right: 20px;" />

<img width="350" alt="Screenshot_2" src="https://github.com/user-attachments/assets/877c98a8-65fc-44a1-9faf-22a4ffed69b9" />



## 🛠️ Tech Stack

- Flutter
- Dart
- TensorFlow Lite (`tflite_flutter`)
- image_picker
- image (for pixel conversion)
- google_fonts

---

## 📂 Project Structure

```
lib/
├── main.dart
├── home_page.dart
assets/
├── model.tflite
├── labels.txt
```

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone git@github.com:tusher100/classifications_app.git
cd classifications_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Add Assets

Make sure your `assets` directory includes the following:

- `model.tflite` – Trained TensorFlow Lite model
- `labels.txt` – List of class labels (one per line)

Update your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/model.tflite
    - assets/labels.txt
```

### 4. Run the App

```bash
flutter run
```

---

## 🧠 Model Info

- Input shape: `(1, 96, 96, 3)`
- Output: Softmax vector of size equal to number of classes
- Loss: `sparse_categorical_crossentropy`

---

## 📷 How It Works

1. User selects an image from the gallery.
2. The image is resized and normalized.
3. It is passed to the TFLite model for inference.
4. The predicted label and confidence score are displayed.

---

## 🧪 Sample Code Snippet

```dart
final output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);
_interpreter!.run(input4D, output);
final scores = output[0].cast<double>();
```

---

## 📌 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  image_picker: ^1.0.4
  image: ^4.1.3
  tflite_flutter: ^0.10.0
  google_fonts: ^6.1.0
```

---

## 🛡️ License

This project is licensed under the MIT License.

---

## 🙌 Acknowledgements

- TensorFlow Lite team
- Flutter community
- Open-source datasets for traffic signs

---

## 👨‍💻 Author

**Md Mahbubur Rahman Tusher**  
📧 [Connect on GitHub](https://github.com/tusher100)

---

⭐️ *If you found this helpful, give the repo a star!*


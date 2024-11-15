# FaceGuard

FaceGuard is a Flutter-based facial recognition and comparison app that leverages Google ML Kit for face detection. The app allows users to pick images from the gallery or capture new images using the camera, and then compare them for similarity. This can be useful for authentication, verification, and analysis purposes.

## Features

- **Image Selection**: Users can select images for face recognition from their gallery or capture new images using their device's camera.
- **Face Detection and Comparison**: Utilizes Google ML Kit's face detection to recognize faces in images and compare facial features.
- **Face Matching Results**: Provides a comparison result showing matched and non-matched faces with similarity percentages.
- **Customizable Transitions**: Users can switch between different animation styles (Slide or Fade) for a more interactive experience.

## Screens

1. **FaceRecognitionScreen**: 
   - Handles image selection, face detection, and comparison. 
   - Displays a list of matched and non-matched faces based on similarity.

2. **AppInfoScreen**: 
   - Provides an overview of the app's purpose and instructions for usage.

3. **SettingsScreen**: 
   - Allows users to toggle between Slide and Fade transition effects for dialogs and animations.

## Dependencies

This project utilizes the following dependencies:

- [flutter_spinkit](https://pub.dev/packages/flutter_spinkit): For loading animations.
- [google_mlkit_face_detection](https://pub.dev/packages/google_mlkit_face_detection): For face detection and feature extraction.
- [image_picker](https://pub.dev/packages/image_picker): For selecting images from the gallery or capturing via the camera.
- [permission_handler](https://pub.dev/packages/permission_handler): For handling camera and storage permissions.

## Getting Started

To run this project:

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd faceguard
DEVELOPER:
SOFTWARE ENGINEER MUHAMMAD UWAIM QURESHI

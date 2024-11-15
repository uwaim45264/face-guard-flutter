import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';



class FaceRecognitionScreen extends StatefulWidget {
  const FaceRecognitionScreen({Key? key}) : super(key: key);

  @override
  _FaceRecognitionScreenState createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _pickedImages = [];
  List<File> _knownImages = [];
  bool _isProcessing = false;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableContours: true, enableClassification: true,),
  );

  List<Map<String, dynamic>> _matchedFaces = [];
  List<Map<String, dynamic>> _nonMatchedFaces = [];

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    await Permission.camera.request();
    await Permission.storage.request();
  }

  Future<void> _pickImages(ImageSource source, List<File> imageList) async {
    final pickedFiles = await _picker.pickMultiImage();
    setState(() {
      imageList.addAll(pickedFiles.map((pickedFile) => File(pickedFile.path)));
    });
  }

  Future<void> _pickImageFromGallery() async {
    _pickImages(ImageSource.gallery, _pickedImages);
  }

  Future<void> _pickKnownImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final InputImage inputImage = InputImage.fromFile(imageFile);

      final List<Face> faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        setState(() {
          _knownImages.add(imageFile);
        });
      } else {
        _showNoFaceDetectedDialog();
      }
    }
  }

  Future<void> _recognizeFaces() async {
    if (_pickedImages.isNotEmpty && _knownImages.isNotEmpty) {
      setState(() {
        _isProcessing = true;
        _matchedFaces.clear();
        _nonMatchedFaces.clear();
      });

      for (var knownImage in _knownImages) {
        final knownInputImage = InputImage.fromFile(knownImage);
        final knownFaces = await _faceDetector.processImage(knownInputImage);

        for (var pickedImage in _pickedImages) {
          final pickedInputImage = InputImage.fromFile(pickedImage);
          final pickedFaces = await _faceDetector.processImage(pickedInputImage);

          bool matchFound = false;
          for (var pickedFace in pickedFaces) {
            for (var knownFace in knownFaces) {
              double similarity = _calculateSimilarity(pickedFace, knownFace);

              if (similarity > 0.5) {
                matchFound = true;
                setState(() {
                  _matchedFaces.add({
                    'image': pickedImage,
                    'similarity': similarity,
                  });
                });
              } else {
                setState(() {
                  _nonMatchedFaces.add({
                    'image': pickedImage,
                    'similarity': similarity,
                  });
                });
              }
              break;
            }
          }
        }
      }

      setState(() {
        _isProcessing = false;
      });

      _showSummaryDialog();
    }
  }

  double _calculateSimilarity(Face face1, Face face2) {
    final rect1 = face1.boundingBox;
    final rect2 = face2.boundingBox;

    final double interLeft = rect1.left > rect2.left ? rect1.left : rect2.left;
    final double interTop = rect1.top > rect2.top ? rect1.top : rect2.top;
    final double interRight = rect1.right < rect2.right ? rect1.right : rect2.right;
    final double interBottom = rect1.bottom < rect2.bottom ? rect1.bottom : rect2.bottom;

    final double interArea = (interRight - interLeft) * (interBottom - interTop);
    final double area1 = (rect1.right - rect1.left) * (rect1.bottom - rect1.top);
    final double area2 = (rect2.right - rect2.left) * (rect2.bottom - rect2.top);
    final double unionArea = area1 + area2 - interArea;

    return interArea / unionArea;
  }

  void _showNoFaceDetectedDialog() {
    _showCustomDialog(
      title: 'No Face Detected',
      content: Text('Please capture an image that contains a face.'),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.teal),
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      animationType: 'scale', // Custom scale animation
    );
  }

  void _showSummaryDialog() {
    _showCustomDialog(
      title: 'Comparison Result',
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Matched Faces:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            Text(
              'Matched Faces Count: ${_matchedFaces.length}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            _matchedFaces.isEmpty
                ? const Text('No matched faces.', style: TextStyle(color: Colors.black54))
                : _buildFaceGrid(_matchedFaces, Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Non-Matched Faces:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            Text(
              'Non-Matched Faces Count: ${_nonMatchedFaces.length}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            _nonMatchedFaces.isEmpty
                ? const Text('No non-matched faces.', style: TextStyle(color: Colors.black54))
                : _buildFaceGrid(_nonMatchedFaces, Colors.red),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.teal),
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      animationType: 'fade', // Custom fade animation for the summary
    );
  }

  // Reusable custom dialog function with different animation types
  void _showCustomDialog({
    required String title,
    required Widget content,
    required List<Widget> actions,
    String animationType = 'fade', // Default animation type
    Duration transitionDuration = const Duration(milliseconds: 500),
  }) {
    Widget dialogWidget = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: content,
      actions: actions,
    );

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, anim1, anim2) {
        switch (animationType) {
          case 'scale':
            return ScaleTransition(
              scale: CurvedAnimation(parent: anim1, curve: Curves.easeInOut),
              child: dialogWidget,
            );
          case 'slide':
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                  .animate(CurvedAnimation(parent: anim1, curve: Curves.easeInOut)),
              child: dialogWidget,
            );
          case 'fade':
          default:
            return FadeTransition(
              opacity: CurvedAnimation(parent: anim1, curve: Curves.easeInOut),
              child: dialogWidget,
            );
        }
      },
      transitionDuration: transitionDuration,
    );
  }

  Widget _buildFaceGrid(List<Map<String, dynamic>> faces, Color color) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: faces.length,
      itemBuilder: (context, index) {
        return AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: Transform.scale(
            scale: 1.0,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      faces[index]['image'],
                      fit: BoxFit.cover,
                      height: 80,
                      width: 80,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Similarity: ${(faces[index]['similarity'] * 100).toStringAsFixed(2)}%',
                  style: TextStyle(fontSize: 14, color: color),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Animated button with ripple effect
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTapDown: (_) => setState(() {}), // Required for tap animation
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(isPrimary ? 0.97 : 1.0),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 24),
          label: Text(label, style: const TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            foregroundColor: isPrimary ? Colors.white : Colors.indigo,
            backgroundColor: isPrimary ? Colors.teal : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            shadowColor: Colors.black38,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(int index, List<File> imageList) {
    _showCustomDialog(
      title: 'Delete Image',
      content: const Text('Are you sure you want to delete this image?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              imageList.removeAt(index);
            });
            Navigator.of(context).pop();
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
      animationType: 'slide', // Custom slide animation for delete dialog
      transitionDuration: const Duration(milliseconds: 600),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FaceGuard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/info');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.teal.shade700
                  : Colors.indigo.shade600,
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.indigo.shade400
                  : Colors.teal.shade300
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          children: [
            _buildImageSection('Images for Recognition', _pickedImages),
            const SizedBox(height: 20),
            _buildActionButton(
              label: 'Pick Images for Recognition',
              icon: Icons.image_search,
              onPressed: _pickImageFromGallery,
            ),
            const SizedBox(height: 30),
            _buildImageSection('Captured Known Images', _knownImages),
            const SizedBox(height: 20),
            _buildActionButton(
              label: 'Capture Known Image',
              icon: Icons.camera_alt,
              onPressed: _pickKnownImageFromCamera,
            ),
            const SizedBox(height: 30),
            _isProcessing
                ? Center(child: SpinKitFadingCircle(color: Colors.white, size: 50)) // Enhanced loading
                : _buildActionButton(
              label: 'Compare Faces',
              icon: Icons.compare_arrows,
              onPressed: _recognizeFaces,
              isPrimary: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(String title, List<File> images) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        images.isEmpty
            ? const Text('No images selected', style: TextStyle(color: Colors.white70))
            : GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      images[index],
                      fit: BoxFit.cover,
                      height: 100,
                      width: 100,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmationDialog(index, images);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

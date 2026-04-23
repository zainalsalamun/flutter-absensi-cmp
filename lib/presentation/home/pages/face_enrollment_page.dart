import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/core/core.dart';
import 'package:flutter_absensi_app/data/datasources/face_remote_datasource.dart';

class FaceEnrollmentPage extends StatefulWidget {
  const FaceEnrollmentPage({super.key});

  @override
  State<FaceEnrollmentPage> createState() => _FaceEnrollmentPageState();
}

class _FaceEnrollmentPageState extends State<FaceEnrollmentPage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isTakingPhoto = false;
  XFile? _capturedPhoto;
  bool _isLoading = false;
  bool _isEnrolled = false;

  late Size size;
  CameraLensDirection camDirec = CameraLensDirection.front;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    _initializeCamera();
  }

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);
    final result = await FaceRemoteDatasource().checkFaceStatus();
    result.fold(
      (l) {
        setState(() {
          _isEnrolled = false;
          _isLoading = false;
        });
      },
      (r) {
        setState(() {
          _isEnrolled = r['is_enrolled'] == true;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final cameraDescription = cameras.firstWhere(
      (camera) => camera.lensDirection == camDirec,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null) return;

    setState(() {
      _isTakingPhoto = true;
    });

    final XFile photo = await _cameraController!.takePicture();

    setState(() {
      _capturedPhoto = photo;
      _isTakingPhoto = false;
    });
  }

  void _reverseCamera() {
    setState(() {
      camDirec = camDirec == CameraLensDirection.front
          ? CameraLensDirection.back
          : CameraLensDirection.front;
    });
    _initializeCamera();
  }

  void _retakePhoto() {
    setState(() {
      _capturedPhoto = null;
    });
  }

  Future<void> _submitFace() async {
    if (_capturedPhoto == null) return;

    setState(() {
      _isLoading = true;
    });

    final result = await FaceRemoteDatasource().enrollFace(_capturedPhoto!.path);
    
    result.fold(
      (l) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l), backgroundColor: AppColors.red),
        );
      },
      (r) {
        setState(() {
          _isLoading = false;
          _isEnrolled = true;
          _capturedPhoto = null; // Clear to go back to camera view or we can pop
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wajah berhasil didaftarkan!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      },
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    if (_isLoading && _capturedPhoto == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_capturedPhoto != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Konfirmasi Wajah'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _retakePhoto,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Image.file(
                File(_capturedPhoto!.path),
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _retakePhoto,
                          child: const Text('Ulangi Foto'),
                        ),
                        ElevatedButton(
                          onPressed: _submitFace,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Daftarkan Wajah'),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEnrolled ? 'Update Wajah Anda' : 'Daftarkan Wajah Anda'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned(
              top: 0.0,
              left: 0.0,
              width: size.width,
              height: size.height,
              child: AspectRatio(
                aspectRatio: _cameraController!.value.aspectRatio,
                child: CameraPreview(_cameraController!),
              ),
            ),
            Positioned(
              bottom: 30.0,
              left: 0.0,
              right: 0.0,
              child: Column(
                children: [
                  if (_isEnrolled)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Wajah Anda Sudah Terdaftar',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: _reverseCamera,
                        icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 40),
                      ),
                      GestureDetector(
                        onTap: _isTakingPhoto ? null : _takePhoto,
                        child: const Icon(
                          Icons.circle,
                          size: 80.0,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 40), // Spacer equivalent
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

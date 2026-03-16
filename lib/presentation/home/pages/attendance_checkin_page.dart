import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart.dart';
import 'package:image_picker/image_picker.dart';
import '../../presentation/home/bloc/checkin_attendance/checkin_attendance_bloc.dart';
import '../../presentation/home/pages/attendance_success_page.dart';
import '../../presentation/home/pages/location_page.dart';
import '../../../core/core.dart';

class AttendanceCheckinPage extends StatefulWidget {
  const AttendanceCheckinPage({super.key});

  @override
  State<AttendanceCheckinPage> createState() => _AttendanceCheckinPageState();
}

class _AttendanceCheckinPageState extends State<AttendanceCheckinPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _capturedPhoto;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isTakingPhoto = false;

  late Size size;
  CameraLensDirection camDirec = CameraLensDirection.front;

  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    getCurrentPosition();
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

  void _confirmPhoto() {
    if (_capturedPhoto == null) return;
    _submitAttendance();
  }

  void _retakePhoto() {
    setState(() {
      _capturedPhoto = null;
    });
  }

  Future<void> _submitAttendance() async {
    if (latitude == null || longitude == null) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
        latitude = position.latitude;
        longitude = position.longitude;
      } catch (e) {
        // ignore
      }
    }

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi belum ditemukan, pastikan GPS aktif.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_capturedPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto belum diambil.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Convert photo to multipart file
    final photoFile = File(_capturedPhoto!.path);
    final request = CheckInOutRequestModel(
      latitude: latitude.toString(),
      longitude: longitude.toString(),
      photo: await photoFile.readAsBytes(),
    );

    if (mounted) {
      context.read<CheckinAttendanceBloc>().add(
        CheckinAttendanceEvent.checkinWithPhoto(request),
      );
    }
  }

  Future<void> getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      if (mounted) {
        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    if (!_isCameraInitialized || _cameraController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_capturedPhoto != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Konfirmasi Foto'),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _retakePhoto,
                    child: const Text('Ulangi Foto'),
                  ),
                  ElevatedButton(
                    onPressed: _confirmPhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Kirim Absen'),
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
              bottom: 5.0,
              left: 0.0,
              right: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.47),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Absensi Datang',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Kantor',
                                style: TextStyle(color: AppColors.white),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              context.push(
                                LocationPage(
                                  latitude: latitude,
                                  longitude: longitude,
                                ),
                              );
                            },
                            child: Assets.images.seeLocation.image(
                              height: 30.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SpaceHeight(15.0),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _reverseCamera,
                          icon: Assets.icons.reverse.svg(width: 48.0),
                        ),
                        const Spacer(),
                        BlocConsumer<
                          CheckinAttendanceBloc,
                          CheckinAttendanceState
                        >(
                          listener: (context, state) {
                            state.maybeWhen(
                              orElse: () {},
                              error: (message) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              },
                              loaded: (responseModel) {
                                context.pushReplacement(
                                  const AttendanceSuccessPage(
                                    status: 'Berhasil Checkin',
                                  ),
                                );
                              },
                            );
                          },
                          builder: (context, state) {
                            return state.maybeWhen(
                              orElse: () {
                                return IconButton(
                                  onPressed: _isTakingPhoto ? null : _takePhoto,
                                  icon: const Icon(
                                    Icons.circle,
                                    size: 70.0,
                                    color: AppColors.red,
                                  ),
                                );
                              },
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                        const Spacer(),
                        const SpaceWidth(48.0),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

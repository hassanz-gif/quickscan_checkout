import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

class CameraScanningScreen extends StatefulWidget {
  const CameraScanningScreen({super.key});

  @override
  State<CameraScanningScreen> createState() => _CameraScanningScreenState();
}

class _CameraScanningScreenState extends State<CameraScanningScreen> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _initCamera() async {
    final granted = await _requestCameraPermission();
    if (!granted) {
      setState(() {
        _cameraError = 'Camera permission denied. Please enable it in settings.';
      });
      return;
    }
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _cameraError = 'No cameras found on this device.');
        return;
      }
      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first,
            )
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first,
            );

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false,
      );
      await _cameraController!.initialize();

      try {
        await _cameraController!.setFocusMode(FocusMode.auto);
      } catch (_) {}
      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.off);
        } catch (_) {}
      }

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cameraError = 'Failed to initialize camera.');
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);
    try {
      final XFile photo = await _cameraController!.takePicture();
      String? savedPath;

      if (!kIsWeb) {
        try {
          final dir = await getApplicationDocumentsDirectory();
          final scansDir = Directory('${dir.path}/CheckoutPhotos');
          if (!await scansDir.exists()) {
            await scansDir.create(recursive: true);
          }
          final fileName =
              'checkout_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final saved =
              await File(photo.path).copy('${scansDir.path}/$fileName');
          savedPath = saved.path;
        } catch (_) {
          savedPath = photo.path;
        }
      }

      if (mounted) {
        await Navigator.of(context, rootNavigator: true).pushNamed(
          '/email-collection-screen',
          arguments: {'photoPath': savedPath ?? photo.path},
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to capture photo. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(theme),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(4.w, 6.h, 4.w, 3.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Makerspace Checkout',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Position items in frame, then tap the button',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          ..._buildCornerGuides(theme),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 6.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Center(
                child: GestureDetector(
                  onTap: _isCameraInitialized && !_isCapturing
                      ? _capturePhoto
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isCapturing
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.white,
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isCapturing
                          ? SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          : CustomIconWidget(
                              iconName: 'camera_alt',
                              color: theme.colorScheme.primary,
                              size: 36,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerGuides(ThemeData theme) {
    const double size = 28;
    const double thickness = 3;
    final color = theme.colorScheme.primary;

    Widget corner({
      required AlignmentGeometry alignment,
      required BorderRadius radius,
      required Border border,
    }) {
      return Align(
        alignment: alignment,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: border,
            borderRadius: radius,
          ),
        ),
      );
    }

    return [
      Positioned(
        top: 18.h,
        left: 6.w,
        right: 6.w,
        bottom: 18.h,
        child: Stack(
          children: [
            corner(
              alignment: Alignment.topLeft,
              radius: const BorderRadius.only(topLeft: Radius.circular(6)),
              border: Border(
                top: BorderSide(color: color, width: thickness),
                left: BorderSide(color: color, width: thickness),
              ),
            ),
            corner(
              alignment: Alignment.topRight,
              radius: const BorderRadius.only(topRight: Radius.circular(6)),
              border: Border(
                top: BorderSide(color: color, width: thickness),
                right: BorderSide(color: color, width: thickness),
              ),
            ),
            corner(
              alignment: Alignment.bottomLeft,
              radius: const BorderRadius.only(bottomLeft: Radius.circular(6)),
              border: Border(
                bottom: BorderSide(color: color, width: thickness),
                left: BorderSide(color: color, width: thickness),
              ),
            ),
            corner(
              alignment: Alignment.bottomRight,
              radius: const BorderRadius.only(bottomRight: Radius.circular(6)),
              border: Border(
                bottom: BorderSide(color: color, width: thickness),
                right: BorderSide(color: color, width: thickness),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildCameraPreview(ThemeData theme) {
    if (_cameraError != null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.camera_enhance_outlined,
                    color: Colors.white54, size: 48),
                SizedBox(height: 2.h),
                Text(
                  _cameraError!,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                TextButton(
                  onPressed: () {
                    setState(() => _cameraError = null);
                    _initCamera();
                  },
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return CameraPreview(_cameraController!);
  }
}

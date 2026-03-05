import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/scanned_items_list_widget.dart';
import './widgets/scanning_overlay_widget.dart';

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
  bool _hasPermission = false;
  String? _cameraError;

  final List<Map<String, dynamic>> _scannedItems = [];

  final List<Map<String, dynamic>> _mockRecognizedItems = [
    {
      "id": 1,
      "name": "Organic Green Tea",
      "price": 8.99,
      "quantity": 1,
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1298e33ac-1772696549384.png",
      "semanticLabel": "Box of organic green tea with green packaging",
    },
    {
      "id": 2,
      "name": "Whole Grain Bread",
      "price": 4.49,
      "quantity": 1,
      "image":
          "https://images.unsplash.com/photo-1618194696460-202623a57e02",
      "semanticLabel": "Sliced whole grain bread loaf on wooden cutting board",
    },
    {
      "id": 3,
      "name": "Fresh Orange Juice",
      "price": 5.99,
      "quantity": 1,
      "image":
          "https://images.unsplash.com/photo-1503624141236-2bd972ca51f7",
      "semanticLabel": "Glass of fresh orange juice with oranges",
    },
    {
      "id": 4,
      "name": "Greek Yogurt",
      "price": 3.49,
      "quantity": 1,
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_18d43e79d-1772289482461.png",
      "semanticLabel": "White cup of creamy Greek yogurt on marble surface",
    },
  ];

  int _mockItemIndex = 0;

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
        _hasPermission = false;
        _cameraError =
            'Camera permission denied. Please enable it in settings.';
      });
      return;
    }
    setState(() => _hasPermission = true);
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
      await _savePhotoToFolder(photo);
      _recognizeItem();
    } catch (_) {
      _recognizeItem();
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _savePhotoToFolder(XFile photo) async {
    if (kIsWeb) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final scansDir = Directory('${dir.path}/ScannedItems');
      if (!await scansDir.exists()) {
        await scansDir.create(recursive: true);
      }
      final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(photo.path).copy('${scansDir.path}/$fileName');
    } catch (_) {}
  }

  void _recognizeItem() {
    if (_mockRecognizedItems.isEmpty) return;
    final recognized =
        _mockRecognizedItems[_mockItemIndex % _mockRecognizedItems.length];
    _mockItemIndex++;

    setState(() {
      final existingIndex = _scannedItems.indexWhere(
        (item) => item['id'] == recognized['id'],
      );
      if (existingIndex >= 0) {
        _scannedItems[existingIndex]['quantity'] =
            (_scannedItems[existingIndex]['quantity'] as int) + 1;
      } else {
        _scannedItems.add(Map<String, dynamic>.from(recognized));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recognized: ${recognized['name']}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeItem(int id) {
    setState(() {
      _scannedItems.removeWhere((item) => item['id'] == id);
    });
  }

  void _proceedToCheckout() {
    if (_scannedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please scan at least one item before checkout.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed('/email-collection-screen');
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
      appBar: CustomAppBar(
        title: 'Scan Items',
        showBackButton: false,
        variant: CustomAppBarVariant.solid,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _scannedItems.clear();
                  _mockItemIndex = 0;
                });
              },
              icon: CustomIconWidget(
                iconName: 'refresh',
                color: theme.colorScheme.primary,
                size: 22,
              ),
              tooltip: 'Clear all',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildCameraPreview(theme),
                      ScanningOverlayWidget(isCapturing: _isCapturing),
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: _isCameraInitialized && !_isCapturing
                                ? _capturePhoto
                                : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isCapturing
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : Colors.white,
                                border: Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isCapturing
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: theme.colorScheme.primary,
                                        ),
                                      )
                                    : CustomIconWidget(
                                        iconName: 'camera_alt',
                                        color: theme.colorScheme.primary,
                                        size: 30,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Scanned Items (${_scannedItems.length})',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_scannedItems.isNotEmpty)
                          Text(
                            'Total: \$${_scannedItems.fold<double>(0, (s, i) => s + (i['price'] as double) * (i['quantity'] as int)).toStringAsFixed(2)}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Expanded(
                      child: ScannedItemsListWidget(
                        items: _scannedItems,
                        onRemove: _removeItem,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _proceedToCheckout,
                        icon: CustomIconWidget(
                          iconName: 'shopping_cart_checkout',
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text('Proceed to Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                CustomIconWidget(
                  iconName: 'camera_off',
                  color: Colors.white54,
                  size: 48,
                ),
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

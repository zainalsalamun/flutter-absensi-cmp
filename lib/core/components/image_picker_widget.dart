import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/core/constants/variables.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/colors.dart';
import 'buttons.dart';
import 'spaces.dart';

class ImagePickerWidget extends StatefulWidget {
  final String label;
  final void Function(XFile? file) onChanged;
  final bool showLabel;
  final String? imageUrl;

  const ImagePickerWidget({
    super.key,
    required this.label,
    required this.onChanged,
    this.showLabel = true,
    this.imageUrl,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  String? imagePath;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
    );

    setState(() {
      if (pickedFile != null) {
        imagePath = pickedFile.path;
        widget.onChanged(pickedFile);
      } else {
        debugPrint('No image selected.');
        widget.onChanged(null);
      }
    });
  }

  void _showSelectionDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SpaceHeight(20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SelectionItem(
                    icon: Icons.photo_library,
                    label: 'Galeri',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  _SelectionItem(
                    icon: Icons.camera_alt,
                    label: 'Kamera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ],
              ),
              const SpaceHeight(20.0),
            ],
          ),
        );
      },
    );
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SpaceHeight(12.0),
        ],
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: AppColors.primary),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 80.0,
                height: 80.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: imagePath != null
                      ? Image.memory(
                          File(imagePath!).readAsBytesSync(),
                          fit: BoxFit.cover,
                        )
                      : widget.imageUrl != null
                          ? Image.network(
                              widget.imageUrl!.startsWith('http')
                                  ? widget.imageUrl!
                                  : widget.imageUrl!.startsWith('storage/')
                                      ? '${Variables.baseUrl}/${widget.imageUrl}'
                                      : '${Variables.baseUrl}/storage/${widget.imageUrl}',
                              fit: BoxFit.cover,
                            )
                          : Container(
                              padding: const EdgeInsets.all(0.0),
                              color: AppColors.black.withOpacity(0.05),
                              child: Icon(
                                Icons.camera_alt,
                                color: AppColors.black.withOpacity(0.3),
                                size: 40.0,
                              ),
                            ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Button.filled(
                  height: 50.0,
                  width: 132.0,
                  onPressed: _showSelectionDialog,
                  label: 'Pilih Foto',
                  fontSize: 12.0,
                  borderRadius: 10.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SelectionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 32.0,
            ),
          ),
          const SpaceHeight(8.0),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

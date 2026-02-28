import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../core/constants.dart';

class PlayerPhotoUpload extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? imageFileName;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const PlayerPhotoUpload({
    super.key,
    required this.imageBytes,
    required this.imageFileName,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: imageBytes != null
          ? _buildPreview()
          : _buildEmpty(),
    );
  }

  Widget _buildEmpty() {
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 40,
              color: AppColors.gray,
            ),
            const SizedBox(height: 8),
            const Text(
              'Click to upload player photo',
              style: TextStyle(color: AppColors.gray),
            ),
            const SizedBox(height: 4),
            const Text(
              'JPG, PNG, WebP up to 5MB',
              style: TextStyle(color: AppColors.gray, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          child: Image.memory(
            imageBytes!,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppConstants.radiusSmall),
                bottomRight: Radius.circular(AppConstants.radiusSmall),
              ),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Text(
              imageFileName ?? 'player_photo',
              style: const TextStyle(color: AppColors.white, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 18),
              color: AppColors.error,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
            ),
          ),
        ),
      ],
    );
  }
}

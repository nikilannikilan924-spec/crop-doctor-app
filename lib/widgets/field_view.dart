import 'package:flutter/material.dart';

class FieldView extends StatelessWidget {
  final String cropName;
  final String cropIcon;
  final double suitability;
  final bool isSelected;

  const FieldView({
    super.key,
    required this.cropName,
    required this.cropIcon,
    required this.suitability,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF2E7D32).withOpacity(0.15)
            : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF2E7D32)
              : const Color(0xFF81C784).withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            cropIcon,
            style: TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 4),
          Text(
            cropName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFF4E342E),
            ),
          ),
          const SizedBox(height: 2),
          if (suitability > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: _suitabilityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${suitability.round()}%',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: _suitabilityColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color get _suitabilityColor {
    if (suitability >= 80) return const Color(0xFF4CAF50);
    if (suitability >= 60) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }
}

class FieldGrid extends StatelessWidget {
  final List<Map<String, dynamic>> crops;
  final String? selectedCrop;
  final void Function(String crop)? onCropTap;

  const FieldGrid({
    super.key,
    required this.crops,
    this.selectedCrop,
    this.onCropTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(Icons.grid_view_rounded, size: 18, color: Colors.green[700]),
              const SizedBox(width: 6),
              Text(
                'Your Field Map',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[900],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              childAspectRatio: 0.85,
            ),
            itemCount: crops.length.clamp(0, 9),
            itemBuilder: (context, index) {
              final crop = crops[index];
              return GestureDetector(
                onTap: () => onCropTap?.call(crop['name']),
                child: FieldView(
                  cropName: crop['name'] ?? '',
                  cropIcon: crop['icon'] ?? '🌱',
                  suitability: (crop['suitability'] ?? 0).toDouble(),
                  isSelected: selectedCrop == crop['name'],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

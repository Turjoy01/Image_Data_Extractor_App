import 'package:flutter/material.dart';
import '../models/comparison_type.dart';

class ComparisonTypeSelector extends StatelessWidget {
  final ComparisonType selectedType;
  final Function(ComparisonType) onTypeChanged;

  const ComparisonTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparison Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ComparisonType>(
              value: selectedType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: ComparisonType.values.map((type) {
                return DropdownMenuItem<ComparisonType>(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (ComparisonType? newType) {
                if (newType != null) {
                  onTypeChanged(newType);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

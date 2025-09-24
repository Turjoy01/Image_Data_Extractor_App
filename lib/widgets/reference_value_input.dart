import 'package:flutter/material.dart';
import '../models/comparison_type.dart';

class ReferenceValueInput extends StatelessWidget {
  final String value;
  final ComparisonType comparisonType;
  final Function(String) onChanged;

  const ReferenceValueInput({
    super.key,
    required this.value,
    required this.comparisonType,
    required this.onChanged,
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
              'Reference Value',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: value,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: comparisonType.placeholder,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: onChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a reference value';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AdditionalContextInput extends StatelessWidget {
  final String value;
  final Function(String) onChanged;

  const AdditionalContextInput({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Context (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: value,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Any specific details to look for or compare',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 3,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:khaata/app/style.dart';


/// Individual settings entry in the settings section. This is wrapped
/// by Settings main widget.
class SettingsEntry extends StatelessWidget {
  const new({super.key, required this.label, required this.description, required this.controlWidget});

  /// The label of entry.
  final String label;

  /// Brief description or hint for this entry.
  final String description;

  /// The widget that controls this setting.
  final Widget controlWidget;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          description,
          style: Theme.of(context)
                       .textTheme
                       .bodySmall
                      ?.copyWith(color: Theme.of(context).hintColor),
        ),
        SizedBox(height: AppSpacing.sm),
        controlWidget,
      ],
    );
  }
}
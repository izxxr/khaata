import 'package:flutter/material.dart';
import 'package:khaata/app/style.dart';

class QuickActionButton extends StatelessWidget {
  const new({super.key, required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(AppSpacing.sm + 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: AppSpacing.sm,
            children: [
              Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis, // Adds '...' at the end
              )
            ],
          ),
        ),
      )
    );
  }
}
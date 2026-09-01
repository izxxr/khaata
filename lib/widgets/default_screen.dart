import 'package:flutter/material.dart';
import 'package:khaata/app/style.dart';


/// Generic default screen with representative icon and some text.
/// 
/// This is used for representing "empty" screens.
class DefaultScreen extends StatelessWidget {
  const new({super.key, required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2,
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: AppSpacing.md,
          children: [
            Icon(icon, size: 100),
            SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              subtitle,
              style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Theme.of(context).hintColor),
            ),
          ]
        )
      ),
    );
  }
}
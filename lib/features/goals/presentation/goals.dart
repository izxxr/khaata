import 'package:flutter/material.dart';
import 'package:khaata/app/style.dart';


/// Widget for the "Goals" section.
class Goals extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.globalPadding),
      children: [
        Text(
          "Goals",
          style: Theme.of(context).textTheme.titleLarge
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          "Set and track fund collection goals",
          style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: Theme.of(context).hintColor),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height - kToolbarHeight, 
          width: double.infinity,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: AppSpacing.md,
              children: [
                Icon(Icons.hourglass_bottom, size: 100),
                SizedBox(height: AppSpacing.md),
                Text(
                  "Coming soon...",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  "This feature is currently under development",
                  style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Theme.of(context).hintColor),
                ),
              ]
            )
          ),
        ),
      ],
    );
  }
}

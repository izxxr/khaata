import 'package:flutter/material.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/widgets/default_screen.dart';


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
        DefaultScreen(
          icon: Icons.hourglass_bottom,
          title: "Coming soon...",
          subtitle: "This feature is currently under development"
        )
      ],
    );
  }
}

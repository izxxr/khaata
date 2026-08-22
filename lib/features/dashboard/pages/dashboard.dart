import 'package:flutter/material.dart';
import 'package:khaata/features/dashboard/widgets/overview_card.dart';


/// Dashboard widget for the home screen.
class Dashboard extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        OverviewCard(),
      ]
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/app/bloc/app_bloc.dart';


/// Overview card for presenting user's balance and important details
class OverviewCard extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.globalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.sm,
          children: [
            Text(
              "Welcome back,",
              style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                          ?.copyWith(color: Theme.of(context).disabledColor)
            ),
            Text(
              context.read<AppBloc>().state.username?.toUpperCase() ?? "DEFAULT USER",
              style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)
            ),
            Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.refresh),
                ),
                Spacer(),
                Column(
                  spacing: AppSpacing.xs,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Balance",
                      style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: Theme.of(context).hintColor),
                    ),
                    Text(
                      "4316.00",
                      style: Theme.of(context).textTheme.headlineMedium,
                    )
                  ]
                ),
              ]
            ),
          ],
        ),
      ),
    );
  }
}
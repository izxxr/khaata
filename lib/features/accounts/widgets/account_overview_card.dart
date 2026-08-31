import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/features/transactions/services/transaction_repository.dart';

class AccountOverviewCard extends StatefulWidget {
  const new({super.key, required this.accountIds, this.before, this.after});

  final List<int> accountIds;
  final DateTime? before;
  final DateTime? after;

  @override
  State<AccountOverviewCard> createState() => _AccountOverviewCardState();
}

class _AccountOverviewCardState extends State<AccountOverviewCard> {
  late Stream<(int, int, int)> _balanceStream;

  @override
  void initState() {
    super.initState();

    _balanceStream = context.read<TransactionRepository>().watchAmounts(
      widget.accountIds,
      before: widget.before,
      after: widget.after,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(5)
      ),
      width: double.infinity,
      child: StreamBuilder(
        stream: _balanceStream,
        builder: (context, snapshot) {
          Widget child;

          if (snapshot.connectionState == ConnectionState.waiting) {
            child = CircularProgressIndicator();
          }
          else if (snapshot.data == null || snapshot.hasError) {
            child = Text("0.00", style: Theme.of(context).textTheme.headlineLarge);
          }
          else {
            child = Text((snapshot.data!.$1 / 100).toStringAsFixed(2), style: Theme.of(context).textTheme.headlineLarge);
          }

          return Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Balance",
                        style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Theme.of(context).hintColor)
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          child,
                        ]
                      ),
                    ]
                  ),
                  Spacer(),
                  IconButton(onPressed: () {}, icon: Icon(Icons.refresh)),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Income",
                        style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Theme.of(context).hintColor)
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        ((snapshot.data ?? (0, 0, 0)).$2 / 100).toStringAsFixed(2),
                        style: Theme.of(context)
                                     .textTheme
                                     .headlineSmall
                                    ?.copyWith(color: Colors.green.shade500)
                      ),
                    ],
                  ),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Spending",
                        style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Theme.of(context).hintColor)
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        ((snapshot.data ?? (0, 0, 0)).$3 / 100).toStringAsFixed(2),
                        style: Theme.of(context)
                                     .textTheme
                                     .headlineSmall
                                    ?.copyWith(color: Colors.redAccent)
                      ),
                    ],
                  ),
                  Spacer(),
                ]
              )
            ]
          );
        }
      ),
    );
  }
}
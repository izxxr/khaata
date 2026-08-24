import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/features/transactions/services/transaction_repository.dart';

class AccountOverviewCard extends StatefulWidget {
  const new({super.key, required this.account});

  final Account account;

  @override
  State<AccountOverviewCard> createState() => _AccountOverviewCardState();
}

class _AccountOverviewCardState extends State<AccountOverviewCard> {
  late Stream<int> _balanceStream;

  @override
  void initState() {
    super.initState();

    _balanceStream = context.read<TransactionRepository>().watchBalance(widget.account.id);
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
          else if (snapshot.hasError || snapshot.data == null) {
            child = Text("0.00", style: Theme.of(context).textTheme.displaySmall);
          }
          else {
            child = Text((snapshot.data! / 100).toStringAsFixed(2), style: Theme.of(context).textTheme.displaySmall);
          }

          return Row(
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
                      SizedBox(width: AppSpacing.md),
                      widget.account.isolatedAccount ?
                        Tooltip(
                          message: "Isolated account",
                          triggerMode: TooltipTriggerMode.tap,
                          child: Icon(Icons.money_off, size: 28, color: Colors.orange)
                        )
                      : SizedBox(),
                    ]
                  ),
                ]
              ),
              Spacer(),
              IconButton(onPressed: () {}, icon: Icon(Icons.refresh)),
            ],
          );
        }
      ),
    );
  }
}
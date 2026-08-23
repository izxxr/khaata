import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/features/accounts/widgets/account_colors.dart';
import 'package:khaata/features/transactions/services/transaction_repository.dart';

class AccountsListEntry extends StatelessWidget {
  const new({super.key, required this.data});

  final Account data;

  void _onTap(BuildContext context) {
    context.go('/accounts/${data.id}');
  }

  @override
  Widget build(BuildContext context) {
    final description = data.description ?? "";
    final balanceStream = StreamBuilder(
      stream: context.read<TransactionRepository>().watchBalance(data.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        return Text(
          ((snapshot.data ?? 0) / 100).toStringAsFixed(2),
          style: Theme.of(context)
                       .textTheme
                       .titleMedium
                      ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).hintColor,
                        ),
        );
      }
    );

    List<Widget> children = [];

    if (description.isEmpty) {
      children = [
        Row(
          children: [
            Text(data.title, style: Theme.of(context).textTheme.titleMedium),
            Spacer(),
            balanceStream
          ]
        ),
      ];
    } else {
      children = [
        Text(data.title, style: Theme.of(context).textTheme.titleMedium),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Text(
                description.length > 100 ? "${description.substring(0, 100)}..." : description,
                style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Theme.of(context).hintColor)
              ),
            ),
            Spacer(),
            balanceStream
          ]
        ),
      ];
    }

    return Container(
      margin: EdgeInsets.only(top: AppSpacing.md),
      child: InkWell(
        onTap: () => _onTap(context),
        child: Ink(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Theme.of(context).colorScheme.surfaceContainerHighest, Theme.of(context).colorScheme.surfaceContainerHigh]),
            border: Border(
              left: BorderSide(
                color: AccountColor.fromId(data.color).color,
                width: 4,
              ),
            ),
            borderRadius: BorderRadius.circular(5)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      )
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/common/khaata_colors.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/features/transactions/services/transaction_repository.dart';

class AccountsListEntry extends StatelessWidget {
  const new({super.key, required this.data});

  final Account data;

  void _onTap(BuildContext context) {
    context.go('/accounts/${data.id}');
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> additionalChildren = [];
    final description = data.description ?? "";

    if (description.isNotEmpty) {
      additionalChildren = [
        SizedBox(height: AppSpacing.sm),
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
                color: KhaataColors.fromId(data.color).color,
                width: 4,
              ),
            ),
            borderRadius: BorderRadius.circular(5)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(data.title, style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(width: AppSpacing.sm),

                  data.isolatedAccount ?
                    Icon(Icons.money_off, size: 18, color: Colors.orange)
                  : SizedBox(),

                  Spacer(),
                  StreamBuilder(
                    stream: context.read<TransactionRepository>().watchBalance(data.id),
                    builder: (context, snapshot) {
                      String text = "";

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        text = "Loading";
                      }
                      if (snapshot.hasError) {
                        text = "Error";
                      }
                      if (snapshot.data != null) {
                        text = (snapshot.data! / 100).toStringAsFixed(2);
                      }

                      return Text(
                        text,
                        style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).hintColor,
                                      ),
                      );
                    }
                  ),
                ]
              ),
              ...additionalChildren,
            ],
          ),
        ),
      )
    );
  }
}
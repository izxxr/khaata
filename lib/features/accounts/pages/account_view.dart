import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/features/accounts/services/account_repository.dart';
import 'package:khaata/features/transactions/services/transaction_repository.dart';
import 'package:khaata/features/accounts/widgets/account_colors.dart';
import 'package:khaata/features/accounts/widgets/account_modals.dart';
import 'package:khaata/features/accounts/widgets/account_overview_card.dart';
import 'package:khaata/features/transactions/widgets/transaction_card.dart';
import 'package:khaata/features/transactions/widgets/transaction_modal.dart';
import 'package:khaata/widgets/default_screen.dart';


class AccountView extends StatefulWidget {
  const new({super.key, required this.accountId});

  final int accountId;

  @override
  State<AccountView> createState() => _AccountViewState();
}


class _AccountViewState extends State<AccountView> {
  late Stream<Account> _accountWatcher;

  final _editAccountFormKey = GlobalKey<FormState>();
  final _addTransactionFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _accountWatcher = context.read<AccountRepository>().getAccount(widget.accountId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _accountWatcher,
      builder: (builder, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final account = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(account.title),
            backgroundColor: AccountColor.fromId(account.color).color,
            actions: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => showAccountCreationModal(
                  context,
                  _editAccountFormKey,
                  accountId: account.id,
                  initialTitle: account.title,
                  initialDescription: account.description,
                  initialColor: AccountColor.fromId(account.color),
                ),
              )
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(AppSpacing.globalPadding),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSpacing.md),
                    AccountOverviewCard(account: account),
                    SizedBox(height: AppSpacing.xl),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Transactions", style: Theme.of(context).textTheme.titleMedium),
                        Spacer(),
                        TextButton.icon(
                          onPressed: () {},
                          label: Text("View History"),
                        )
                      ]
                    ),
                    SizedBox(height: AppSpacing.sm),
                  ],
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: context.read<TransactionRepository>().watchTransactions(account.id, 7),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final transactions = snapshot.data!;

                      if (transactions.isEmpty) {
                        return const DefaultScreen(
                          icon: Icons.money_off,
                          title: "No transactions",
                          subtitle: "Tap on + to log transactions"
                        );
                      }

                      return ListView.builder(
                        clipBehavior: .hardEdge,
                        itemCount: transactions.length,
                        itemBuilder: (context, index) => Material(child: TransactionCard(transaction: transactions[index]))
                      );
                    }
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => showTransactionModal(context, _addTransactionFormKey, account.id, null),
            child: Icon(Icons.add),
          ),
        );
      }
    );
  }
}

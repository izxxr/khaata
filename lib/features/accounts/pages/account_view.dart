import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/common/khaata_colors.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/features/accounts/services/account_repository.dart';
import 'package:khaata/features/accounts/widgets/account_modal.dart';
import 'package:khaata/features/accounts/widgets/account_overview_card.dart';
import 'package:khaata/features/transactions/widgets/transaction_modal.dart';
import 'package:khaata/features/transactions/widgets/transactions_list.dart';


/// View of an account showing balance and transactions from the account.
class AccountView extends StatefulWidget {
  const new({super.key, required this.accountId});

  final int accountId;

  @override
  State<AccountView> createState() => _AccountViewState();
}


class _AccountViewState extends State<AccountView> {
  late Stream<Account> _accountWatcher;

  final _editAccountFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _accountWatcher = context.read<AccountRepository>().watchAccount(widget.accountId);
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
            backgroundColor: KhaataColors.fromId(account.color).color,
            actions: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => showAccountCreationModal(
                  context,
                  _editAccountFormKey,
                  account
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
                    AccountOverviewCard(accountIds: [account.id]),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Transactions",
                      style: Theme.of(context).textTheme.titleMedium
                    ),
                    // TODO: reveal this button after insights page implemented.
                    // Spacer(),
                    // TextButton.icon(
                    //   onPressed: () {},
                    //   label: Text("View History"),
                    // )
                  ]
                ),
                SizedBox(height: AppSpacing.sm),
                Expanded(child: TransactionsList(account: account, limit: null)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => TransactionModal.show(context, account.id, null),
            child: Icon(Icons.add),
          ),
        );
      }
    );
  }
}

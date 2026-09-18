import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/common/khaata_colors.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/features/accounts/services/account_repository.dart';
import 'package:khaata/features/accounts/widgets/account_modal.dart';
import 'package:khaata/features/accounts/widgets/account_overview_card.dart';
import 'package:khaata/features/transactions/widgets/transaction_modal.dart';
import 'package:khaata/features/transactions/widgets/transactions_list.dart';
import 'package:khaata/features/transactions/widgets/transfer_modal.dart';


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
  final _fabKey = GlobalKey<ExpandableFabState>();

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
                  ]
                ),
                SizedBox(height: AppSpacing.sm),
                Expanded(child: TransactionsList(accountIds: [account.id], basic: false)),
              ],
            ),
          ),
          floatingActionButtonLocation: ExpandableFab.location,
          floatingActionButton: ExpandableFab(
            key: _fabKey,
            distance: 70,
            type: ExpandableFabType.up,
            childrenAnimation: ExpandableFabAnimation.none,
            margin: EdgeInsets.all(20),
            openButtonBuilder: RotateFloatingActionButtonBuilder(
              child: const Icon(Icons.add),
              fabSize: ExpandableFabSize.regular,
              shape: const CircleBorder(),
            ),
            overlayStyle: ExpandableFabOverlayStyle(
              // blur: 3,
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.259)
            ),
            children: [
              Row(
                children: [
                  Text('Transaction', style: TextStyle(fontWeight: .bold)),
                  SizedBox(width: AppSpacing.md),
                  FloatingActionButton.small(
                    heroTag: null,
                    onPressed: () async {
                      await TransactionModal.show(context, account.id, null);
                      _fabKey.currentState?.toggle();
                    },
                    child: Icon(Icons.add),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Transfer', style: TextStyle(fontWeight: .bold)),
                  SizedBox(width: AppSpacing.md),
                  FloatingActionButton.small(
                    heroTag: null,
                    onPressed: () async {
                      await TransferModal.show(context, account);
                      _fabKey.currentState?.toggle();
                    },
                    child: Icon(Icons.send),
                  ),
                ],
              ),
            ]
          )
        );
      }
    );
  }
}

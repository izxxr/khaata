import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/features/accounts/services/account_repository.dart';
import 'package:khaata/features/accounts/widgets/account_colors.dart';
import 'package:khaata/features/accounts/widgets/account_modals.dart';
import 'package:khaata/features/accounts/widgets/account_overview_card.dart';


class AccountView extends StatefulWidget {
  const new({super.key, required this.accountId});

  final int accountId;

  @override
  State<AccountView> createState() => _AccountViewState();
}


class _AccountViewState extends State<AccountView> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final colorController = TextEditingController();

  late Stream<AccountData> _accountWatcher;

  @override
  void initState() {
    super.initState();

    _accountWatcher = context.read<AccountRepository>().getAccount(widget.accountId);

    _accountWatcher.listen((data) {
      nameController.value = TextEditingValue(text: data.title);
      descriptionController.value = TextEditingValue(text: data.description ?? "");
      colorController.value = TextEditingValue(text: AccountColor.fromId(data.color).name);
    });
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
                  nameController: nameController,
                  descriptionController: descriptionController,
                  colorController: colorController,
                  accountId: account.id,
                ),
              )
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(AppSpacing.globalPadding),
            child: Column(
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
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: Icon(Icons.add),
          ),
        );
      }
    );
  }
}

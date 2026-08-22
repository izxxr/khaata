import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/features/accounts/widgets/accounts_list_entry.dart';
import 'package:khaata/widgets/default_screen.dart';
import 'package:khaata/features/accounts/widgets/account_modals.dart';
import 'package:khaata/features/accounts/widgets/account_colors.dart';
import 'package:khaata/features/accounts/services/account_repository.dart';


/// Accounts list widget for the "Accounts" section.
class AccountsList extends StatefulWidget {
  const new({super.key});

  @override
  createState() => _AccountsListState();
}


class _AccountsListState extends State<AccountsList> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final colorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(AppSpacing.globalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Accounts",
              style: Theme.of(context).textTheme.titleLarge
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              "Categorize your transactions using accounts",
              style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(color: Theme.of(context).hintColor),
            ),
            SizedBox(height: AppSpacing.lg),
            StreamBuilder(
              stream: context.read<AccountRepository>().watchAccounts(),
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

                final accounts = snapshot.data!;

                if (accounts.isEmpty) {
                  return const DefaultScreen(
                    icon: Icons.info,
                    title: "No accounts",
                    subtitle: "Tap on + to create an account"
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: accounts.length,
                    itemBuilder: (context, index) => AccountsListEntry(data: accounts[index])
                  )
                );
              }
            )
            
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAccountCreationModal(
          context,
          nameController: nameController,
          descriptionController: descriptionController,
          colorController: colorController,
          onSubmit: () async {
            final title = nameController.text.trim();
            final description = descriptionController.text.trim();
            final color = AccountColor.values.firstWhere(
              (v) => v.name.toLowerCase() == colorController.text.trim().toLowerCase()
            );

            if (title.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Account name must be provided.'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }

            if (title.length < 2) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Account name must be at least 2 characters long'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }

            await context.read<AccountRepository>().createAccount(
              title,
              description: description,
              color: color,
            );

            if (!this.context.mounted) return;

            Navigator.pop(context);
          }
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

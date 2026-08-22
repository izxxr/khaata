import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/widgets/confirm_dialog.dart';
import 'package:khaata/features/accounts/services/account_repository.dart';
import 'package:khaata/features/accounts/widgets/account_colors.dart';

void showAccountCreationModal(
  BuildContext context,
  {
    required TextEditingController nameController,
    required TextEditingController descriptionController,
    required TextEditingController colorController,
    int? accountId,
  }
) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return SizedBox(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.globalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (accountId != null) ? "Update Account" : "Create Account",
                        style: Theme.of(context).textTheme.titleMedium
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        "${(accountId != null) ? 'Modify' : 'Enter'} the account details",
                        style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Theme.of(context).hintColor)
                      ),
                    ],
                  ),
                  Spacer(),
                  (accountId != null) ?
                    IconButton(
                      onPressed: () async {
                        final confirmed = await showConfirmDialog(
                          context, 
                          title: 'Delete Account', 
                          message: 'Are you sure? This action is irreversible.'
                        );

                        if (!confirmed) return;
                        if (!context.mounted) return;

                        await context.read<AccountRepository>().deleteAccount(accountId);
                        if (!context.mounted) return;

                        context.go('/accounts');
                      },
                      icon: Icon(Icons.delete),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.errorContainer,
                        foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    )
                  : SizedBox(),
                  SizedBox(width: AppSpacing.sm),
                  IconButton(
                    onPressed: () async {
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

                      if (accountId != null) {
                        await context.read<AccountRepository>().updateAccount(
                          accountId,
                          title: title,
                          description: description,
                          color: color,
                        );
                      } else {
                        await context.read<AccountRepository>().createAccount(
                          title,
                          description: description,
                          color: color,
                        );
                      }

                      if (!context.mounted) return;

                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.done),
                    style: IconButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primaryContainer),
                  )
                ],
              ),
              SizedBox(height: AppSpacing.xl),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  label: Text("Account name"),
                  hint: Text("Bank, cash, wallet, etc."),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  label: Text("Description (optional)"),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              DropdownMenu<int>(
                label: Text("Color"),
                menuHeight: 300,
                width: MediaQuery.of(context).size.width,
                controller: colorController,
                dropdownMenuEntries: [
                  for (var entry in AccountColor.values)
                    DropdownMenuEntry(
                      label: entry.name,
                      value: entry.id,
                      leadingIcon: Icon(Icons.circle, color: entry.color),
                    )
                ]
              ),
              SizedBox(height: AppSpacing.lg),
            ],
          )
        )
      );
    },
  );
}

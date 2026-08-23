import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/widgets/confirm_dialog.dart';
import 'package:khaata/features/accounts/services/account_repository.dart';
import 'package:khaata/features/accounts/widgets/account_colors.dart';

Future showAccountCreationModal(
  BuildContext context,
  GlobalKey<FormState> formKey,
  Account? account,
) async {
  String title = account?.title ?? '';
  String description = account?.description ?? '';
  AccountColor color = account != null ? AccountColor.fromId(account.color) : AccountColor.slate;

  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return SizedBox(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.globalPadding),
          child: Form(
            key: formKey,
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
                          (account != null) ? "Update Account" : "Create Account",
                          style: Theme.of(context).textTheme.titleMedium
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          "${(account != null) ? 'Modify' : 'Enter'} the account details",
                          style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Theme.of(context).hintColor)
                        ),
                      ],
                    ),
                    Spacer(),
                    (account != null) ?
                      IconButton(
                        onPressed: () async {
                          final confirmed = await showConfirmDialog(
                            context, 
                            title: 'Delete Account', 
                            message: 'Are you sure? This action is irreversible.'
                          );

                          if (!confirmed) return;
                          if (!context.mounted) return;

                          await context.read<AccountRepository>().deleteAccount(account.id);
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
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        formKey.currentState!.save();

                        if (account != null) {
                          await context.read<AccountRepository>().updateAccount(
                            account.id,
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

                        formKey.currentState!.reset();

                        if (!context.mounted) return;

                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.done),
                      style: IconButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primaryContainer),
                    )
                  ],
                ),
                SizedBox(height: AppSpacing.xl),
                TextFormField(
                  decoration: InputDecoration(
                    label: Text("Account name"),
                    hint: Text("Bank, cash, wallet, etc."),
                  ),
                  initialValue: account?.title,
                  validator: (value) {
                    if (value == null) {
                      return 'Account name is required.';
                    }

                    if (value.isEmpty) {
                      return 'Account name is required.';
                    }

                    if (value.length < 2) {
                      return 'Account name must be at least 2 characters.';
                    }

                    return null;
                  },
                  onSaved: (newValue) {
                    title = newValue ?? '';
                  },
                ),
                SizedBox(height: AppSpacing.md),
                TextFormField(
                  decoration: InputDecoration(
                    label: Text("Description (optional)"),
                  ),
                  initialValue: account?.description,
                  onSaved: (newValue) {
                    description = newValue ?? '';
                  },
                ),
                SizedBox(height: AppSpacing.md),
                DropdownMenuFormField<int>(
                  label: Text("Color"),
                  menuHeight: 300,
                  width: MediaQuery.of(context).size.width,
                  dropdownMenuEntries: [
                    for (var entry in AccountColor.values)
                      DropdownMenuEntry(
                        label: entry.name,
                        value: entry.id,
                        leadingIcon: Icon(Icons.circle, color: entry.color),
                      )
                  ],
                  initialSelection: account?.color,
                  onSaved: (newValue) {
                    if (newValue == null) {
                      color = AccountColor.slate;
                    } else {
                      color = AccountColor.fromId(newValue);
                    }
                  },
                ),
                SizedBox(height: AppSpacing.lg),
              ],
            )
          )
        )
      );
    },
  );
}

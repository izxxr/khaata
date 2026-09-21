import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/common/khaata_colors.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/features/accounts/services/account_repository.dart';

class AccountsDropdown extends StatefulWidget {
  const new({
    super.key,
    required this.onChanged,
    required this.onSaved,
    this.accountId,
    this.exclude,
    this.labelText = "Account",
  });

  final int? accountId;
  final List<int>? exclude;
  final String labelText;
  final void Function(Account?) onChanged;
  final void Function(Account?) onSaved;

  @override
  State<AccountsDropdown> createState() => _AccountsDropdownState();
}


class _AccountsDropdownState extends State<AccountsDropdown> {
  late int? accountId;

  @override
  void initState() {
    super.initState();

    accountId = widget.accountId;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<AccountRepository>().watchAccounts(),
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.connectionState == ConnectionState.waiting) {
          return DropdownButtonFormField(
            hint: Text("Loading..."),
            items: [],
            onChanged: (v) {},
            decoration: InputDecoration(
              enabled: false
            ),
          );
        }

        var accounts = snapshot.data!
          .where((a) => !(widget.exclude?.contains(a.id) ?? false))
          .map(
            (a) => DropdownMenuItem(
              value: a.id,
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance,
                    color: KhaataColors.fromId(a.color).color
                  ),
                  SizedBox(width: AppSpacing.md), // Gives space between icon and text
                  Text(a.title),
                ]
              ),
            )
          ).toList();

        accounts = [
          DropdownMenuItem(
            value: null,
            child: Text("None")
          ),
          ...accounts
        ];

        final accountIds = snapshot.data!.map((e) => e.id).toSet();

        return DropdownButtonFormField(
          items: accounts,
          initialValue: accountIds.contains(accountId) ? accountId : null,
          validator: (value) {
            if (snapshot.data!.isEmpty && value == null) {
              // No account exists, allow empty value
              return null;
            }
            if (value == null) {
              return "Select an account to log transaction";
            }
            return null;
          },
          onChanged: (v) => setState(() {
            if (v != null) {
              widget.onChanged(snapshot.data!.firstWhere((a) => a.id == v));
            } else {
              widget.onChanged(null);
            }

            accountId = v;
          }),
          onSaved: (v) => (v) => setState(() {
            if (v != null) {
              widget.onSaved(snapshot.data!.firstWhere((a) => a.id == v));
            } else {
              widget.onSaved(null);
            }

            accountId = v;
          }),
          decoration: InputDecoration(
            label: Text(widget.labelText),
          ),
        );
      }
    );
  }
}
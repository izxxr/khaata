import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/common/khaata_colors.dart';
import 'package:khaata/features/accounts/services/account_repository.dart';

class AccountsDropdown extends StatefulWidget {
  const new({super.key, this.accountId, required this.onChanged, required this.onSaved});

  final int? accountId;
  final void Function(int?) onChanged;
  final void Function(int?) onSaved;

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

        var accounts = snapshot.data!.map(
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
            if (value == null) {
              return "Select an account to log transaction";
            }
            return null;
          },
          onChanged: (v) => setState(() { widget.onChanged(v); accountId = v; }),
          onSaved: (v) => setState(() { widget.onSaved(v); accountId = v; }),
          decoration: InputDecoration(
            label: Text("Account"),
          ),
        );
      }
    );
  }
}
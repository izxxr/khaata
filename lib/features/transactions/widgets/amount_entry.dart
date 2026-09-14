import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/database/database.dart';


class AmountEntry extends StatefulWidget {
  const new({super.key, required this.onSaved, this.transaction});

  final Transaction? transaction;
  final FormFieldSetter<int?> onSaved;

  @override
  State<AmountEntry> createState() => _AmountEntryState();
}


class _AmountEntryState extends State<AmountEntry> {
  final _amountFocusNode = FocusNode();

  int amount = 0;
  int sign = 1;

  @override
  void initState() {
    super.initState();

    amount = widget.transaction?.amount ?? 0;
    sign = amount >= 0 ? 1 : -1;
  }

  int? _parseAmount(String? raw, int sign) {
    if (raw == null || raw.isEmpty) return null;

    final parts = raw.split('.');

    final whole = int.parse(parts[0]);
    final frac = parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0'));

    return sign * (whole * 100 + frac);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(sign == 1 ? Icons.add : Icons.remove),
          color: sign == 1 ? Colors.green : Colors.red,
          onPressed: () {
            setState(() {
              sign = -sign;
              _amountFocusNode.requestFocus();
            });
          },
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              hint: Text(
                "Amount...",
                style: TextStyle(
                  fontSize: 22,
                  color: Theme.of(context).hintColor
                )
              ),
              suffixIcon: Icon(Icons.money),
              border: UnderlineInputBorder(),
            ),
            style: TextStyle(
              color: sign == 1 ? Colors.green.shade500 : Colors.red,
              fontSize: 22
            ),
            autofocus: true,
            focusNode: _amountFocusNode,
            textInputAction: TextInputAction.next,
            initialValue: widget.transaction != null ? widget.transaction!.parseAmount(stripSign: true) : "",
            keyboardType: TextInputType.number, // Shows numeric keyboard
            inputFormatters: <TextInputFormatter>[
              TextInputFormatter.withFunction((oldValue, newValue) {
                final value = newValue.text;

                if (value.isEmpty) {
                  return newValue;
                }

                if (RegExp(r'^\d+(?:\.\d{0,2})?$').hasMatch(value)) {
                  return newValue;
                }

                return oldValue;
              })
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter an amount';
              }

              if (!RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(value)) {
                return 'Invalid amount';
              }

              if (_parseAmount(value, sign) == 0) {
                return 'Amount cannot be zero';
              }

              return null;
            },
            onSaved: (value) => widget.onSaved(_parseAmount(value, sign)),
          )
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/common/formatters.dart';
import 'package:khaata/common/helpers.dart';
import 'package:khaata/database/database.dart';


class AmountEntry extends StatefulWidget {
  const new({
    super.key,
    this.onSaved,
    this.onChanged,
    this.transaction,
    this.positiveOnly = false
  });

  final Transaction? transaction;
  final FormFieldSetter<int?>? onSaved;
  final FormFieldSetter<int?>? onChanged;
  final bool positiveOnly;

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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        !widget.positiveOnly ?
          IconButton(
            icon: Icon(sign == 1 ? Icons.add : Icons.remove),
            color: sign == 1 ? Colors.green : Colors.red,
            onPressed: () {
              setState(() {
                sign = -sign;
                _amountFocusNode.requestFocus();
              });
            },
          )
        : SizedBox(),
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
              color: 
                widget.positiveOnly ? null :
                  (sign == 1 ? Colors.green.shade500 : Colors.red),
              fontSize: 22
            ),
            autofocus: true,
            focusNode: _amountFocusNode,
            initialValue: widget.transaction != null ? widget.transaction!.parseAmount(stripSign: true) : "",
            keyboardType: TextInputType.number, // Shows numeric keyboard
            inputFormatters: <TextInputFormatter>[
              getAmountFormatter(),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter an amount';
              }

              if (!RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(value)) {
                return 'Invalid amount';
              }

              if (parseRawAmount(value, sign) == 0) {
                return 'Amount cannot be zero';
              }

              return null;
            },
            onSaved: (value) =>
              widget.onSaved != null ?
              widget.onSaved!(parseRawAmount(value, widget.positiveOnly ? 1 : sign)) :
              null,
            onChanged: (value) =>
              widget.onChanged != null ?
              widget.onChanged!(parseRawAmount(value, widget.positiveOnly ? 1 : sign)) :
              null,
          )
        ),
      ],
    );
  }
}
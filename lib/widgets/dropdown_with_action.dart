import 'package:flutter/material.dart';


/// Dropdown with "Add New" action.
/// 
/// This widget allows listing existing elements like categories or counterparties
/// and provide option to create new element integrated into dropdown.
/// 
/// Dropdown is populated by provided [stream] and requires [itemBuilder] for serializing
/// stream result into dropdown widget. [labelText] is the dropdown's label.
/// 
/// For default or no selection case, [noSelectionValue] is the value to represent the
/// "nothing selected" case.
/// 
/// [newItemValue] is the value of generic type [U] to represent value when "Create new..."
/// entry is selected. This value should be unique and a sentinel to avoid conflicts with
/// actual dropdown entries.
/// 
/// [onNewItem] callback is called when a new item is to be created. It should return the
/// new entry's value or [noSelectionValue] if no entry was created (e.g. if user canceled
/// the operation).
/// 
/// [onChanged] callback is called when dropdown's state changes (except when new item button
/// is clicked).
/// 
/// [initialSelection] is the initially selected value.
class DropdownWithAction<T, U> extends StatefulWidget {
  const new({
    super.key,
    required this.stream,
    required this.itemBuilder,
    required this.labelText,
    required this.noSelectionValue,
    required this.newItemValue,
    required this.onNewItem,
    required this.onChanged,
    this.initialSelection,
  });

  final Stream<List<T>> stream;
  final DropdownMenuItem<U> Function(T) itemBuilder;
  final String labelText;
  final U? noSelectionValue;
  final U newItemValue;
  final Future<U?> Function() onNewItem;
  final void Function(U?) onChanged;
  final U? initialSelection;

  @override
  State<DropdownWithAction<T, U>> createState() => _DropdownWithActionState<T, U>();
}


class _DropdownWithActionState<T, U> extends State<DropdownWithAction<T, U>> {
  U? _currentSelection;

  @override
  void initState() {
    super.initState();

    _currentSelection = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.stream,
      builder: (builder, snapshot) {
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

        List<DropdownMenuItem<U>> entries = snapshot.data!.map(
          widget.itemBuilder
        ).toList();

        entries.add(
          DropdownMenuItem<U>(
            value: widget.newItemValue,
            child: Text("Create new...", style: TextStyle(color: Colors.blue)),
          )
        );

        entries.insert(
          0,
          DropdownMenuItem<U>(value: widget.noSelectionValue, child: Text("None"))
        );

        return DropdownButtonFormField(
          decoration: InputDecoration(
            label: Text(widget.labelText),
          ),
          initialValue: _currentSelection,
          onChanged: (v) async {
            if (v == widget.newItemValue) {
              final newValue = await widget.onNewItem();

              return setState(() {
                _currentSelection = newValue;
              });
            }

            widget.onChanged(v);

            setState(() {
              _currentSelection = v;
            });
         },
          items: entries
        ); 
      }
    );
  }
}
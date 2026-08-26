import 'package:flutter/material.dart';

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
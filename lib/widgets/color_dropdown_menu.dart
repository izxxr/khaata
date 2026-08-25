import 'package:flutter/material.dart';
import 'package:khaata/common/khaata_colors.dart';

class ColorDropdownMenu extends StatelessWidget {
  const new({super.key, required this.onSelected, this.initialSelection});

  final Function(KhaataColors) onSelected;
  final KhaataColors? initialSelection;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<int>(
      label: Text("Color"),
      menuHeight: 300,
      width: MediaQuery.of(context).size.width,
      dropdownMenuEntries: [
        for (var entry in KhaataColors.values)
          DropdownMenuEntry(
            label: entry.name,
            value: entry.id,
            leadingIcon: Icon(Icons.circle, color: entry.color),
          )
      ],
      initialSelection: initialSelection?.id,
      onSelected: (newValue) {
        if (newValue == null) {
          onSelected(KhaataColors.slate);
        } else {
          onSelected(KhaataColors.fromId(newValue));
        }
      }
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/common/khaata_colors.dart';
import 'package:khaata/widgets/color_dropdown_menu.dart';
import 'package:khaata/features/transactions/services/category_repository.dart';

class CategoryModal extends StatefulWidget {
  const new({super.key});

  static Future<int?> show(BuildContext context) async {
    final result = await showDialog<int?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CategoryModal(),
    );
    return result; // Returns false if user taps outside
  }

  @override
  State<CategoryModal> createState() => _CategoryModalState();
}

class _CategoryModalState extends State<CategoryModal> {
  final _formKey = GlobalKey<FormState>();

  String? categoryName;
  KhaataColors categoryColor = KhaataColors.slate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Create new category...", style: Theme.of(context).textTheme.titleLarge),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.md,
          children: [
            SizedBox(),
            TextFormField(
              onSaved: (v) {
                categoryName = v!.trim();
              },
              decoration: InputDecoration(
                label: Text("Name"),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return "Category name is required";
                }
                return null;
              },
            ),
            ColorDropdownMenu(
              onSelected: (newValue) {
                categoryColor = newValue;
              }
            )
          ]
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel')
        ),
        ElevatedButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            _formKey.currentState!.save();

            if (categoryName == null) {
              return;
            }

            final id = await context.read<CategoryRepository>().createCategory(
              categoryName!,
              color: categoryColor,
            );

            if (!context.mounted) return;

            Navigator.pop(context, id);
          },
          child: const Text('Create')
        ),
      ],
    );
  }
}

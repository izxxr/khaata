import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/common/khaata_colors.dart';
import 'package:khaata/database/database.dart';
import 'package:khaata/widgets/color_dropdown_menu.dart';
import 'package:khaata/features/transactions/services/category_repository.dart';

class CategoryModal extends StatefulWidget {
  const new({super.key, this.category});

  final Category? category;

  static Future<int?> show(BuildContext context, Category? category) async {
    final result = await showDialog<int?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CategoryModal(category: category),
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
  void initState() {
    super.initState();

    if (widget.category != null) {
      categoryColor = KhaataColors.fromId(widget.category!.color);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${widget.category == null ? 'Create' : 'Edit'} category...",
            style: Theme.of(context).textTheme.titleLarge
          ),
          Spacer(),
          widget.category != null ?
            IconButton(
              onPressed: () async {
                await context.read<CategoryRepository>().deleteCategory(widget.category!.id);

                if (!context.mounted) return;

                Navigator.pop(context, null);
              },
              icon: Icon(Icons.delete, size: 26, color: Colors.red.shade500)
            )
          : SizedBox()
        ]
      ),
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
              initialValue: widget.category?.name,
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
              initialSelection: widget.category != null ? KhaataColors.fromId(widget.category!.color) : null,
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

            int? categoryId = widget.category?.id;

            if (categoryId == null) {
              categoryId = await context.read<CategoryRepository>().createCategory(
                categoryName!,
                color: categoryColor,
              );
            } else {
              await context.read<CategoryRepository>().updateCategory(
                categoryId,
                name: categoryName,
                color: categoryColor,
              );
            }

            if (!context.mounted) return;

            Navigator.pop(context, categoryId);
          },
          child: Text(widget.category != null ? "Update" : "Create")
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/common/khaata_colors.dart';
import 'package:khaata/features/transactions/services/category_repository.dart';
import 'package:khaata/features/transactions/widgets/category_modal.dart';
import 'package:khaata/widgets/default_screen.dart';

class Categories extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Categories"),
        actions: [
          IconButton(
            onPressed: () => CategoryModal.show(context, null),
            icon: Icon(Icons.add)
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(AppSpacing.globalPadding),
        child: StreamBuilder(
          stream: context.read<CategoryRepository>().watchCategories(),
          builder: (builder, snapshot) {
            if (snapshot.data == null || snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            final categories = snapshot.data!;

            if (categories.isEmpty) {
              return DefaultScreen(
                icon: Icons.category,
                title: "No categories",
                subtitle: "Tap on + to create one"
              );
            }

            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];

                return ListTile(
                  title: Text(cat.name),
                  horizontalTitleGap: AppSpacing.lg,
                  subtitle: Text("ID: ${cat.id}"),
                  visualDensity: VisualDensity.comfortable,
                  leading: Icon(Icons.category, color: KhaataColors.fromId(cat.color).color),
                  onTap: () => CategoryModal.show(context, cat),
                );
              }
            );
          }
        ),
      )
    );
  }
}
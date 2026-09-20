import 'dart:io';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khaata/widgets/confirm_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:khaata/app/style.dart';
import 'package:khaata/app/bloc/app_bloc.dart';
import 'package:khaata/app/bloc/app_event.dart';
import 'package:khaata/features/settings/widgets/settings_entry.dart';
import 'package:khaata/features/settings/services/import_export.dart';
import 'package:khaata/features/accounts/widgets/accounts_dropdown.dart';


/// Main widget for the "Settings" section.
class Settings extends StatelessWidget {
  new({super.key});

  final Uri _viewSourceUrl = Uri.parse("https://github.com/izxxr/khaata");

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.globalPadding),
      children: [
        Text(
          "Settings",
          style: Theme.of(context).textTheme.titleLarge
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          "Customize Khaata the way you like it",
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).hintColor
          ),
        ),
        SettingsEntry(
          label: "Theme",
          description: "To use device's default theme, set to System",
          controlWidget: DropdownMenu(
            initialSelection: context.read<AppBloc>().state.themeMode.name,
            width: double.infinity,
            dropdownMenuEntries: [
              DropdownMenuEntry(value: "system", label: "System"),
              DropdownMenuEntry(value: "light", label: "Light"),
              DropdownMenuEntry(value: "dark", label: "Dark"),
            ],
            onSelected: (value) {
              context.read<AppBloc>().add(
                ThemeModeUpdated(
                  newThemeMode: switch (value) {
                    "light" => ThemeMode.light,
                    "dark" => ThemeMode.dark,
                    _ => ThemeMode.system,
                  }
                )
              );
            },
          )
        ),
        SettingsEntry(
          label: "Time Format",
          description: "24-hours: 14:29, 12-hours: 02:29 PM",
          controlWidget: DropdownMenu(
            initialSelection: context.read<AppBloc>().state.timeFormatIs24Hours ? 1 : 0,
            dropdownMenuEntries: [
              DropdownMenuEntry(value: 1, label: "24 hours"),
              DropdownMenuEntry(value: 0, label: "12 hours"),
            ],
            width: double.infinity,
            onSelected: (value) {
              context.read<AppBloc>().add(
                TimeFormatUpdated(is24HoursFormat: value == 1 ? true : false)
              );
            },
          )
        ),
        SettingsEntry(
          label: "Default Account",
          description: "The account automatically chosen when adding transaction from dashboard",
          controlWidget: AccountsDropdown(
            accountId: context.read<AppBloc>().state.defaultAccountId,
            onChanged: (v) {
              context.read<AppBloc>().add(
                DefaultAccountUpdated(accountId: v?.id)
              );
            },
            onSaved: (v) {
              context.read<AppBloc>().add(
                DefaultAccountUpdated(accountId: v?.id)
              );
            }
          ),
        ),
        SettingsEntry(
          label: "Import/Export",
          description: "Export your data or import existing data. Useful for creating backup.",
          controlWidget: Row(
            spacing: AppSpacing.xl,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  bool confirm = await showConfirmDialog(
                    context,
                    title: "Caution",
                    message:
                      "Importing data will not remove or overwrite your existing "
                      "accounts or transactions. The imported accounts and transactions "
                      "will be added alongside existing ones.\n\n"
                      "This can cause duplication if the imported data already exists or "
                      "if same data is imported multiple times.\n\n"
                      "If you would like to replace existing data with imported data, "
                      "please delete existing data first.\n\n"
                      "Click proceed to continue with import process or press cancel if "
                      "you are not sure yet.",
                  );

                  if (!confirm) return;

                  final fp = await FilePicker.pickFile(
                    dialogTitle: "Please select directory to export data to:",
                    type: FileType.custom,
                    allowedExtensions: ["json"],
                  );

                  if (fp == null) return;

                  final file = File(fp.uri.path);
                  final jsonString = await file.readAsString();

                  if (!context.mounted) return;

                  try {
                    final data = jsonDecode(jsonString);
                    await importData(context, data);
                  } catch (e, trace) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to import data: $e"),
                        action: SnackBarAction(
                          label: "Show Trace",
                          onPressed: () => showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (ctx) => AlertDialog(
                              title: Text("Error: $e"),
                              content: Text(trace.toString()),
                            )
                          )
                        ),
                      )
                    );
                    return;
                  }

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Data imported successfully")
                    )
                  );
                },
                icon: Icon(Icons.download),
                label: Text("Import")
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final data = await buildExportData(context);
                  final jsonData = jsonEncode(data);

                  final output = await FileSaver.instance.saveFile(
                    name: "khaata-export-${DateTime.now().toIso8601String()}",
                    fileExtension: "json",
                    includeExtension: true,
                    bytes: Uint8List.fromList(utf8.encode(jsonData)),
                    mimeType: MimeType.json,
                  );

                  // file_picker for some reason did not provide implementation
                  // getDirectoryPath() and saveFile() for Linux even though the
                  // documentation states it does.

                  // final outputDir = await FilePicker.getDirectoryPath(
                  //   dialogTitle: "Please select directory to export data to:",
                  // );
                  // final fp = "$outputDir/khaata-export-${DateTime.now().toIso8601String()}.json";

                  // if (outputDir != null) {
                  //   final file = File(fp);
                  //   await file.writeAsString(jsonData);
                  // }

                  if (!context.mounted) return;

                  final snackBar = SnackBar(
                    content: Text(
                      output.isNotEmpty ?
                        'Data exported successfully to $output'
                      : 'Export operation canceled'
                    ),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                icon: Icon(Icons.upload),
                label: Text("Export")
              ),
            ],
          )
        ),
        SettingsEntry(
          label: "Shared Preferences",
          description: "Reset application shared preferences.\n\nThis will clear app settings (username, theme, etc.) only. Accounts data and transactions remain unchanged.\n\nFor debugging purposes only.",
          controlWidget: ElevatedButton.icon(
            onPressed: () {
              context.read<AppBloc>().add(StateReset());
            },
            label: Text(
              "Clear",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer
              )
            ),
            icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.onErrorContainer),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
          )
        ),
        SettingsEntry(
          label: "App Info",
          description: "Khaata v2.2.0 - developed with ❤️ by Izhar Ahmad\n\n"
                       "This app is open source and welcomes contributions.\nView code and report issues on GitHub repository.",
          controlWidget: TextButton.icon(
            onPressed: () async {
              await launchUrl(_viewSourceUrl);
            },
            label: Text("View GitHub"),
            icon: Icon(Icons.link)
          ),
        )
      ],
    );
  }
}

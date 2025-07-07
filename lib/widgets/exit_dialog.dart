import 'package:flutter/material.dart';
import 'package:ecommerce/l10n/app_localizations.dart';

class ExitDialog extends StatelessWidget {
  const ExitDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const ExitDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(localization.confirmExitTitle),
      content: Text(localization.confirmExitContent),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(localization.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: Text(
            localization.exit,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

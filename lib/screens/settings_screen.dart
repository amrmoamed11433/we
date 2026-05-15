import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../providers/language_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l.language,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: Colors.grey.shade700),
              ),
            ),
            RadioListTile<String>(
              title: Text(l.arabic),
              value: 'ar',
              groupValue: lang.locale.languageCode,
              onChanged: (v) => v != null ? lang.setLanguage(v) : null,
            ),
            RadioListTile<String>(
              title: Text(l.english),
              value: 'en',
              groupValue: lang.locale.languageCode,
              onChanged: (v) => v != null ? lang.setLanguage(v) : null,
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                l.appInfo,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: Colors.grey.shade700),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l.appVersion),
              subtitle: const Text('1.0.0'),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(l.about),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.red),
              title: Text(l.resetDemo,
                  style: const TextStyle(color: Colors.red)),
              onTap: () => _confirmReset(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.resetDemoTitle),
        content: Text(l.resetDemoMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel)),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.confirm),
          ),
        ],
      ),
    );
    if (ok == true) {
      if (!context.mounted) return;
      await context.read<AppProvider>().resetDemoData();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.successSaved),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/services/firebase_service.dart';
import '../core/theme/theme_provider.dart';
import '../core/utils/locale_provider.dart';
import '../core/utils/purchase_service.dart';
import '../core/utils/review_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
} 

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseService.instance.logScreenView('SettingsScreen');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider    = context.watch<AppThemeProvider>();
    final localeProvider   = context.watch<LocaleProvider>();
    final purchaseService  = context.watch<PurchaseService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [

          // ── Appearance ──────────────────────────────────────────────────
          _SectionHeader('Appearance'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: Text(themeProvider.themeMode.name),
            onTap: () => _showThemeDialog(context, themeProvider),
          ),

          // ── Language ────────────────────────────────────────────────────
          _SectionHeader('Language'),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(
              LocaleProvider.localeNames[localeProvider.locale.languageCode] ?? 'English',
            ),
            onTap: () => _showLanguageDialog(context, localeProvider),
          ),

          // ── Premium / IAP ───────────────────────────────────────────────
          _SectionHeader('Premium'),
          ...purchaseService.products.map((product) => ListTile(
            leading: const Icon(Icons.star_outline),
            title: Text(product.title),
            subtitle: Text(product.price),
            trailing: ElevatedButton(
              onPressed: purchaseService.isPurchasing
                  ? null
                  : () => purchaseService.purchase(product),
              child: const Text('Buy'),
            ),
          )),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Purchases'),
            onTap: () => purchaseService.restorePurchases(),
          ),

          // ── Review ──────────────────────────────────────────────────────
          _SectionHeader('Feedback'),
          ListTile(
            leading: const Icon(Icons.star_rate_outlined),
            title: const Text('Rate the App'),
            onTap: () => ReviewService.instance.requestReviewNow(),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showThemeDialog(BuildContext ctx, AppThemeProvider provider) {
    showDialog(
      context: ctx,
      builder: (_) => SimpleDialog(
        title: const Text('Choose Theme'),
        children: ThemeMode.values.map((mode) => SimpleDialogOption(
          onPressed: () {
            provider.setThemeMode(mode);
            Navigator.pop(ctx);
          },
          child: Row(
            children: [
              Icon(mode == provider.themeMode ? Icons.radio_button_checked : Icons.radio_button_off),
              const SizedBox(width: 8),
              Text(mode.name[0].toUpperCase() + mode.name.substring(1)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  void _showLanguageDialog(BuildContext ctx, LocaleProvider provider) {
    showDialog(
      context: ctx,
      builder: (_) => SimpleDialog(
        title: const Text('Choose Language'),
        children: LocaleProvider.supportedLocales.map((locale) {
          final name = LocaleProvider.localeNames[locale.languageCode] ?? locale.languageCode;
          final selected = locale == provider.locale;
          return SimpleDialogOption(
            onPressed: () {
              provider.setLocale(locale);
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off),
                const SizedBox(width: 8),
                Text(name),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
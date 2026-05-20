import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// import '../config/services/firebase_service.dart';
// import '../core/utils/review_service.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/locale_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _privacyPolicyUrl = 'https://example.com/privacy-policy';
  static const String _termsOfServiceUrl = 'https://example.com/terms';
  static const String _supportEmail = 'support@example.com';

  @override
  void initState() {
    super.initState();
    // FirebaseService.instance.logScreenView('SettingsScreen');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<AppThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: EdgeInsets.only(bottom: 24.h),
        children: [
          const _SectionHeader('Appearance'),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark mode'),
            subtitle: Text(_themeModeLabel(themeProvider.themeMode)),
            onTap: () => _showThemeDialog(context, themeProvider),
          ),
          const _SectionHeader('Language'),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('Language'),
            subtitle: Text(LocaleProvider
                    .localeNames[localeProvider.locale.languageCode] ??
                'English'),
            onTap: () => _showLanguageDialog(context, localeProvider),
          ),
          const _SectionHeader('App policy'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy policy'),
            subtitle: const Text('Read how your data is handled'),
            onTap: () => _openUrl(_privacyPolicyUrl),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of service'),
            subtitle: const Text('Review the rules for using the app'),
            onTap: () => _openUrl(_termsOfServiceUrl),
          ),
          ListTile(
            leading: const Icon(Icons.support_agent_outlined),
            title: const Text('Contact support'),
            subtitle: const Text(_supportEmail),
            onTap: () => _openUrl('mailto:$_supportEmail'),
          ),
          const _SectionHeader('Feedback'),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Rate the App'),
            subtitle: const Text('Open the native in-app review prompt'),
            // onTap: () => ReviewService.instance.requestReviewNow(),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('In-app review not implemented.')),
              );
            },
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showThemeDialog(BuildContext ctx, AppThemeProvider provider) {
    showDialog(
      context: ctx,
      builder: (_) => SimpleDialog(
        title: const Text('Choose dark mode'),
        children: ThemeMode.values
            .map((mode) => SimpleDialogOption(
                  onPressed: () {
                    provider.setThemeMode(mode);
                    Navigator.pop(ctx);
                  },
                  child: Row(
                    children: [
                      Icon(
                        mode == provider.themeMode
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(_themeModeLabel(mode)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  void _showLanguageDialog(BuildContext ctx, LocaleProvider provider) {
    showDialog(
      context: ctx,
      builder: (_) => SimpleDialog(
        title: const Text('Choose Language'),
        children: LocaleProvider.supportedLocales.map((locale) {
          final name = LocaleProvider.localeNames[locale.languageCode] ??
              locale.languageCode;
          final selected = locale == provider.locale;
          return SimpleDialogOption(
            onPressed: () {
              provider.setLocale(locale);
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(name),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the requested link.')),
      );
    }
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Follow system';
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 4.h),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 12.sp,
              letterSpacing: 1.2.w,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

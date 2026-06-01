import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/home_widget_service.dart';
import '../utils/review_service.dart';
import '../utils/share_service.dart';
import 'share_prompt_dialog.dart';

/// Quick actions for retention: widget, share, rate.
class EngagementActions extends StatelessWidget {
  const EngagementActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
              child: Text(
                'Grow & stay connected',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.widgets_outlined),
              title: const Text('Home screen widget'),
              subtitle: const Text('Glance info without opening the app'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _onAddWidget(context),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const Icon(Icons.ios_share_outlined),
              title: const Text('Invite a friend'),
              subtitle: const Text('Share the app with your network'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _onShare(context),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const Icon(Icons.star_outline),
              title: const Text('Rate the app'),
              subtitle: const Text('Opens native star rating sheet'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => ReviewService.instance.requestReviewNow(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onShare(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    await ShareService.instance.shareApp(sharePositionOrigin: origin);
  }

  Future<void> _onAddWidget(BuildContext context) async {
    await HomeWidgetService.instance.syncFromApp();

    final pinSupported = await HomeWidgetService.instance.isPinSupported();
    if (!context.mounted) return;
    if (pinSupported) {
      await HomeWidgetService.instance.requestPinWidget();
      return;
    }

    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add home screen widget'),
        content: const Text(
          'Long-press your home screen → Widgets → find this app → '
          'drag the widget onto your screen.\n\n'
          'iOS: add a Widget Extension in Xcode (see README).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

/// Runs session tracking for review + share prompts (call from HomeScreen).
Future<void> runEngagementSessionHooks(BuildContext context) async {
  await HomeWidgetService.instance.initialize();
  await HomeWidgetService.instance.syncFromApp();

  // Native review may appear without a dialog (platform throttled).
  await ReviewService.instance.trackSessionAndPromptIfEligible();

  if (!context.mounted) return;
  final shouldShare = await ShareService.instance.shouldShowSharePrompt();
  if (!context.mounted) return;
  if (shouldShare) {
    await showSharePromptDialog(context);
  }
}

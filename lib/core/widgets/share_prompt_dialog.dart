import 'package:flutter/material.dart';

import '../utils/share_service.dart';

/// Gentle invite to share after the user has engaged a few times.
Future<void> showSharePromptDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.ios_share_rounded, size: 40),
      title: const Text('Share with friends?'),
      content: const Text(
        'Know someone who would find this useful? '
        'Send them a link — it helps the app grow.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Maybe later'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Share'),
        ),
      ],
    ),
  );

  await ShareService.instance.markSharePromptShown();

  if (result == true && context.mounted) {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    await ShareService.instance.shareApp(sharePositionOrigin: origin);
  }
}

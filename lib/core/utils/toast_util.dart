import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastUtil {
  ToastUtil._();

  static ToastificationItem show(
    String message, {
    String? title,
    ToastificationType type = ToastificationType.info,
    ToastificationStyle style = ToastificationStyle.flatColored,
    Duration autoCloseDuration = const Duration(seconds: 4),
  }) {
    return toastification.show(
      type: type,
      style: style,
      title: Text(title ?? _defaultTitle(type)),
      description: Text(message),
      autoCloseDuration: autoCloseDuration,
      alignment: Alignment.topRight,
    );
  }

  static ToastificationItem success(
    String message, {
    String title = 'Success',
  }) {
    return show(
      message,
      title: title,
      type: ToastificationType.success,
    );
  }

  static ToastificationItem error(
    String message, {
    String title = 'Error',
  }) {
    return show(
      message,
      title: title,
      type: ToastificationType.error,
    );
  }

  static ToastificationItem info(
    String message, {
    String title = 'Info',
  }) {
    return show(
      message,
      title: title,
      type: ToastificationType.info,
    );
  }

  static String _defaultTitle(ToastificationType type) {
    switch (type) {
      case ToastificationType.success:
        return 'Success';
      case ToastificationType.error:
        return 'Error';
      case ToastificationType.warning:
        return 'Warning';
      case ToastificationType.info:
        return 'Info';
    }

    throw StateError('Unsupported toast type: $type');
  }
}

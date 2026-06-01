import 'dart:io';

Future<void> run(String command) async {
  print('\n> $command');

  final result = await Process.run(
    Platform.isWindows ? 'cmd' : 'sh',
    Platform.isWindows ? ['/c', command] : ['-c', command],
    runInShell: true,
  );

  stdout.write(result.stdout);
  stderr.write(result.stderr);

  if (result.exitCode != 0) {
    throw Exception('Command failed: $command');
  }
}

Future<void> main() async {
  await run('flutter pub run rename setAppName --value "GSTmate"');

  await run(
    'flutter pub run change_app_package_name:main com.yourcompany.gstmate',
  );

  await run('flutter pub run flutter_launcher_icons');

  const widgetFile =
      'android/app/src/main/kotlin/com/example/starterapp/StarterAppWidgetProvider.kt';

  final file = File(widgetFile);
  if (await file.exists()) {
    await file.delete();
    print('Deleted $widgetFile');
  }

  await run('flutter clean');
  await run('flutter pub get');

  if (Platform.isWindows) {
    await run('cd android && gradlew clean');
  } else {
    await run('cd android && ./gradlew clean');
  }

  await run('flutter run');
}

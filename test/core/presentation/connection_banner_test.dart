import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/core/presentation/connection_banner.dart';
import 'package:memory_notes/core/services/connection_service.dart';
import 'package:supa_manager/supa_manager.dart';

void main() {
  testWidgets('banner distinguishes offline from server failure and clears after success', (tester) async {
    final connection = ConnectionService();
    connection.updateConnectivity([ConnectivityResult.none]);
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: ConnectionBanner(connection: connection, onRetry: () async {}),
    )));
    expect(find.text('No internet connection'), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    connection.updateConnectivity([ConnectivityResult.wifi]);
    connection.reportFailure(TimeoutException('backend not reachable'));
    await tester.pump();
    expect(find.text('Unable to reach the server'), findsOneWidget);
    await connection.run(() async => const Result<int>.success(1));
    await tester.pump();
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('offline banner fits a narrow screen with large text', (tester) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final connection = ConnectionService()..updateConnectivity([ConnectivityResult.none]);
    await tester.pumpWidget(MaterialApp(home: MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(2)),
      child: Scaffold(body: Column(children: [
        ConnectionBanner(connection: connection, onRetry: () async {}),
        const Expanded(child: Text('Loaded notes')),
      ])),
    )));
    expect(find.text('Loaded notes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

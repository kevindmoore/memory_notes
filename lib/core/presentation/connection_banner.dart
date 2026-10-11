import 'package:flutter/material.dart';
import 'package:memory_notes/core/services/connection_service.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:signals/signals_flutter.dart';

class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({required this.connection, required this.onRetry, super.key});

  final ConnectionService connection;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => SignalBuilder(builder: (context) {
    final status = connection.status.value;
    if (status == ConnectionStatus.online || status == ConnectionStatus.unknown) {
      return const SizedBox.shrink();
    }
    final offline = status == ConnectionStatus.offline;
    return Material(
      color: AppColors.surfaceVariant,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(offline ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
                  color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  offline ? 'No internet connection' : 'Unable to reach the server',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
              TextButton(
                onPressed: connection.isRetrying.value
                    ? null : () => connection.retry(onRetry),
                child: Text(connection.isRetrying.value ? 'Retrying…' : 'Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  });
}

class LoadErrorView extends StatelessWidget {
  const LoadErrorView({required this.error, required this.onRetry, super.key});

  final String error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.textSecondary, size: 40),
          const SizedBox(height: 12),
          Text(ConnectionService.loadErrorMessage(error),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}

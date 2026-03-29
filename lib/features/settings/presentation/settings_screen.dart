import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:memory_notes/app/router/app_router.dart';
import 'package:memory_notes/core/theme/app_theme.dart';
import 'package:memory_notes/features/auth/application/auth_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';

@RoutePage(name: 'SettingsRoute')
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    required this.auth,
    super.key,
  });

  final AuthController auth;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = '${info.version} (${info.buildNumber})');
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileSubtitle =
        widget.auth.userName?.trim().isNotEmpty == true
            ? widget.auth.userName!.trim()
            : (widget.auth.userEmail ?? 'Unknown');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings',
            style:
                TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 8),
                  const _SectionHeader('Account'),
                  _SettingsTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Profile',
                    subtitle: profileSubtitle,
                  ),
                  const SizedBox(height: 16),
                  const _SectionHeader('About'),
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Version',
                    subtitle: _version,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
              child: _SettingsTile(
                icon: Icons.logout_rounded,
                title: 'Sign Out',
                titleColor: AppColors.error,
                iconColor: AppColors.error,
                onTap: () {
                  widget.auth.logout();
                  if (context.mounted) {
                    context.router.replaceAll([LoginRoute(onResult: (_) {}, auth: widget.auth)]);
                  }
                },
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textDisabled,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color titleColor;
  final Color iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.titleColor = AppColors.textPrimary,
    this.iconColor = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              color: titleColor, fontSize: 15, fontWeight: FontWeight.w500)),
                      if (subtitle != null)
                        Text(subtitle!,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textDisabled, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

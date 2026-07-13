import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:memory_notes/app/router/app_router.dart';
import 'package:memory_notes/core/services/app_services.dart';
import 'package:memory_notes/core/theme/app_theme.dart';

@RoutePage(name: 'MainShellRoute')
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  bool _didInitializeSync = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitializeSync) return;
    _didInitializeSync = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppServices.instance.notesSync.initialize();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      AppServices.instance.notesSync.handleAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    return AutoTabsScaffold(
      routes: const [
        InstantNotesTabRoute(),
        NotesTabRoute(),
        SearchTabRoute(),
        SettingsTabRoute(),
      ],
      bottomNavigationBuilder: (context, tabsRouter) {
        if (isKeyboardVisible) {
          return const SizedBox.shrink();
        }
        return _AppBottomNav(tabsRouter: tabsRouter);
      },
    );
  }
}

class _AppBottomNav extends StatelessWidget {
  final TabsRouter tabsRouter;

  const _AppBottomNav({required this.tabsRouter});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navBackground,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: tabsRouter.activeIndex,
        onTap: tabsRouter.setActiveIndex,
        backgroundColor: AppColors.navBackground,
        selectedItemColor: AppColors.navActive,
        unselectedItemColor: AppColors.navInactive,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.mic_rounded), label: 'Instant'),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted_rounded),
            label: 'Lists',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}

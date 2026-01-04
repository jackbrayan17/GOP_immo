import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/dashboard_screen.dart';
import 'screens/forms/assign_provider_screen.dart';
import 'screens/forms/contract_form_screen.dart';
import 'screens/forms/media_upload_screen.dart';
import 'screens/forms/payment_form_screen.dart';
import 'screens/forms/property_form_screen.dart';
import 'screens/forms/report_form_screen.dart';
import 'screens/home_screen.dart';
import 'screens/inbox_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/properties_screen.dart';
import 'state/app_state.dart';
import 'widgets/app_background.dart';

enum AppDrawerAction {
  home,
  marketplace,
  dashboard,
  inbox,
  properties,
  contract,
  payment,
  report,
  assignProvider,
  media,
  profile,
  logout,
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    MarketplaceScreen(embedded: true),
    DashboardScreen(),
    InboxScreen(),
  ];

  void _onDrawerAction(BuildContext context, AppDrawerAction action) {
    Navigator.pop(context);
    switch (action) {
      case AppDrawerAction.home:
        context.read<AppState>().setNavIndex(0);
        break;
      case AppDrawerAction.marketplace:
        context.read<AppState>().setNavIndex(1);
        break;
      case AppDrawerAction.dashboard:
        context.read<AppState>().setNavIndex(2);
        break;
      case AppDrawerAction.inbox:
        context.read<AppState>().setNavIndex(3);
        break;
      case AppDrawerAction.properties:
        _push(context, const PropertiesScreen());
        break;
      case AppDrawerAction.contract:
        _push(context, const ContractFormScreen());
        break;
      case AppDrawerAction.payment:
        _push(context, const PaymentFormScreen());
        break;
      case AppDrawerAction.report:
        _push(context, const ReportFormScreen());
        break;
      case AppDrawerAction.assignProvider:
        _push(context, const AssignProviderScreen());
        break;
      case AppDrawerAction.media:
        _push(context, const MediaUploadScreen());
        break;
      case AppDrawerAction.profile:
        _push(context, const ProfileScreen());
        break;
      case AppDrawerAction.logout:
        context.read<AppState>().logout();
        break;
    }
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.watch<AppState>().navIndex;
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 980;
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Row(
              children: [
                Image.asset(
                  'gop-logo.png',
                  height: 28,
                  width: 28,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                const Text('GOP Immo'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _push(context, const MarketplaceScreen()),
              ),
              IconButton(
                icon: const Icon(Icons.mail_outline),
                onPressed: () => _push(context, const InboxScreen()),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () => _push(context, const ProfileScreen()),
              ),
              const SizedBox(width: 8),
            ],
          ),
          drawer: useRail
              ? null
              : AppDrawer(
                  onSelect: (action) => _onDrawerAction(context, action),
                ),
          floatingActionButton: selectedIndex == 2
              ? FloatingActionButton.extended(
                  onPressed: () => _push(context, const PropertyFormScreen()),
                  icon: const Icon(Icons.add_home_work_outlined),
                  label: const Text('Ajouter un bien'),
                )
              : null,
          body: Stack(
            children: [
              const AppBackground(),
              SafeArea(
                child: Row(
                  children: [
                    if (useRail)
                      NavigationRail(
                        selectedIndex: selectedIndex,
                        onDestinationSelected: (index) => context.read<AppState>().setNavIndex(index),
                        extended: true,
                        labelType: NavigationRailLabelType.none,
                        leading: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Image.asset(
                            'gop-logo.png',
                            height: 36,
                            width: 36,
                            fit: BoxFit.contain,
                          ),
                        ),
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.home_outlined),
                            selectedIcon: Icon(Icons.home),
                            label: Text('Accueil'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.handyman_outlined),
                            selectedIcon: Icon(Icons.handyman),
                            label: Text('Marketplace'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.grid_view_outlined),
                            selectedIcon: Icon(Icons.grid_view),
                            label: Text('Dashboard'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.chat_bubble_outline),
                            selectedIcon: Icon(Icons.chat_bubble),
                            label: Text('Messagerie'),
                          ),
                        ],
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        child: IndexedStack(
                          index: selectedIndex,
                          children: _screens,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: useRail
              ? null
              : BottomNavigationBar(
                  currentIndex: selectedIndex,
                  onTap: (index) => context.read<AppState>().setNavIndex(index),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      label: 'Accueil',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.handyman_outlined),
                      label: 'Marketplace',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.grid_view_outlined),
                      label: 'Dashboard',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.chat_bubble_outline),
                      label: 'Messagerie',
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.onSelect});

  final void Function(AppDrawerAction action) onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = context.watch<AppState>().currentUser;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'gop-logo.png',
                        height: 28,
                        width: 28,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'GOP Immo',
                        style: textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user.name,
                    style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          _DrawerItem(
            icon: Icons.home_outlined,
            label: 'Accueil',
            onTap: () => onSelect(AppDrawerAction.home),
          ),
          _DrawerItem(
            icon: Icons.handyman_outlined,
            label: 'Marketplace',
            onTap: () => onSelect(AppDrawerAction.marketplace),
          ),
          _DrawerItem(
            icon: Icons.grid_view_outlined,
            label: 'Dashboard',
            onTap: () => onSelect(AppDrawerAction.dashboard),
          ),
          _DrawerItem(
            icon: Icons.chat_bubble_outline,
            label: 'Messagerie',
            onTap: () => onSelect(AppDrawerAction.inbox),
          ),
          const Divider(),
          _DrawerItem(
            icon: Icons.home_work_outlined,
            label: 'Mes biens',
            onTap: () => onSelect(AppDrawerAction.properties),
          ),
          _DrawerItem(
            icon: Icons.assignment_outlined,
            label: 'Nouveau contrat',
            onTap: () => onSelect(AppDrawerAction.contract),
          ),
          _DrawerItem(
            icon: Icons.payments_outlined,
            label: 'Nouveau paiement',
            onTap: () => onSelect(AppDrawerAction.payment),
          ),
          _DrawerItem(
            icon: Icons.fact_check_outlined,
            label: 'Rapport',
            onTap: () => onSelect(AppDrawerAction.report),
          ),
          _DrawerItem(
            icon: Icons.people_outline,
            label: 'Associer prestataire',
            onTap: () => onSelect(AppDrawerAction.assignProvider),
          ),
          _DrawerItem(
            icon: Icons.perm_media_outlined,
            label: 'Medias',
            onTap: () => onSelect(AppDrawerAction.media),
          ),
          const Divider(),
          _DrawerItem(
            icon: Icons.person_outline,
            label: 'Profil',
            onTap: () => onSelect(AppDrawerAction.profile),
          ),
          _DrawerItem(
            icon: Icons.logout,
            label: 'Deconnexion',
            onTap: () => onSelect(AppDrawerAction.logout),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }
}

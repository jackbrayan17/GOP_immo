import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'screens/forms/assign_provider_screen.dart';
import 'screens/forms/contract_form_screen.dart';
import 'screens/forms/media_upload_screen.dart';
import 'screens/forms/payment_form_screen.dart';
import 'screens/forms/property_form_screen.dart';
import 'screens/forms/report_form_screen.dart';
import 'screens/home_screen.dart';
import 'screens/inbox_screen.dart';
import 'screens/login_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/properties_screen.dart';
import 'screens/signup_choice_screen.dart';
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
  login,
  signup,
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MarketplaceScreen(),
    DashboardScreen(),
    InboxScreen(),
  ];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onDrawerAction(AppDrawerAction action) {
    Navigator.pop(context);
    switch (action) {
      case AppDrawerAction.home:
        _onNavTapped(0);
        break;
      case AppDrawerAction.marketplace:
        _onNavTapped(1);
        break;
      case AppDrawerAction.dashboard:
        _onNavTapped(2);
        break;
      case AppDrawerAction.inbox:
        _onNavTapped(3);
        break;
      case AppDrawerAction.properties:
        _push(const PropertiesScreen());
        break;
      case AppDrawerAction.contract:
        _push(const ContractFormScreen());
        break;
      case AppDrawerAction.payment:
        _push(const PaymentFormScreen());
        break;
      case AppDrawerAction.report:
        _push(const ReportFormScreen());
        break;
      case AppDrawerAction.assignProvider:
        _push(const AssignProviderScreen());
        break;
      case AppDrawerAction.media:
        _push(const MediaUploadScreen());
        break;
      case AppDrawerAction.profile:
        _push(const ProfileScreen());
        break;
      case AppDrawerAction.login:
        _push(const LoginScreen());
        break;
      case AppDrawerAction.signup:
        _push(const SignupChoiceScreen());
        break;
    }
  }

  void _push(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  FloatingActionButton? _buildFab() {
    if (_selectedIndex == 2) {
      return FloatingActionButton.extended(
        onPressed: () => _push(const PropertyFormScreen()),
        icon: const Icon(Icons.add_home_work_outlined),
        label: const Text('Ajouter un bien'),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 980;
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('GP Immo'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _push(const MarketplaceScreen()),
              ),
              IconButton(
                icon: const Icon(Icons.mail_outline),
                onPressed: () => _push(const InboxScreen()),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () => _push(const ProfileScreen()),
              ),
              const SizedBox(width: 8),
            ],
          ),
          drawer: useRail ? null : AppDrawer(onSelect: _onDrawerAction),
          floatingActionButton: _buildFab(),
          body: Stack(
            children: [
              const AppBackground(),
              SafeArea(
                child: Row(
                  children: [
                    if (useRail)
                      NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: _onNavTapped,
                        extended: true,
                        labelType: NavigationRailLabelType.none,
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
                          index: _selectedIndex,
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
                  currentIndex: _selectedIndex,
                  onTap: _onNavTapped,
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
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
              child: Text(
                'GP Immo',
                style: textTheme.titleLarge?.copyWith(color: Colors.white),
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
            icon: Icons.login_outlined,
            label: 'Connexion',
            onTap: () => onSelect(AppDrawerAction.login),
          ),
          _DrawerItem(
            icon: Icons.person_add_alt_outlined,
            label: 'Inscription',
            onTap: () => onSelect(AppDrawerAction.signup),
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

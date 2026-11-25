import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/data/portfolio_menu.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/services/project_refresh_notifier.dart';
import 'package:myportofolio_mobile/utils/portfolio_route_observer.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatelessWidget {
  final PortfolioSection? activeSection;
  final bool isHome;

  /// Sumber data opsional yang diteruskan ke halaman kategori yang dibuka
  /// melalui drawer, sehingga drawer tidak terikat langsung pada data dummy.
  final PortfolioDataSource? dataSource;

  /// Callback opsional sebelum drawer menavigasikan keluar dari halaman aktif
  /// (misalnya untuk meminta konfirmasi sebelum membuang draf form yang berubah).
  final Future<bool> Function()? onWillNavigate;

  const LeftDrawer({
    super.key,
    this.activeSection,
    this.isHome = false,
    this.dataSource,
    this.onWillNavigate,
  });

  Future<void> _navigateToHome(BuildContext context) async {
    final navigator = Navigator.of(context);
    navigator.pop();
    if (isHome) return;

    if (onWillNavigate != null) {
      final shouldProceed = await onWillNavigate!();
      if (!shouldProceed || !navigator.mounted) return;
    }

    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
      return;
    }

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/'),
        builder: (context) => const MyHomePage(),
      ),
      (route) => false,
    );
  }

  Future<void> _navigateToSection(
    BuildContext context,
    PortfolioCategoryConfig category,
  ) async {
    final isCurrent = activeSection == category.section;
    final navigator = Navigator.of(context);
    navigator.pop();
    if (isCurrent) return;

    if (onWillNavigate != null) {
      final shouldProceed = await onWillNavigate!();
      if (!shouldProceed || !navigator.mounted) return;
    }

    // Jika rute kategori yang dituju sudah terbuka di bawah halaman saat ini
    // (mis. memilih Projects dari form yang dibuka lewat Projects), gunakan
    // kembali rute tersebut agar tidak menumpuk dua layar kategori berturut-turut.
    final existingRoute = portfolioRouteObserver.routeForName(
      navigator,
      category.routeName,
    );
    if (existingRoute != null) {
      navigator.popUntil((route) => route == existingRoute || route.isFirst);
      return;
    }

    final route = MaterialPageRoute(
      settings: RouteSettings(name: category.routeName),
      builder: (_) =>
          buildPortfolioSectionPage(category.section, dataSource: dataSource),
    );
    if (isHome) {
      navigator.push(route);
    } else if (portfolioRouteObserver.hasAnySectionRoute(navigator)) {
      // Berpindah ke kategori lain dari dalam form atau halaman kategori lain:
      // jaga stack tetap [Home, TargetSection] tanpa menggandakan halaman kategori.
      navigator.pushAndRemoveUntil(route, (existing) => existing.isFirst);
    } else {
      navigator.pushReplacement(route);
    }
  }

  Future<void> _openAddProject(BuildContext context) async {
    final navigator = Navigator.of(context);
    ProjectRefreshNotifier? refreshNotifier;
    try {
      refreshNotifier = context.read<ProjectRefreshNotifier>();
    } on ProviderNotFoundException {
      refreshNotifier = null;
    }
    navigator.pop();

    if (onWillNavigate != null) {
      final shouldProceed = await onWillNavigate!();
      if (!shouldProceed || !navigator.mounted) return;
    }

    final loggedIn = await ensureLoggedIn(navigator.context);
    if (!loggedIn || !navigator.mounted) return;

    final created = await navigator.push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const ProjectFormPage()),
    );
    if (created == true) {
      refreshNotifier?.requestRefresh();
    }
  }

  Future<void> _openLogin(BuildContext context) async {
    final navigator = Navigator.of(context);
    navigator.pop();
    await navigator.push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authState = context.read<AuthState>();
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();

    await authState.logout();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Berhasil logout.')));
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Portfolio',
                    style: TextStyle(
                      fontSize: 30,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Explore personal projects and experiences!',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            // Navigasi ke halaman utama portofolio
            onTap: () => _navigateToHome(context),
          ),
          ...portfolioCategoryConfigs.map(
            (category) => ListTile(
              leading: Icon(category.icon),
              title: Text(category.name),
              onTap: () => _navigateToSection(context, category),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add_box_outlined),
            title: const Text('Add Project'),
            onTap: () => _openAddProject(context),
          ),
          if (isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _handleLogout(context),
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () => _openLogin(context),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/data/portfolio_menu.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/services/project_refresh_notifier.dart';
import 'package:myportofolio_mobile/utils/portfolio_route_observer.dart';
import 'package:myportofolio_mobile/widgets/code_snippet_box.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

/// Root widget dari aplikasi MyPortfolio Mobile.
///
/// Mengatur konfigurasi dasar aplikasi seperti judul, tema warna Material 3,
/// resolver rute kategori untuk deep link/refresh web, dan menentukan
/// [MyHomePage] sebagai halaman utama aplikasi.
///
/// Jika [apiClient] disuntikkan dari luar (mis. untuk pengujian), pemanggil
/// tetap memegang kepemilikan lifecycle dan bertanggung jawab memanggil
/// `apiClient.close()`. Jika bernilai `null`, `MyApp` membuat dan menutup
/// instance [ApiClient] secara otomatis saat [Provider] di-dispose.
class MyApp extends StatelessWidget {
  const MyApp({super.key, this.apiClient, this.initialToken});

  final ApiClient? apiClient;
  final String? initialToken;

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    if (settings.name == Navigator.defaultRouteName) {
      return MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/'),
        builder: (_) => const MyHomePage(),
      );
    }
    final section = portfolioSectionFromRouteName(settings.name);
    if (section != null) {
      return MaterialPageRoute<void>(
        settings: RouteSettings(
          name: section.routeName,
          arguments: settings.arguments,
        ),
        builder: (_) => buildPortfolioSectionPage(section),
      );
    }
    return null;
  }

  List<Route<dynamic>> _onGenerateInitialRoutes(String initialRoute) {
    final homeRoute = MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/'),
      builder: (_) => const MyHomePage(),
    );
    final section = portfolioSectionFromRouteName(initialRoute);
    if (section != null) {
      final sectionRoute = _onGenerateRoute(
        RouteSettings(name: section.routeName),
      )!;
      return [homeRoute, sectionRoute];
    }
    return [homeRoute];
  }

  Route<dynamic> _onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/'),
      builder: (_) => const MyHomePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      secondary: Colors.amber[700],
    );

    return MultiProvider(
      providers: [
        Provider<ApiClient>(
          create: (_) => apiClient ?? ApiClient(),
          dispose: (_, client) {
            if (apiClient == null) {
              client.close();
            }
          },
        ),
        ChangeNotifierProvider<AuthState>(
          create: (context) =>
              AuthState(context.read<ApiClient>(), initialToken: initialToken),
        ),
        ChangeNotifierProvider<ProjectRefreshNotifier>(
          create: (_) => ProjectRefreshNotifier(),
        ),
      ],
      child: MaterialApp(
        title: 'MyPortfolio',
        navigatorObservers: [portfolioRouteObserver],
        onGenerateInitialRoutes: _onGenerateInitialRoutes,
        onGenerateRoute: _onGenerateRoute,
        onUnknownRoute: _onUnknownRoute,
        theme: ThemeData(
          colorScheme: colorScheme,
          appBarTheme: AppBarTheme(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 14.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              textStyle: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          extensions: const [CodeSnippetTheme.dark()],
          useMaterial3: true,
        ),
        builder: (context, child) {
          if (!kIsWeb || !kDebugMode || child == null) {
            return child ?? const SizedBox.shrink();
          }
          return _WebPhoneViewport(child: child);
        },
      ),
    );
  }
}

/// Membatasi tampilan debug Web agar menyerupai layar ponsel di Chrome desktop.
class _WebPhoneViewport extends StatelessWidget {
  final Widget child;

  const _WebPhoneViewport({required this.child});

  static const double _phoneWidth = 390.0;
  static const double _phoneMaxHeight = 844.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Jika viewport sudah seukuran ponsel (mis. lewat Device Toolbar), tampilkan penuh.
        if (constraints.maxWidth <= 430.0) {
          return child;
        }

        final availableHeight = (constraints.maxHeight - 32.0).clamp(
          480.0,
          _phoneMaxHeight,
        );
        final viewportSize = Size(_phoneWidth, availableHeight);
        final mediaQuery = MediaQuery.of(context);

        return ColoredBox(
          color: const Color(0xFF1E1E24),
          child: Center(
            child: Container(
              width: viewportSize.width,
              height: viewportSize.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x55000000),
                    blurRadius: 28.0,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: MediaQuery(
                  data: mediaQuery.copyWith(size: viewportSize),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

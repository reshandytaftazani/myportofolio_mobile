import 'package:material_ui/material_ui.dart';

/// Observer navigasi global yang melacak tumpukan rute aktif per [NavigatorState]
/// secara sinkron melalui lifecycle [NavigatorObserver], tanpa menyimpan state
/// rute di dalam widget UI.
class PortfolioRouteObserver extends NavigatorObserver {
  final Expando<List<Route<dynamic>>> _stacksByNavigator =
      Expando<List<Route<dynamic>>>();

  List<Route<dynamic>> _stackFor(NavigatorState navigator) {
    return _stacksByNavigator[navigator] ??= <Route<dynamic>>[];
  }

  /// Mengembalikan rute paling atas pada [navigator] yang cocok dengan
  /// [routeName], atau `null` bila belum ada di tumpukan rute aktif.
  Route<dynamic>? routeForName(NavigatorState navigator, String routeName) {
    final stack = _stacksByNavigator[navigator];
    if (stack == null) return null;
    for (var i = stack.length - 1; i >= 0; i--) {
      final route = stack[i];
      if (route.settings.name == routeName) {
        return route;
      }
    }
    return null;
  }

  /// Mengecek apakah terdapat minimal satu rute kategori (`/section/...`) yang
  /// sedang aktif di tumpukan [navigator].
  bool hasAnySectionRoute(NavigatorState navigator) {
    final stack = _stacksByNavigator[navigator];
    if (stack == null) return false;
    return stack.any(
      (route) => route.settings.name?.startsWith('/section/') ?? false,
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final nav = navigator;
    if (nav == null) return;
    final stack = _stackFor(nav);
    if (stack.isEmpty && previousRoute != null) {
      stack.add(previousRoute);
    }
    stack.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final nav = navigator;
    if (nav == null) return;
    _stacksByNavigator[nav]?.remove(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    final nav = navigator;
    if (nav == null) return;
    _stacksByNavigator[nav]?.remove(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final nav = navigator;
    if (nav == null) return;
    final stack = _stackFor(nav);
    if (oldRoute != null) {
      final index = stack.indexOf(oldRoute);
      if (index != -1) {
        if (newRoute != null) {
          stack[index] = newRoute;
        } else {
          stack.removeAt(index);
        }
        return;
      }
    }
    if (newRoute != null) {
      stack.add(newRoute);
    }
  }
}

/// Instance bersama [PortfolioRouteObserver] yang didaftarkan pada [MaterialApp].
final PortfolioRouteObserver portfolioRouteObserver = PortfolioRouteObserver();

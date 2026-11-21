import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

void main() {
  runApp(const MyApp());
}

/// Root widget dari aplikasi MyPortfolio Mobile.
///
/// Mengatur konfigurasi dasar aplikasi seperti judul, tema warna Material 3,
/// dan menentukan [MyHomePage] sebagai halaman utama aplikasi.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPortfolio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          secondary: Colors.amber[700],
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        if (!kIsWeb || !kDebugMode || child == null) {
          return child ?? const SizedBox.shrink();
        }
        return _WebPhoneViewport(child: child);
      },
      home: const MyHomePage(),
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

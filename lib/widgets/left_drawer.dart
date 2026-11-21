import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/portfolio_section_page.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  void _navigateToHome(BuildContext context) {
    final isHome = context.findAncestorWidgetOfExactType<MyHomePage>() != null;
    Navigator.pop(context);
    if (isHome) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage()),
      (route) => false,
    );
  }

  void _navigateToSection(BuildContext context, ItemHomepage item) {
    final currentSection =
        context.findAncestorWidgetOfExactType<PortfolioSectionPage>();
    final isCurrent = currentSection?.title == item.name;
    final isHome = context.findAncestorWidgetOfExactType<MyHomePage>() != null;
    Navigator.pop(context);
    if (isCurrent) return;

    final route = MaterialPageRoute(builder: item.pageBuilder);
    if (isHome) {
      Navigator.push(context, route);
    } else {
      Navigator.pushReplacement(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          ...portfolioMenuItems.map(
            (item) => ListTile(
              leading: Icon(item.icon),
              title: Text(item.name),
              onTap: () => _navigateToSection(context, item),
            ),
          ),
        ],
      ),
    );
  }
}

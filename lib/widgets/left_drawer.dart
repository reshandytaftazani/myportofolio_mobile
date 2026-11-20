import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  void _navigateToHome(BuildContext context) {
    final isHome = context.findAncestorWidgetOfExactType<MyHomePage>() != null;
    Navigator.pop(context);
    if (isHome) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
      (route) => false,
    );
  }

  void _navigateToForm<T extends Widget>(
    BuildContext context,
    WidgetBuilder builder,
  ) {
    final isCurrent = context.findAncestorWidgetOfExactType<T>() != null;
    final isHome = context.findAncestorWidgetOfExactType<MyHomePage>() != null;
    Navigator.pop(context);
    if (isCurrent) return;

    final route = MaterialPageRoute(builder: builder);
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
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            // Navigasi ke halaman tambah proyek
            onTap: () => _navigateToForm<ProjectFormPage>(
              context,
              (context) => const ProjectFormPage(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Tambah Pengalaman'),
            // Navigasi ke halaman tambah pengalaman
            onTap: () => _navigateToForm<ExperienceFormPage>(
              context,
              (context) => const ExperienceFormPage(),
            ),
          ),
        ],
      ),
    );
  }
}

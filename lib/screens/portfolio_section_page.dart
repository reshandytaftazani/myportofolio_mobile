import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/skill_form.dart';
import 'package:myportofolio_mobile/screens/tech_stack_form.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Daftar konfigurasi 4 bagian utama portofolio untuk beranda dan drawer.
final List<ItemHomepage> portfolioMenuItems = [
  ItemHomepage(
    name: "Projects",
    subtitle: "Projects & Tech Stack",
    icon: Icons.folder_outlined,
    color: Colors.indigo,
    pageBuilder: (_) => PortfolioSectionPage(
      title: "Projects",
      emptyMessage: "Tambahkan proyek portofolio atau kelola tech stack Anda.",
      icon: Icons.folder_outlined,
      accentColor: Colors.indigo,
      primaryAction: SectionAction(
        label: "Tambah Proyek",
        icon: Icons.add,
        builder: (_) => const ProjectFormPage(),
      ),
      secondaryAction: SectionAction(
        label: "Tambah Tech Stack",
        icon: Icons.layers_outlined,
        builder: (_) => const TechStackFormPage(),
      ),
    ),
  ),
  ItemHomepage(
    name: "Experiences",
    subtitle: "Kerja & Organisasi",
    icon: Icons.work_outline,
    color: const Color(0xFF0277BD),
    pageBuilder: (_) => PortfolioSectionPage(
      title: "Experiences",
      emptyMessage: "Catat pengalaman kerja, magang, atau organisasi Anda.",
      icon: Icons.work_outline,
      accentColor: const Color(0xFF0277BD),
      primaryAction: SectionAction(
        label: "Tambah Pengalaman",
        icon: Icons.add,
        builder: (_) => const ExperienceFormPage(),
      ),
    ),
  ),
  ItemHomepage(
    name: "Education",
    subtitle: "Riwayat Akademik",
    icon: Icons.school_outlined,
    color: const Color(0xFF00695C),
    pageBuilder: (_) => PortfolioSectionPage(
      title: "Education",
      emptyMessage: "Tambahkan riwayat sekolah atau perguruan tinggi Anda.",
      icon: Icons.school_outlined,
      accentColor: const Color(0xFF00695C),
      primaryAction: SectionAction(
        label: "Tambah Pendidikan",
        icon: Icons.add,
        builder: (_) => const EducationFormPage(),
      ),
    ),
  ),
  ItemHomepage(
    name: "Skills",
    subtitle: "Skill & Kode",
    icon: Icons.code_rounded,
    color: const Color(0xFF6A1B9A),
    pageBuilder: (_) => PortfolioSectionPage(
      title: "Skills",
      emptyMessage: "Tambahkan keahlian teknis beserta tingkat kemahirannya.",
      icon: Icons.code_rounded,
      accentColor: const Color(0xFF6A1B9A),
      primaryAction: SectionAction(
        label: "Tambah Keahlian",
        icon: Icons.add,
        builder: (_) => const SkillFormPage(),
      ),
    ),
  ),
];

/// Konfigurasi aksi tambahan pada halaman bagian portofolio.
class SectionAction {
  /// Label tombol aksi.
  final String label;

  /// Ikon tombol aksi.
  final IconData icon;

  /// Builder halaman tujuan saat tombol ditekan.
  final WidgetBuilder builder;

  /// Membuat instansi [SectionAction].
  const SectionAction({
    required this.label,
    required this.icon,
    required this.builder,
  });
}

/// Halaman bagian portofolio yang menyatukan tampilan daftar dan tombol tambah.
///
/// Menggantikan tombol "Lihat ..." dan "Tambah ..." yang sebelumnya terpisah
/// di menu utama agar alur navigasi lebih ringkas.
class PortfolioSectionPage extends StatelessWidget {
  /// Judul bagian pada AppBar.
  final String title;

  /// Deskripsi singkat saat daftar masih kosong.
  final String emptyMessage;

  /// Ikon representatif untuk bagian ini.
  final IconData icon;

  /// Warna aksen bagian ini.
  final Color accentColor;

  /// Aksi utama untuk menambah data pada bagian ini.
  final SectionAction primaryAction;

  /// Aksi sekunder opsional (misalnya Tambah Tech Stack pada bagian Proyek).
  final SectionAction? secondaryAction;

  /// Membuat instansi [PortfolioSectionPage].
  const PortfolioSectionPage({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.icon,
    required this.accentColor,
    required this.primaryAction,
    this.secondaryAction,
  });

  void _openPage(BuildContext context, WidgetBuilder builder) {
    Navigator.push(context, MaterialPageRoute(builder: builder));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 48.0, color: accentColor),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Belum ada data $title',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  emptyMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: () =>
                          _openPage(context, primaryAction.builder),
                      icon: Icon(primaryAction.icon),
                      label: Text(primaryAction.label),
                    ),
                    if (secondaryAction != null)
                      OutlinedButton.icon(
                        onPressed: () =>
                            _openPage(context, secondaryAction!.builder),
                        icon: Icon(secondaryAction!.icon),
                        label: Text(secondaryAction!.label),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openPage(context, primaryAction.builder),
        icon: Icon(primaryAction.icon),
        label: Text(primaryAction.label),
      ),
    );
  }
}

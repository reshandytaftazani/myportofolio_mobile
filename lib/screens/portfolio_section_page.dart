import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/data/dummy_portfolio.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/skill_form.dart';
import 'package:myportofolio_mobile/screens/tech_stack_form.dart';
import 'package:myportofolio_mobile/widgets/education_card.dart';
import 'package:myportofolio_mobile/widgets/experience_card.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_item_card.dart';
import 'package:myportofolio_mobile/widgets/skill_card.dart';
import 'package:myportofolio_mobile/widgets/tech_stack_card.dart';

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
      primaryTabLabel: "Projects",
      itemCount: DummyPortfolioData.projects.length,
      itemBuilder: (context, index) => ProjectItemCard(
        project: DummyPortfolioData.projects[index],
      ),
      secondaryTabLabel: "Tech Stack",
      secondaryItemCount: DummyPortfolioData.techStacks.length,
      secondaryItemBuilder: (context, index) => TechStackCard(
        techStack: DummyPortfolioData.techStacks[index],
      ),
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
      itemCount: DummyPortfolioData.experiences.length,
      itemBuilder: (context, index) => ExperienceCard(
        experience: DummyPortfolioData.experiences[index],
      ),
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
      itemCount: DummyPortfolioData.educations.length,
      itemBuilder: (context, index) => EducationCard(
        education: DummyPortfolioData.educations[index],
      ),
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
      itemCount: DummyPortfolioData.skills.length,
      itemBuilder: (context, index) => SkillCard(
        skill: DummyPortfolioData.skills[index],
      ),
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
/// Menampilkan daftar item menggunakan [ListView.builder] atau fallback ke
/// tampilan kosong bila daftar belum memiliki data. Mendukung tab sekunder
/// (misalnya tab Tech Stack pada bagian Projects).
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

  /// Jumlah item pada daftar utama.
  final int itemCount;

  /// Builder item untuk daftar utama.
  final IndexedWidgetBuilder? itemBuilder;

  /// Label tab utama saat tab sekunder diaktifkan.
  final String? primaryTabLabel;

  /// Label tab sekunder opsional (misalnya "Tech Stack").
  final String? secondaryTabLabel;

  /// Jumlah item pada daftar tab sekunder.
  final int secondaryItemCount;

  /// Builder item untuk daftar tab sekunder.
  final IndexedWidgetBuilder? secondaryItemBuilder;

  /// Membuat instansi [PortfolioSectionPage].
  const PortfolioSectionPage({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.icon,
    required this.accentColor,
    required this.primaryAction,
    this.secondaryAction,
    this.itemCount = 0,
    this.itemBuilder,
    this.primaryTabLabel,
    this.secondaryTabLabel,
    this.secondaryItemCount = 0,
    this.secondaryItemBuilder,
  });

  void _openPage(BuildContext context, WidgetBuilder builder) {
    Navigator.push(context, MaterialPageRoute(builder: builder));
  }

  Widget _buildListOrEmpty({
    required BuildContext context,
    required int count,
    required IndexedWidgetBuilder? builder,
    required String emptyTitle,
  }) {
    if (count == 0 || builder == null) {
      return _EmptySectionView(
        title: emptyTitle,
        emptyMessage: emptyMessage,
        icon: icon,
        accentColor: accentColor,
        primaryAction: primaryAction,
        secondaryAction: secondaryAction,
        onOpenPage: (pageBuilder) => _openPage(context, pageBuilder),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
      itemCount: count,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: builder(context, index),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final hasTabs = secondaryTabLabel != null;

    if (!hasTabs) {
      return _buildListOrEmpty(
        context: context,
        count: itemCount,
        builder: itemBuilder,
        emptyTitle: 'Belum ada data $title',
      );
    }

    return Column(
      children: [
        if (secondaryAction != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _openPage(context, secondaryAction!.builder),
                icon: Icon(secondaryAction!.icon, size: 18),
                label: Text(secondaryAction!.label),
              ),
            ),
          ),
        Expanded(
          child: TabBarView(
            children: [
              _buildListOrEmpty(
                context: context,
                count: itemCount,
                builder: itemBuilder,
                emptyTitle: 'Belum ada data ${primaryTabLabel ?? title}',
              ),
              _buildListOrEmpty(
                context: context,
                count: secondaryItemCount,
                builder: secondaryItemBuilder,
                emptyTitle: 'Belum ada data $secondaryTabLabel',
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasTabs = secondaryTabLabel != null;

    final scaffold = Scaffold(
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
        bottom: hasTabs
            ? TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: primaryTabLabel ?? title),
                  Tab(text: secondaryTabLabel!),
                ],
              )
            : null,
      ),
      drawer: const LeftDrawer(),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openPage(context, primaryAction.builder),
        icon: Icon(primaryAction.icon),
        label: Text(primaryAction.label),
      ),
    );

    if (hasTabs) {
      return DefaultTabController(length: 2, child: scaffold);
    }
    return scaffold;
  }
}

class _EmptySectionView extends StatelessWidget {
  final String title;
  final String emptyMessage;
  final IconData icon;
  final Color accentColor;
  final SectionAction primaryAction;
  final SectionAction? secondaryAction;
  final ValueChanged<WidgetBuilder> onOpenPage;

  const _EmptySectionView({
    required this.title,
    required this.emptyMessage,
    required this.icon,
    required this.accentColor,
    required this.primaryAction,
    required this.secondaryAction,
    required this.onOpenPage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
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
                title,
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
                    onPressed: () => onOpenPage(primaryAction.builder),
                    icon: Icon(primaryAction.icon),
                    label: Text(primaryAction.label),
                  ),
                  if (secondaryAction != null)
                    OutlinedButton.icon(
                      onPressed: () => onOpenPage(secondaryAction!.builder),
                      icon: Icon(secondaryAction!.icon),
                      label: Text(secondaryAction!.label),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

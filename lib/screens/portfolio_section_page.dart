import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

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
  /// Identitas stabil bagian portofolio ini.
  final PortfolioSection section;

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
    required this.section,
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
                  color: Theme.of(context).colorScheme.outlineVariant
                      .withValues(alpha: 0.6),
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
      drawer: LeftDrawer(activeSection: section),
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

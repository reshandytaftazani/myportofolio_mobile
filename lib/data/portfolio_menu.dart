import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/data/dummy_portfolio.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/models/tech_stack.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/portfolio_detail_page.dart';
import 'package:myportofolio_mobile/screens/portfolio_section_page.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/skill_form.dart';
import 'package:myportofolio_mobile/screens/tech_stack_form.dart';
import 'package:myportofolio_mobile/widgets/education_card.dart';
import 'package:myportofolio_mobile/widgets/experience_card.dart';
import 'package:myportofolio_mobile/widgets/project_item_card.dart';
import 'package:myportofolio_mobile/widgets/project_list_view.dart';
import 'package:myportofolio_mobile/widgets/skill_card.dart';
import 'package:myportofolio_mobile/widgets/tech_stack_card.dart';

/// Kumpulan data portofolio yang disuntikkan ke halaman bagian portofolio.
class PortfolioDataSource {
  final List<Project> projects;
  final List<TechStack> techStacks;
  final List<Experience> experiences;
  final List<Education> educations;
  final List<Skill> skills;

  const PortfolioDataSource({
    this.projects = const [],
    this.techStacks = const [],
    this.experiences = const [],
    this.educations = const [],
    this.skills = const [],
  });

  /// Menggunakan data dummy lokal sementara sebelum integrasi backend Django.
  factory PortfolioDataSource.dummy() {
    return PortfolioDataSource(
      projects: DummyPortfolioData.projects,
      techStacks: DummyPortfolioData.techStacks,
      experiences: DummyPortfolioData.experiences,
      educations: DummyPortfolioData.educations,
      skills: DummyPortfolioData.skills,
    );
  }
}

/// Membangun halaman bagian portofolio untuk [section] dari [dataSource]
/// secara terpisah dari konfigurasi menu dan komponen navigasi.
Widget buildPortfolioSectionPage(
  PortfolioSection section, {
  PortfolioDataSource? dataSource,
}) {
  final data = dataSource ?? PortfolioDataSource.dummy();
  final config = categoryConfigForSection(section);

  switch (section) {
    case PortfolioSection.projects:
      return PortfolioSectionPage(
        section: config.section,
        title: config.name,
        emptyMessage:
            'Tambahkan proyek portofolio atau kelola tech stack Anda.',
        icon: config.icon,
        accentColor: config.color,
        primaryTabLabel: 'Projects',
        primaryBody: dataSource == null ? const ProjectListView() : null,
        itemCount: data.projects.length,
        itemBuilder: (context, index) {
          final project = data.projects[index];
          return ProjectItemCard(
            project: project,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PortfolioDetailPage.project(project),
              ),
            ),
          );
        },
        secondaryTabLabel: 'Tech Stack',
        secondaryItemCount: data.techStacks.length,
        secondaryItemBuilder: (context, index) {
          final techStack = data.techStacks[index];
          return TechStackCard(
            techStack: techStack,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PortfolioDetailPage.techStack(techStack),
              ),
            ),
          );
        },
        primaryAction: SectionAction(
          label: 'Tambah Proyek',
          icon: Icons.add,
          requiresAuth: true,
          builder: (_) => const ProjectFormPage(),
        ),
        secondaryAction: SectionAction(
          label: 'Tambah Tech Stack',
          icon: Icons.layers_outlined,
          builder: (_) => const TechStackFormPage(),
        ),
      );
    case PortfolioSection.experiences:
      return PortfolioSectionPage(
        section: config.section,
        title: config.name,
        emptyMessage: 'Catat pengalaman kerja, magang, atau organisasi Anda.',
        icon: config.icon,
        accentColor: config.color,
        itemCount: data.experiences.length,
        itemBuilder: (context, index) {
          final experience = data.experiences[index];
          return ExperienceCard(
            experience: experience,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PortfolioDetailPage.experience(experience),
              ),
            ),
          );
        },
        primaryAction: SectionAction(
          label: 'Tambah Pengalaman',
          icon: Icons.add,
          builder: (_) => const ExperienceFormPage(),
        ),
      );
    case PortfolioSection.education:
      return PortfolioSectionPage(
        section: config.section,
        title: config.name,
        emptyMessage: 'Tambahkan riwayat sekolah atau perguruan tinggi Anda.',
        icon: config.icon,
        accentColor: config.color,
        itemCount: data.educations.length,
        itemBuilder: (context, index) {
          final education = data.educations[index];
          return EducationCard(
            education: education,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PortfolioDetailPage.education(education),
              ),
            ),
          );
        },
        primaryAction: SectionAction(
          label: 'Tambah Pendidikan',
          icon: Icons.add,
          builder: (_) => const EducationFormPage(),
        ),
      );
    case PortfolioSection.skills:
      return PortfolioSectionPage(
        section: config.section,
        title: config.name,
        emptyMessage: 'Tambahkan keahlian teknis beserta tingkat kemahirannya.',
        icon: config.icon,
        accentColor: config.color,
        itemCount: data.skills.length,
        itemBuilder: (context, index) {
          final skill = data.skills[index];
          return SkillCard(
            skill: skill,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PortfolioDetailPage.skill(skill),
              ),
            ),
          );
        },
        primaryAction: SectionAction(
          label: 'Tambah Keahlian',
          icon: Icons.add,
          builder: (_) => const SkillFormPage(),
        ),
      );
  }
}

/// Merakit daftar konfigurasi 4 bagian utama portofolio dari [dataSource].
List<ItemHomepage> buildPortfolioMenuItems({PortfolioDataSource? dataSource}) {
  return portfolioCategoryConfigs
      .map(
        (config) => ItemHomepage(
          section: config.section,
          name: config.name,
          subtitle: config.subtitle,
          icon: config.icon,
          color: config.color,
          pageBuilder: (_) =>
              buildPortfolioSectionPage(config.section, dataSource: dataSource),
        ),
      )
      .toList();
}

/// Daftar konfigurasi 4 bagian utama portofolio bawaan untuk beranda dan drawer.
final List<ItemHomepage> portfolioMenuItems = buildPortfolioMenuItems();

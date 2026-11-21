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

/// Merakit daftar konfigurasi 4 bagian utama portofolio dari [dataSource].
List<ItemHomepage> buildPortfolioMenuItems({PortfolioDataSource? dataSource}) {
  final data = dataSource ?? PortfolioDataSource.dummy();
  return [
    ItemHomepage(
      section: PortfolioSection.projects,
      name: "Projects",
      subtitle: "Projects & Tech Stack",
      icon: Icons.folder_outlined,
      color: Colors.indigo,
      pageBuilder: (_) => PortfolioSectionPage(
        section: PortfolioSection.projects,
        title: "Projects",
        emptyMessage:
            "Tambahkan proyek portofolio atau kelola tech stack Anda.",
        icon: Icons.folder_outlined,
        accentColor: Colors.indigo,
        primaryTabLabel: "Projects",
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
        secondaryTabLabel: "Tech Stack",
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
      section: PortfolioSection.experiences,
      name: "Experiences",
      subtitle: "Kerja & Organisasi",
      icon: Icons.work_outline,
      color: const Color(0xFF0277BD),
      pageBuilder: (_) => PortfolioSectionPage(
        section: PortfolioSection.experiences,
        title: "Experiences",
        emptyMessage: "Catat pengalaman kerja, magang, atau organisasi Anda.",
        icon: Icons.work_outline,
        accentColor: const Color(0xFF0277BD),
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
          label: "Tambah Pengalaman",
          icon: Icons.add,
          builder: (_) => const ExperienceFormPage(),
        ),
      ),
    ),
    ItemHomepage(
      section: PortfolioSection.education,
      name: "Education",
      subtitle: "Riwayat Akademik",
      icon: Icons.school_outlined,
      color: const Color(0xFF00695C),
      pageBuilder: (_) => PortfolioSectionPage(
        section: PortfolioSection.education,
        title: "Education",
        emptyMessage: "Tambahkan riwayat sekolah atau perguruan tinggi Anda.",
        icon: Icons.school_outlined,
        accentColor: const Color(0xFF00695C),
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
          label: "Tambah Pendidikan",
          icon: Icons.add,
          builder: (_) => const EducationFormPage(),
        ),
      ),
    ),
    ItemHomepage(
      section: PortfolioSection.skills,
      name: "Skills",
      subtitle: "Skill & Kode",
      icon: Icons.code_rounded,
      color: const Color(0xFF6A1B9A),
      pageBuilder: (_) => PortfolioSectionPage(
        section: PortfolioSection.skills,
        title: "Skills",
        emptyMessage: "Tambahkan keahlian teknis beserta tingkat kemahirannya.",
        icon: Icons.code_rounded,
        accentColor: const Color(0xFF6A1B9A),
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
          label: "Tambah Keahlian",
          icon: Icons.add,
          builder: (_) => const SkillFormPage(),
        ),
      ),
    ),
  ];
}

/// Daftar konfigurasi 4 bagian utama portofolio bawaan untuk beranda dan drawer.
final List<ItemHomepage> portfolioMenuItems = buildPortfolioMenuItems();

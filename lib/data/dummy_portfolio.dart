import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/models/tech_stack.dart';

/// Data dummy lokal sementara untuk menguji tampilan daftar portofolio
/// sebelum integrasi API Django pada Tahap 4.
class DummyPortfolioData {
  DummyPortfolioData._();

  static const List<Project> projects = [
    Project(
      id: 'proj-1',
      title: 'MyPortfolio Mobile',
      description: 'Aplikasi mobile lintas platform berbasis Flutter untuk mengelola dan menampilkan portofolio proyek, pengalaman, pendidikan, serta keahlian teknis.',
      category: 'Mobile Development',
      techStack: 'Flutter, Dart, Django REST',
      projectUrl: 'https://github.com/reshandytaftazani/myportofolio_mobile',
      isFeatured: true,
      starCount: 8,
      isStarred: true,
      starredByNames: 'reshandy, budi',
    ),
    Project(
      id: 'proj-2',
      title: 'MyPortfolio Web',
      description: 'Situs portofolio personal berbasis Django dengan REST API, autentikasi berbasis cookie, serta fitur star untuk setiap item portofolio.',
      category: 'Web Development',
      techStack: 'Django, Python, Tailwind CSS',
      projectUrl: 'https://github.com/reshandytaftazani/myportofolio',
      isFeatured: true,
      starCount: 5,
    ),
    Project(
      id: 'proj-3',
      title: 'Campus Event Classifier',
      description: 'Model klasifikasi teks sederhana untuk mengelompokkan pengumuman kegiatan kampus berdasarkan kategori minat mahasiswa.',
      category: 'Machine Learning',
      techStack: 'Python, scikit-learn',
      isFeatured: false,
      starCount: 2,
    ),
  ];

  static const List<TechStack> techStacks = [
    TechStack(
      id: 1,
      name: 'Flutter',
      iconUrl: '',
      filename: 'lib/main.dart',
      codeSnippet: '''void main() {
  runApp(const MyApp());
}''',
      order: 1,
      starCount: 6,
      isStarred: true,
      starredByNames: 'reshandy',
    ),
    TechStack(
      id: 2,
      name: 'Django',
      iconUrl: '',
      filename: 'main/views.py',
      codeSnippet: '''def show_json(request):
    data = Project.objects.all()
    return JsonResponse(list(data.values()), safe=False)''',
      order: 2,
      starCount: 4,
    ),
    TechStack(
      id: 3,
      name: 'PostgreSQL',
      iconUrl: '',
      filename: 'schema.sql',
      codeSnippet: '''SELECT id, title, is_featured
FROM main_project
ORDER BY is_featured DESC;''',
      order: 3,
      starCount: 3,
    ),
  ];

  static final List<Experience> experiences = [
    Experience(
      id: 'exp-1',
      title: 'Teaching Assistant — Dasar Pemrograman',
      company: 'Fakultas Ilmu Komputer UI',
      description: 'Membantu mahasiswa memahami konsep dasar pemrograman Python, debugging tugas mingguan, serta melakukan review kode.',
      category: 'part-time',
      categoryDisplay: 'Part-Time',
      startedAt: DateTime(2025, 8, 1),
      isOngoing: true,
      starCount: 7,
      isStarred: true,
      starredByNames: 'reshandy',
    ),
    Experience(
      id: 'exp-2',
      title: 'Mobile Developer Intern',
      company: 'Tech Nusantara Studio',
      description: 'Mengembangkan fitur UI modular pada aplikasi Flutter, menyusun widget reusable, dan melakukan integrasi REST API.',
      category: 'internship',
      categoryDisplay: 'Internship',
      startedAt: DateTime(2025, 1, 10),
      endedAt: DateTime(2025, 5, 30),
      isOngoing: false,
      starCount: 4,
    ),
  ];

  static const List<Education> educations = [
    Education(
      id: 1,
      schoolName: 'Universitas Indonesia',
      period: '2024 – Sekarang',
      detail: 'S1 Ilmu Komputer, Fakultas Ilmu Komputer.',
      startYear: 2024,
      starCount: 5,
      isStarred: true,
      starredByNames: 'reshandy',
    ),
    Education(
      id: 2,
      schoolName: 'SMA Negeri 1',
      period: '2021 – 2024',
      detail: 'Jurusan Matematika dan Ilmu Pengetahuan Alam (MIPA).',
      startYear: 2021,
      starCount: 2,
    ),
  ];

  static const List<Skill> skills = [
    Skill(
      id: 'skill-1',
      title: 'Flutter & Dart',
      description: 'Membangun antarmuka Material 3 yang responsif, state management lokal, dan navigasi multi-halaman.',
      level: 'Intermediate',
      codeSnippet: '''Widget build(BuildContext context) {
  return const Scaffold(body: Center(child: Text('Hello Flutter')));
}''',
      starCount: 6,
      isStarred: true,
      starredByNames: 'reshandy',
    ),
    Skill(
      id: 'skill-2',
      title: 'Django & REST Framework',
      description: 'Merancang model relasional, serializer dengan validasi sanitasi, dan endpoint JSON untuk klien mobile.',
      level: 'Intermediate',
      codeSnippet: '''class ProjectSerializer(serializers.ModelSerializer):
    class Meta:
        model = Project
        fields = "__all__"''',
      starCount: 4,
    ),
    Skill(
      id: 'skill-3',
      title: 'Git & Collaborative Workflow',
      description: 'Mengelola branching per fitur, commit terstruktur, dan code review sebelum merge ke main.',
      level: 'Advanced',
      starCount: 3,
    ),
  ];
}

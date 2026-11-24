import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/models/skill.dart';
import 'package:myportofolio_mobile/models/tech_stack.dart';

void main() {
  group('Education serialization', () {
    test('fromJson parses full Django payload and defaults', () {
      final edu = Education.fromJson({
        'id': 7,
        'school_name': 'Universitas Indonesia',
        'period': '2024 - Sekarang',
        'detail': 'S1 Ilmu Komputer',
        'start_year': 2024,
        'star_count': 3,
        'is_starred': true,
        'starred_by_names': 'alice, bob',
      });

      expect(edu.id, 7);
      expect(edu.schoolName, 'Universitas Indonesia');
      expect(edu.period, '2024 - Sekarang');
      expect(edu.detail, 'S1 Ilmu Komputer');
      expect(edu.startYear, 2024);
      expect(edu.starCount, 3);
      expect(edu.isStarred, isTrue);
      expect(edu.starredByNames, 'alice, bob');

      final minimal = Education.fromJson({
        'school_name': 'SMA Negeri 1',
        'period': '2021 - 2024',
        'detail': 'MIPA',
        'start_year': 2021,
      });
      expect(minimal.id, isNull);
      expect(minimal.starCount, 0);
      expect(minimal.isStarred, isFalse);
      expect(minimal.starredByNames, '');
    });

    test('toJson serializes snake_case fields and omits null id', () {
      const withoutId = Education(
        schoolName: 'Universitas Indonesia',
        period: '2024 - Sekarang',
        detail: 'S1 Ilmu Komputer',
        startYear: 2024,
      );
      expect(withoutId.toJson(), {
        'school_name': 'Universitas Indonesia',
        'period': '2024 - Sekarang',
        'detail': 'S1 Ilmu Komputer',
        'start_year': 2024,
      });

      const withId = Education(
        id: 12,
        schoolName: 'Universitas Indonesia',
        period: '2024 - Sekarang',
        detail: 'S1 Ilmu Komputer',
        startYear: 2024,
      );
      expect(withId.toJson()['id'], 12);
    });
  });

  group('Experience serialization', () {
    test('fromJson parses dates, status, categoryDisplay, and star fields', () {
      final exp = Experience.fromJson({
        'id': 'uuid-exp-1',
        'title': 'Mobile Intern',
        'company': 'Tech Corp',
        'description': 'Membangun aplikasi Flutter.',
        'category': 'internship',
        'category_display': 'Internship',
        'thumbnail': 'https://example.com/thumb.png',
        'started_at': '2025-06-01',
        'ended_at': null,
        'is_ongoing': true,
        'star_count': 5,
        'is_starred': false,
        'starred_by_names': 'charlie',
      });

      expect(exp.id, 'uuid-exp-1');
      expect(exp.title, 'Mobile Intern');
      expect(exp.company, 'Tech Corp');
      expect(exp.description, 'Membangun aplikasi Flutter.');
      expect(exp.category, 'internship');
      expect(exp.categoryDisplay, 'Internship');
      expect(exp.categoryLabel, 'Internship');
      expect(exp.thumbnail, 'https://example.com/thumb.png');
      expect(exp.startedAt, DateTime(2025, 6, 1));
      expect(exp.endedAt, isNull);
      expect(exp.isOngoing, isTrue);
      expect(exp.starCount, 5);
      expect(exp.isStarred, isFalse);
      expect(exp.starredByNames, 'charlie');
    });

    test('toJson formats started_at and ended_at as YYYY-MM-DD', () {
      final exp = Experience(
        id: 'uuid-exp-2',
        title: 'Research Assistant',
        company: 'Lab AI',
        description: 'Riset NLP.',
        category: 'research',
        thumbnail: null,
        startedAt: DateTime(2025, 1, 5),
        endedAt: DateTime(2025, 11, 21),
      );

      expect(exp.toJson(), {
        'id': 'uuid-exp-2',
        'title': 'Research Assistant',
        'company': 'Lab AI',
        'description': 'Riset NLP.',
        'category': 'research',
        'thumbnail': null,
        'started_at': '2025-01-05',
        'ended_at': '2025-11-21',
      });
    });
  });

  group('Project serialization', () {
    test('fromJson parses all fields and star metadata', () {
      final project = Project.fromJson({
        'id': 'uuid-proj-1',
        'title': 'MyPortofolio Mobile',
        'description': 'Aplikasi portofolio Flutter.',
        'category': 'Mobile Development',
        'tech_stack': 'Flutter, Dart, Django',
        'project_url': 'https://github.com/example/app',
        'project_image_url': 'https://example.com/cover.png',
        'is_featured': true,
        'star_count': 9,
        'is_starred': true,
        'starred_by_names': 'alice, dave',
      });

      expect(project.id, 'uuid-proj-1');
      expect(project.title, 'MyPortofolio Mobile');
      expect(project.description, 'Aplikasi portofolio Flutter.');
      expect(project.category, 'Mobile Development');
      expect(project.techStack, 'Flutter, Dart, Django');
      expect(project.projectUrl, 'https://github.com/example/app');
      expect(project.projectImageUrl, 'https://example.com/cover.png');
      expect(project.isFeatured, isTrue);
      expect(project.starCount, 9);
      expect(project.isStarred, isTrue);
      expect(project.starredByNames, 'alice, dave');
    });

    test('toJson serializes snake_case fields', () {
      const project = Project(
        title: 'Web App',
        description: 'Portal akademik.',
        category: 'Web Development',
        techStack: 'Django',
        projectUrl: 'https://example.com',
        projectImageUrl: '',
        isFeatured: false,
      );

      expect(project.toJson(), {
        'title': 'Web App',
        'description': 'Portal akademik.',
        'category': 'Web Development',
        'tech_stack': 'Django',
        'project_url': 'https://example.com',
        'project_image_url': '',
        'is_featured': false,
      });
    });
  });

  group('Skill serialization', () {
    test('fromJson and toJson round-trip fields accurately', () {
      final skill = Skill.fromJson({
        'id': 'uuid-skill-1',
        'title': 'Flutter',
        'description': 'Pengembangan aplikasi mobile lintas platform.',
        'level': 'Intermediate',
        'code_snippet': 'Widget build(BuildContext context) => Container();',
        'star_count': 4,
        'is_starred': true,
        'starred_by_names': 'eve',
      });

      expect(skill.id, 'uuid-skill-1');
      expect(skill.title, 'Flutter');
      expect(
        skill.description,
        'Pengembangan aplikasi mobile lintas platform.',
      );
      expect(skill.level, 'Intermediate');
      expect(
        skill.codeSnippet,
        'Widget build(BuildContext context) => Container();',
      );
      expect(skill.starCount, 4);
      expect(skill.isStarred, isTrue);
      expect(skill.starredByNames, 'eve');

      expect(skill.toJson(), {
        'id': 'uuid-skill-1',
        'title': 'Flutter',
        'description': 'Pengembangan aplikasi mobile lintas platform.',
        'level': 'Intermediate',
        'code_snippet': 'Widget build(BuildContext context) => Container();',
      });
    });
  });

  group('TechStack serialization', () {
    test('fromJson and toJson handle order and star fields', () {
      final stack = TechStack.fromJson({
        'id': 3,
        'name': 'Django',
        'icon_url': 'https://cdn.example.com/django.svg',
        'filename': 'views.py',
        'code_snippet': 'def index(request):\n    return JsonResponse({})',
        'order': 2,
        'star_count': 6,
        'is_starred': false,
        'starred_by_names': 'frank',
      });

      expect(stack.id, 3);
      expect(stack.name, 'Django');
      expect(stack.iconUrl, 'https://cdn.example.com/django.svg');
      expect(stack.filename, 'views.py');
      expect(
        stack.codeSnippet,
        'def index(request):\n    return JsonResponse({})',
      );
      expect(stack.order, 2);
      expect(stack.starCount, 6);
      expect(stack.isStarred, isFalse);
      expect(stack.starredByNames, 'frank');

      expect(stack.toJson(), {
        'id': 3,
        'name': 'Django',
        'icon_url': 'https://cdn.example.com/django.svg',
        'filename': 'views.py',
        'code_snippet': 'def index(request):\n    return JsonResponse({})',
        'order': 2,
      });
    });
  });
}

import 'package:metas_app/features/projects/application/use_cases/get_daily_entry_by_date.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_milestone_sprints.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_pending_sprints.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_project_milestones.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_user_projects.use_case.dart';
import 'package:metas_app/features/projects/domain/entities/pending_sprint.dart';

/// Combina sprints pendientes de review/retrospectiva (API) con sprints activos
/// sin entrada diaria para la fecha local de hoy ([GET /api/daily-entries/date/:date?sprintId=]).
class LoadPendingRemindersUseCase {
  LoadPendingRemindersUseCase({
    required GetPendingSprintsUseCase getPendingSprintsUseCase,
    required GetUserProjectsUseCase getUserProjectsUseCase,
    required GetProjectMilestonesUseCase getProjectMilestonesUseCase,
    required GetMilestoneSprintsUseCase getMilestoneSprintsUseCase,
    required GetDailyEntryByDateUseCase getDailyEntryByDateUseCase,
  })  : _getPendingSprintsUseCase = getPendingSprintsUseCase,
        _getUserProjectsUseCase = getUserProjectsUseCase,
        _getProjectMilestonesUseCase = getProjectMilestonesUseCase,
        _getMilestoneSprintsUseCase = getMilestoneSprintsUseCase,
        _getDailyEntryByDateUseCase = getDailyEntryByDateUseCase;

  final GetPendingSprintsUseCase _getPendingSprintsUseCase;
  final GetUserProjectsUseCase _getUserProjectsUseCase;
  final GetProjectMilestonesUseCase _getProjectMilestonesUseCase;
  final GetMilestoneSprintsUseCase _getMilestoneSprintsUseCase;
  final GetDailyEntryByDateUseCase _getDailyEntryByDateUseCase;

  Future<List<PendingSprint>> call() async {
    final fromApi = await _getPendingSprintsUseCase();
    final bySprintId = <String, PendingSprint>{
      for (final p in fromApi) p.sprintId: p,
    };

    final today = _dateOnly(DateTime.now());

    final projects = await _getUserProjectsUseCase();
    if (projects.isEmpty) {
      return _sortedValues(bySprintId);
    }

    final milestonesPerProject = await Future.wait(
      projects.map((p) => _getProjectMilestonesUseCase(p.id)),
    );

    final candidates = <_ActiveSprintRef>[];
    for (var i = 0; i < projects.length; i++) {
      final project = projects[i];
      final milestones = milestonesPerProject[i];
      for (final m in milestones) {
        final sprints = await _getMilestoneSprintsUseCase(m.id);
        for (final s in sprints) {
          if (!_calendarDayInRange(s.startDate, s.endDate, today)) {
            continue;
          }
          candidates.add(
            _ActiveSprintRef(
              projectId: project.id,
              projectName: project.name,
              milestoneId: m.id,
              milestoneName: m.name,
              sprintId: s.id,
              sprintName: s.name,
              endDate: s.endDate,
            ),
          );
        }
      }
    }

    if (candidates.isEmpty) {
      return _sortedValues(bySprintId);
    }

    final missingFlags = await Future.wait(
      candidates.map((c) async {
        final entry = await _getDailyEntryByDateUseCase(today, c.sprintId);
        return entry == null;
      }),
    );

    for (var i = 0; i < candidates.length; i++) {
      if (!missingFlags[i]) continue;
      final c = candidates[i];

      final existing = bySprintId[c.sprintId];
      if (existing != null) {
        bySprintId[c.sprintId] = PendingSprint(
          sprintId: existing.sprintId,
          sprintName: existing.sprintName,
          endDate: existing.endDate,
          projectId: existing.projectId,
          projectName: existing.projectName,
          milestoneId: existing.milestoneId,
          milestoneName: existing.milestoneName,
          needsReview: existing.needsReview,
          needsRetrospective: existing.needsRetrospective,
          needsDaily: true,
        );
      } else {
        bySprintId[c.sprintId] = PendingSprint(
          sprintId: c.sprintId,
          sprintName: c.sprintName,
          endDate: c.endDate,
          projectId: c.projectId,
          projectName: c.projectName,
          milestoneId: c.milestoneId,
          milestoneName: c.milestoneName,
          needsReview: false,
          needsRetrospective: false,
          needsDaily: true,
        );
      }
    }

    return _sortedValues(bySprintId);
  }

  List<PendingSprint> _sortedValues(Map<String, PendingSprint> map) {
    final list = map.values.toList()
      ..sort((a, b) {
        final byProject = a.projectName.compareTo(b.projectName);
        if (byProject != 0) return byProject;
        return a.sprintName.compareTo(b.sprintName);
      });
    return list;
  }
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool _calendarDayInRange(DateTime start, DateTime end, DateTime day) {
  final sd = _dateOnly(start);
  final ed = _dateOnly(end);
  final x = _dateOnly(day);
  return !x.isBefore(sd) && !x.isAfter(ed);
}

class _ActiveSprintRef {
  final String projectId;
  final String projectName;
  final String milestoneId;
  final String milestoneName;
  final String sprintId;
  final String sprintName;
  final DateTime endDate;

  _ActiveSprintRef({
    required this.projectId,
    required this.projectName,
    required this.milestoneId,
    required this.milestoneName,
    required this.sprintId,
    required this.sprintName,
    required this.endDate,
  });
}

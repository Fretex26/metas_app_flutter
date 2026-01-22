import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/progress_indicator.dart';
import 'package:metas_app/features/auth/presentation/components/status_badge.dart';
import 'package:metas_app/features/projects/presentation/components/delete_confirmation_dialog.dart';
import 'package:metas_app/features/projects/presentation/components/milestone_card.dart';
import 'package:metas_app/features/projects/presentation/cubits/delete_project.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/delete_project.states.dart';
import 'package:metas_app/features/projects/presentation/cubits/edit_project.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/project_detail.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/project_detail.states.dart';
import 'package:metas_app/features/projects/presentation/pages/create_milestone.page.dart';
import 'package:metas_app/features/projects/presentation/pages/edit_project.page.dart';
import 'package:metas_app/features/projects/presentation/pages/milestone_detail.page.dart';

/// Página que muestra el detalle completo de un proyecto.
/// 
/// Muestra:
/// - Información del proyecto (nombre, descripción, estado, progreso)
/// - Lista de milestones con sus tarjetas
/// - Pull-to-refresh para actualizar
/// - FAB para crear nuevo milestone
/// - Botones de editar y eliminar en el AppBar
/// - Navegación al detalle de cada milestone
class ProjectDetailPage extends StatelessWidget {
  /// Identificador único del proyecto a mostrar
  final String projectId;

  /// Constructor de la página de detalle de proyecto
  const ProjectDetailPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return ProjectDetailCubit(
          getProjectByIdUseCase: context.read(),
          getProjectProgressUseCase: context.read(),
          getProjectMilestonesUseCase: context.read(),
        )..loadProject(projectId);
      },
      child: Builder(
        builder: (scaffoldContext) => BlocBuilder<ProjectDetailCubit, ProjectDetailState>(
          builder: (context, state) {
            if (state is ProjectDetailLoading) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Detalle del Proyecto'),
                ),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            if (state is ProjectDetailError) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Detalle del Proyecto'),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.message,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ProjectDetailCubit>().loadProject(projectId);
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ProjectDetailLoaded) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => EditProjectCubit(
                      updateProjectUseCase: context.read(),
                    ),
                  ),
                  BlocProvider(
                    create: (context) => DeleteProjectCubit(
                      deleteProjectUseCase: context.read(),
                    ),
                  ),
                ],
                child: _ProjectDetailContent(
                  project: state.project,
                  progress: state.progress,
                  milestones: state.milestones,
                  projectId: projectId,
                  scaffoldContext: scaffoldContext,
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('Detalle del Proyecto'),
              ),
              body: const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}

/// Widget interno que muestra el contenido del detalle del proyecto
/// con funcionalidad de edición y eliminación.
class _ProjectDetailContent extends StatelessWidget {
  final dynamic project;
  final dynamic progress;
  final List<dynamic> milestones;
  final String projectId;
  final BuildContext scaffoldContext;

  const _ProjectDetailContent({
    required this.project,
    required this.progress,
    required this.milestones,
    required this.projectId,
    required this.scaffoldContext,
  });

  Future<void> _handleEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => EditProjectCubit(
            updateProjectUseCase: context.read(),
          ),
          child: EditProjectPage(project: project),
        ),
      ),
    );

    if (result != null && scaffoldContext.mounted) {
      scaffoldContext.read<ProjectDetailCubit>().loadProject(projectId);
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context: context,
      title: 'Eliminar Proyecto',
      message: '¿Estás seguro de que deseas eliminar este proyecto? '
          'Esta acción eliminará permanentemente el proyecto, todos sus '
          'milestones, sprints, tasks, checklist items y datos relacionados. '
          'Esta acción no se puede deshacer.',
    );

    if (!confirmed) return;

    context.read<DeleteProjectCubit>().deleteProject(projectId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteProjectCubit, DeleteProjectState>(
      listener: (context, state) {
        if (state is DeleteProjectSuccess) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Proyecto eliminado exitosamente')),
          );
        } else if (state is DeleteProjectError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle del Proyecto'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _handleEdit(context),
            ),
            BlocBuilder<DeleteProjectCubit, DeleteProjectState>(
              builder: (context, deleteState) {
                final isDeleting = deleteState is DeleteProjectLoading;
                return IconButton(
                  icon: isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete),
                  onPressed: isDeleting ? null : () => _handleDelete(context),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            scaffoldContext.read<ProjectDetailCubit>().loadProject(projectId);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                project.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            StatusBadge(status: project.status ?? 'pending'),
                          ],
                        ),
                        if (project.description != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            project.description!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        MyProgressIndicator(
                          progress: progress.progressPercentage / 100,
                          label: 'Progreso del Proyecto',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${progress.completedTasks} de ${progress.totalTasks} tareas completadas',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Milestones',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${milestones.length} milestones',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (milestones.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay milestones aún',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...milestones.map((milestone) {
                    return MilestoneCard(
                      milestone: milestone,
                      onTap: () {
                        final cubit = scaffoldContext.read<ProjectDetailCubit>();
                        Navigator.push(
                          scaffoldContext,
                          MaterialPageRoute(
                            builder: (context) => MilestoneDetailPage(
                              projectId: projectId,
                              milestoneId: milestone.id,
                            ),
                          ),
                        ).then((_) {
                          if (scaffoldContext.mounted) {
                            cubit.loadProject(projectId);
                          }
                        });
                      },
                    );
                  }),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final cubit = scaffoldContext.read<ProjectDetailCubit>();
            Navigator.push(
              scaffoldContext,
              MaterialPageRoute(
                builder: (context) => CreateMilestonePage(projectId: projectId),
              ),
            ).then((_) {
              if (scaffoldContext.mounted) {
                cubit.loadProject(projectId);
              }
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

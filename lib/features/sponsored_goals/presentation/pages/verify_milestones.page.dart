import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/status_badge.dart';
import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/projects/domain/entities/project.dart';
import 'package:metas_app/features/sponsored_goals/application/use_cases/get_project_milestones.use_case.dart'
    as sponsored_goals_milestones;
import 'package:metas_app/features/sponsored_goals/application/use_cases/get_user_sponsored_projects.use_case.dart';
import 'package:metas_app/features/sponsored_goals/application/use_cases/update_sponsored_milestone_status.use_case.dart';
import 'package:metas_app/features/sponsored_goals/application/use_cases/verify_milestone.use_case.dart';
import 'package:metas_app/features/sponsored_goals/presentation/cubits/verify_milestones.cubit.dart';
import 'package:metas_app/features/sponsored_goals/presentation/cubits/verify_milestones.states.dart';

/// Página para que los sponsors busquen usuarios y verifiquen milestones.
///
/// Permite a los sponsors:
/// - Buscar un usuario por email
/// - Ver los proyectos patrocinados del usuario
/// - Ver las milestones de un proyecto
/// - Verificar milestones completadas
///
/// Basado en el diseño de las imágenes proporcionadas.
class VerifyMilestonesPage extends StatefulWidget {
  const VerifyMilestonesPage({super.key});

  @override
  State<VerifyMilestonesPage> createState() => _VerifyMilestonesPageState();
}

class _VerifyMilestonesPageState extends State<VerifyMilestonesPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _searchUser(BuildContext blocContext) {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(
        blocContext,
      ).showSnackBar(const SnackBar(content: Text('Ingresa un email válido')));
      return;
    }

    blocContext.read<VerifyMilestonesCubit>().loadUserProjects(email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VerifyMilestonesCubit(
        getUserSponsoredProjectsUseCase: context
            .read<GetUserSponsoredProjectsUseCase>(),
        getProjectMilestonesUseCase: context
            .read<
              sponsored_goals_milestones.GetSponsoredProjectMilestonesUseCase
            >(),
        verifyMilestoneUseCase: context.read<VerifyMilestoneUseCase>(),
        updateSponsoredMilestoneStatusUseCase: context
            .read<UpdateSponsoredMilestoneStatusUseCase>(),
      ),
      child: Builder(
        builder: (blocContext) => Scaffold(
          appBar: AppBar(title: const Text('Verificar Milestones')),
          body: BlocListener<VerifyMilestonesCubit, VerifyMilestonesState>(
            listener: (context, state) {
              if (state is VerifyMilestonesError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              if (state is VerifyMilestonesVerified) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Milestone verificada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Column(
              children: [
                // Barra de búsqueda
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email del usuario',
                            hintText: 'usuario@example.com',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onSubmitted: (_) => _searchUser(blocContext),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => _searchUser(blocContext),
                        child: const Text('Buscar'),
                      ),
                    ],
                  ),
                ),
                // Contenido
                Expanded(
                  child: BlocBuilder<VerifyMilestonesCubit, VerifyMilestonesState>(
                    builder: (context, state) {
                      if (state is VerifyMilestonesInitial) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search,
                                size: 64,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Busca un usuario por email para ver sus proyectos',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is VerifyMilestonesLoadingProjects) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is VerifyMilestonesLoadingMilestones) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final loadedState = state is VerifyMilestonesLoaded
                          ? state
                          : state is VerifyMilestonesUpdatingStatus
                          ? state.previousState
                          : null;

                      if (loadedState != null) {
                        if (loadedState.projects.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_open,
                                  size: 64,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No se encontraron proyectos patrocinados',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Row(
                          children: [
                            // Lista de proyectos
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                ),
                                child: ListView.builder(
                                  itemCount: loadedState.projects.length,
                                  itemBuilder: (context, index) {
                                    final project = loadedState.projects[index];
                                    final isSelected =
                                        loadedState.selectedProject?.id ==
                                        project.id;
                                    return ListTile(
                                      selected: isSelected,
                                      title: Text(project.name),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (project.description != null &&
                                              project.description!.isNotEmpty)
                                            Text(
                                              project.description!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          const SizedBox(height: 4),
                                          StatusBadge(
                                            status: project.status ?? 'pending',
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        context
                                            .read<VerifyMilestonesCubit>()
                                            .loadProjectMilestones(project.id);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Milestones del proyecto seleccionado
                            Expanded(
                              flex: 2,
                              child: loadedState.selectedProject == null
                                  ? Center(
                                      child: Text(
                                        'Selecciona un proyecto para ver sus milestones',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    )
                                  : _buildMilestonesList(
                                      context,
                                      loadedState.milestones,
                                      loadedState.selectedProject!,
                                    ),
                            ),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMilestonesList(
    BuildContext context,
    List<Milestone> milestones,
    Project project,
  ) {
    if (milestones.isEmpty) {
      return Center(
        child: Text(
          'Este proyecto no tiene milestones',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: milestones.length,
      itemBuilder: (context, index) {
        final milestone = milestones[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
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
                        milestone.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    StatusBadge(status: milestone.status),
                  ],
                ),
                if (milestone.description != null &&
                    milestone.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    milestone.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 16),
                BlocBuilder<VerifyMilestonesCubit, VerifyMilestonesState>(
                  builder: (context, state) {
                    final isUpdating =
                        state is VerifyMilestonesUpdatingStatus &&
                        state.milestoneId == milestone.id;
                    return SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: isUpdating
                            ? null
                            : () {
                                _showMilestoneStatusDialog(context, milestone);
                              },
                        icon: isUpdating
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.edit_note),
                        label: const Text('Cambiar estado'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMilestoneStatusDialog(BuildContext context, Milestone milestone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(milestone.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption(
              ctx: ctx,
              context: context,
              milestoneId: milestone.id,
              value: 'pending',
              label: 'Pendiente',
              currentStatus: milestone.status,
            ),
            _buildStatusOption(
              ctx: ctx,
              context: context,
              milestoneId: milestone.id,
              value: 'in_progress',
              label: 'En progreso',
              currentStatus: milestone.status,
            ),
            _buildStatusOption(
              ctx: ctx,
              context: context,
              milestoneId: milestone.id,
              value: 'completed',
              label: 'Completado',
              currentStatus: milestone.status,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption({
    required BuildContext ctx,
    required BuildContext context,
    required String milestoneId,
    required String value,
    required String label,
    required String currentStatus,
  }) {
    final isCurrent = value == currentStatus;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: StatusBadge(status: value),
      title: Text(label),
      trailing: isCurrent ? const Icon(Icons.check_circle) : null,
      onTap: () {
        Navigator.pop(ctx);
        context.read<VerifyMilestonesCubit>().updateMilestoneStatus(
          milestoneId,
          value,
        );
      },
    );
  }
}

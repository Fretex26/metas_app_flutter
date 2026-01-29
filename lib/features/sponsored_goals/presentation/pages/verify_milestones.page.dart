import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/components/status_badge.dart';
import 'package:metas_app/features/projects/domain/entities/milestone.dart';
import 'package:metas_app/features/projects/domain/entities/project.dart';
import 'package:metas_app/features/sponsored_goals/application/use_cases/get_project_milestones.use_case.dart' as sponsored_goals_milestones;
import 'package:metas_app/features/sponsored_goals/application/use_cases/get_user_sponsored_projects.use_case.dart';
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

  void _searchUser() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un email válido')),
      );
      return;
    }

    context.read<VerifyMilestonesCubit>().loadUserProjects(email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VerifyMilestonesCubit(
        getUserSponsoredProjectsUseCase:
            context.read<GetUserSponsoredProjectsUseCase>(),
        getProjectMilestonesUseCase:
            context.read<sponsored_goals_milestones.GetSponsoredProjectMilestonesUseCase>(),
        verifyMilestoneUseCase: context.read<VerifyMilestoneUseCase>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verificar Milestones'),
        ),
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
                        onSubmitted: (_) => _searchUser(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _searchUser,
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.5),
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

                    if (state is VerifyMilestonesLoaded) {
                      if (state.projects.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_open,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No se encontraron proyectos patrocinados',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
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
                                itemCount: state.projects.length,
                                itemBuilder: (context, index) {
                                  final project = state.projects[index];
                                  final isSelected =
                                      state.selectedProject?.id == project.id;
                                  return ListTile(
                                    selected: isSelected,
                                    title: Text(project.name),
                                    subtitle: project.description != null
                                        ? Text(
                                            project.description!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : null,
                                    trailing: StatusBadge(
                                      status: project.status ?? 'pending',
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
                            child: state.selectedProject == null
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
                                    state.milestones,
                                    state.selectedProject!,
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
        final canVerify = milestone.status == 'in_progress';
        final isVerifying = false; // TODO: obtener del estado

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
                if (canVerify)
                  BlocBuilder<VerifyMilestonesCubit, VerifyMilestonesState>(
                    builder: (context, state) {
                      final isVerifying = state is VerifyMilestonesVerifying &&
                          state.milestoneId == milestone.id;
                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: isVerifying
                              ? null
                              : () {
                                  _showVerifyConfirmationDialog(
                                    context,
                                    milestone,
                                  );
                                },
                          child: isVerifying
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Verificar Milestone'),
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

  void _showVerifyConfirmationDialog(
    BuildContext context,
    Milestone milestone,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verificar Milestone'),
        content: Text(
          '¿Estás seguro de que quieres verificar la milestone "${milestone.name}"? '
          'Esto marcará la milestone como completada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<VerifyMilestonesCubit>().verifyMilestone(milestone.id);
            },
            child: const Text('Verificar'),
          ),
        ],
      ),
    );
  }
}

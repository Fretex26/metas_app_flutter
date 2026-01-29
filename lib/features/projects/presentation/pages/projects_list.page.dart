import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/cubits/auth.cubit.dart';
import 'package:metas_app/features/projects/presentation/components/project_card.dart';
import 'package:metas_app/features/projects/presentation/cubits/projects.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/projects.states.dart';
import 'package:metas_app/features/projects/presentation/pages/create_project.page.dart';
import 'package:metas_app/features/projects/presentation/pages/project_detail.page.dart';

/// Página principal que muestra la lista de proyectos del usuario.
///
/// [isSponsor] true en portal sponsor (oculta sprints/dailies/reviews/retro en detalle).
class ProjectsListPage extends StatefulWidget {
  final bool isSponsor;

  const ProjectsListPage({super.key, this.isSponsor = false});

  @override
  State<ProjectsListPage> createState() => _ProjectsListPageState();
}

class _ProjectsListPageState extends State<ProjectsListPage> {
  /// Carga los proyectos al inicializar la página
  @override
  void initState() {
    super.initState();
    context.read<ProjectsCubit>().loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyectos'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthCubit>().signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocConsumer<ProjectsCubit, ProjectsState>(
        listener: (context, state) {
          if (state is ProjectsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ProjectsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProjectsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error al cargar proyectos',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProjectsCubit>().loadProjects();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is ProjectsLoaded) {
            if (state.projects.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes proyectos aún',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Presiona el botón + para crear uno',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProjectsCubit>().loadProjects();
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.projects.length,
                itemBuilder: (context, index) {
                  final project = state.projects[index];
                  final progress = state.progressMap[project.id];
                    return ProjectCard(
                    project: project,
                    progress: progress,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectDetailPage(
                            projectId: project.id,
                            isSponsor: widget.isSponsor,
                          ),
                        ),
                      ).then((_) {
                        context.read<ProjectsCubit>().loadProjects();
                      });
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'projects_list_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateProjectPage(),
            ),
          ).then((_) {
            context.read<ProjectsCubit>().loadProjects();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/domain/entities/project.dart';
import 'package:metas_app/features/projects/domain/entities/reward.dart';
import 'package:metas_app/features/projects/presentation/cubits/rewards.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/rewards.states.dart';
import 'package:metas_app/features/projects/presentation/pages/reward_detail.page.dart';

/// Página que muestra la lista de todas las rewards del usuario.
/// 
/// Muestra las rewards ordenadas por proyecto con el estado del proyecto.
/// Permite navegar al detalle de cada reward.
class RewardsListPage extends StatefulWidget {
  /// Constructor de la página de lista de rewards
  const RewardsListPage({super.key});

  @override
  State<RewardsListPage> createState() => _RewardsListPageState();
}

class _RewardsListPageState extends State<RewardsListPage> {
  @override
  void initState() {
    super.initState();
    // Cargar rewards al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RewardsCubit>().loadUserRewards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recompensas'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<RewardsCubit, RewardsState>(
        builder: (context, state) {
          if (state is RewardsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RewardsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error al cargar recompensas',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<RewardsCubit>().loadUserRewards();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is RewardsListLoaded) {
            if (state.rewards.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes recompensas aún',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Completa proyectos y milestones para obtener recompensas',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // Agrupar rewards por proyecto
            // Por ahora, mostraremos todas las rewards en una lista simple
            // TODO: Agrupar por proyecto cuando tengamos la información del proyecto
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<RewardsCubit>().loadUserRewards();
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.rewards.length,
                itemBuilder: (context, index) {
                  final reward = state.rewards[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade400,
                              Colors.orange.shade400,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        reward.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      subtitle: reward.description != null
                          ? Text(
                              reward.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RewardDetailPage(rewardId: reward.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Clase auxiliar para agrupar rewards con información del proyecto
class RewardWithProject {
  final Reward reward;
  final Project? project;
  final String? projectStatus;

  RewardWithProject({
    required this.reward,
    this.project,
    this.projectStatus,
  });
}

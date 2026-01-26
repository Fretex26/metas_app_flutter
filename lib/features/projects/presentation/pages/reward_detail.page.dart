import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:metas_app/features/projects/application/use_cases/get_project_by_reward_id.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_project_milestones.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_reward_by_id.use_case.dart';
import 'package:metas_app/features/projects/application/use_cases/get_user_projects.use_case.dart';
import 'package:metas_app/features/projects/presentation/cubits/rewards.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/rewards.states.dart';
import 'package:metas_app/features/projects/presentation/helpers/reward_project_status.helper.dart';

/// Página que muestra el detalle completo de una reward (recompensa).
/// 
/// Muestra:
/// - Nombre y descripción de la reward
/// - Instrucciones para reclamar la reward
/// - Botón para acceder al link de la reward (si está disponible)
/// - Mensaje sobre el estado y progreso del proyecto relacionado
class RewardDetailPage extends StatelessWidget {
  /// Identificador único de la reward a mostrar
  final String rewardId;

  /// Constructor de la página de detalle de reward
  const RewardDetailPage({
    super.key,
    required this.rewardId,
  });

  /// Abre el link de la reward en el navegador o app externa.
  /// 
  /// [url] - URL a abrir
  Future<void> _openRewardLink(String url) async {
    try {
      final uri = Uri.parse(url);
      
      // Intentar abrir la URL directamente, canLaunchUrl puede ser poco confiable
      bool launched = false;
      
      // Intentar primero con externalApplication
      try {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        // Si falla, intentar con platformDefault
        try {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
        } catch (e2) {
          // Si ambos fallan, intentar con inAppWebView como último recurso
          try {
            launched = await launchUrl(
              uri,
              mode: LaunchMode.inAppWebView,
            );
          } catch (e3) {
            throw 'No se pudo abrir la URL. Verifica que tengas un navegador instalado.';
          }
        }
      }
      
      if (!launched) {
        throw 'No se pudo abrir la URL. Verifica que tengas un navegador instalado.';
      }
    } on FormatException {
      throw 'La URL proporcionada no es válida: $url';
    } catch (e) {
      // Si el error ya es un String, lanzarlo tal cual
      if (e is String) {
        rethrow;
      }
      // Si es otro tipo de error, convertirlo a mensaje amigable
      throw 'Error al abrir la URL: ${e.toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RewardsCubit(
        getRewardByIdUseCase: context.read<GetRewardByIdUseCase>(),
        getUserRewardsUseCase: context.read(),
      )..loadReward(rewardId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de la Recompensa'),
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
                      'Error al cargar la recompensa',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<RewardsCubit>().loadReward(rewardId);
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is RewardLoaded) {
              final reward = state.reward;
              final hasLink = reward.claimLink != null && reward.claimLink!.isNotEmpty;

              return FutureBuilder<RewardStatusResult>(
                future: RewardProjectStatusHelper(
                  getProjectByRewardIdUseCase: context.read<GetProjectByRewardIdUseCase>(),
                  getUserProjectsUseCase: context.read<GetUserProjectsUseCase>(),
                  getProjectMilestonesUseCase: context.read<GetProjectMilestonesUseCase>(),
                ).getRewardStatus(reward.id),
                builder: (context, snapshot) {
                  // Determinar el estado del proyecto o milestone
                  final statusResult = snapshot.data;
                  final isProjectCompleted = statusResult?.isCompleted ?? false;
                  final isLoadingProject = snapshot.connectionState == ConnectionState.waiting;
                  
                  // Si está cargando, mostrar indicador de carga
                  if (isLoadingProject) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Si hay error, usar valores por defecto
                  final entityName = statusResult?.entityName ?? 'Proyecto';
                  final isMilestoneReward = statusResult?.milestone != null;
                  final parentProjectName = statusResult?.parentProject?.name;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icono de reward
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.emoji_events,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Nombre de la reward
                        Text(
                          reward.name,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Descripción
                        if (reward.description != null) ...[
                          Text(
                            reward.description!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        // Instrucciones para reclamar
                        if (reward.claimInstructions != null) ...[
                          Text(
                            'Instrucciones para reclamar:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              reward.claimInstructions!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        // Mensaje sobre el estado del proyecto
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isProjectCompleted
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isProjectCompleted ? Colors.green : Colors.orange,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isProjectCompleted ? Icons.check_circle : Icons.info,
                                color: isProjectCompleted ? Colors.green : Colors.orange,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isProjectCompleted
                                      ? isMilestoneReward
                                          ? '¡Felicidades! Has completado el milestone "$entityName" y alcanzado esta recompensa. ¡Es hora de reclamarla!'
                                          : '¡Felicidades! Has completado el proyecto "$entityName" y alcanzado esta recompensa. ¡Es hora de reclamarla!'
                                      : isMilestoneReward
                                          ? parentProjectName != null
                                              ? 'Estás progresando hacia esta recompensa. Continúa trabajando en el milestone "$entityName" del proyecto "$parentProjectName" para alcanzarla.'
                                              : 'Estás progresando hacia esta recompensa. Continúa trabajando en el milestone "$entityName" para alcanzarla.'
                                          : 'Estás progresando hacia esta recompensa. Continúa trabajando en tu proyecto "$entityName" para alcanzarla.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Botón para acceder al link
                        if (hasLink) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isProjectCompleted
                                  ? () async {
                                      try {
                                        await _openRewardLink(reward.claimLink!);
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Error al abrir el link: $e'),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: isProjectCompleted ? 4 : 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.open_in_new,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Reclamar Recompensa',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (hasLink && !isProjectCompleted) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Completa el proyecto para habilitar este botón',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.7),
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ],
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

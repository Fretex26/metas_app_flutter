import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/cubits/auth.cubit.dart';
import 'package:metas_app/features/sponsored_goals/application/use_cases/enroll_in_sponsored_goal.use_case.dart';
import 'package:metas_app/features/sponsored_goals/presentation/components/sponsored_goal_card.dart';
import 'package:metas_app/features/sponsored_goals/presentation/cubits/sponsor_enrollments.cubit.dart';
import 'package:metas_app/features/sponsored_goals/presentation/cubits/sponsor_enrollments.states.dart';
import 'package:metas_app/features/sponsored_goals/presentation/cubits/sponsored_goals.cubit.dart';
import 'package:metas_app/features/sponsored_goals/presentation/cubits/sponsored_goals.states.dart';
import 'package:metas_app/features/sponsored_goals/presentation/pages/sponsored_goal_detail.page.dart';

/// Página que muestra la lista de Sponsored Goals disponibles para usuarios normales.
/// 
/// Permite a los usuarios:
/// - Ver todos los objetivos patrocinados disponibles
/// - Filtrar por categorías (futuro)
/// - Ver detalles de un objetivo
/// - Inscribirse a un objetivo
/// 
/// Basado en el diseño de las imágenes proporcionadas, con estilo moderno y limpio.
class AvailableSponsoredGoalsPage extends StatefulWidget {
  const AvailableSponsoredGoalsPage({super.key});

  @override
  State<AvailableSponsoredGoalsPage> createState() =>
      _AvailableSponsoredGoalsPageState();
}

class _AvailableSponsoredGoalsPageState
    extends State<AvailableSponsoredGoalsPage> {
  @override
  void initState() {
    super.initState();
    // Cargar los sponsored goals disponibles al inicializar
    context.read<SponsoredGoalsCubit>().loadSponsoredGoals();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: context.read<SponsoredGoalsCubit>(),
        ),
        BlocProvider(
          create: (context) => SponsorEnrollmentsCubit(
            enrollInSponsoredGoalUseCase:
                context.read<EnrollInSponsoredGoalUseCase>(),
          ),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Objetivos Disponibles'),
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
        body: BlocConsumer<SponsoredGoalsCubit, SponsoredGoalsState>(
          listener: (context, state) {
            if (state is SponsoredGoalsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is SponsoredGoalsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SponsoredGoalsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar objetivos',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SponsoredGoalsCubit>().loadSponsoredGoals();
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is SponsoredGoalsLoaded) {
              if (state.goals.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay objetivos disponibles',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vuelve más tarde para ver nuevos objetivos patrocinados',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<SponsoredGoalsCubit>().loadSponsoredGoals(
                        categoryIds: state.selectedCategoryIds,
                      );
                },
                child: ListView.builder(
                  itemCount: state.goals.length,
                  itemBuilder: (context, index) {
                    final goal = state.goals[index];
                    return BlocListener<SponsorEnrollmentsCubit,
                        SponsorEnrollmentsState>(
                      listener: (context, enrollmentState) {
                        if (enrollmentState is SponsorEnrollmentsEnrolled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '¡Te has inscrito exitosamente! El proyecto aparecerá en tus proyectos.',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Recargar la lista
                          context.read<SponsoredGoalsCubit>().loadSponsoredGoals(
                                categoryIds: state.selectedCategoryIds,
                              );
                        }
                        if (enrollmentState is SponsorEnrollmentsError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(enrollmentState.message),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: SponsoredGoalCard(
                        goal: goal,
                        onViewDetails: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SponsoredGoalDetailPage(
                                goal: goal,
                              ),
                            ),
                          );
                        },
                        onEnroll: () {
                          _showEnrollConfirmationDialog(context, goal.id);
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
      ),
    );
  }

  void _showEnrollConfirmationDialog(BuildContext context, String goalId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar inscripción'),
        content: const Text(
          '¿Estás seguro de que quieres inscribirte a este objetivo? '
          'El proyecto se duplicará automáticamente en tus proyectos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SponsorEnrollmentsCubit>().enrollInSponsoredGoal(
                    goalId,
                  );
            },
            child: const Text('Inscribirse'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/auth/presentation/cubits/auth.cubit.dart';
import 'package:metas_app/features/sponsored_goals/application/use_cases/get_my_sponsored_goals.use_case.dart';
import 'package:metas_app/features/sponsored_goals/domain/entities/sponsored_goal.dart';
import 'package:metas_app/features/sponsored_goals/presentation/components/sponsored_goal_card.dart';
import 'package:metas_app/features/sponsored_goals/presentation/cubits/sponsor_goals_list.cubit.dart';
import 'package:metas_app/features/sponsored_goals/presentation/cubits/sponsor_goals_list.states.dart';
import 'package:metas_app/features/sponsored_goals/presentation/pages/create_sponsored_goal.page.dart';
import 'package:metas_app/features/sponsored_goals/presentation/pages/sponsor_goal_detail_sponsor.page.dart';

/// Lista de objetivos patrocinados del sponsor (ver, editar, eliminar, crear).
class SponsorGoalsListPage extends StatefulWidget {
  const SponsorGoalsListPage({super.key});

  @override
  State<SponsorGoalsListPage> createState() => _SponsorGoalsListPageState();
}

class _SponsorGoalsListPageState extends State<SponsorGoalsListPage> {
  Future<void> _openCreate() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateSponsoredGoalPage()),
    );
    if (!mounted) return;
    context.read<SponsorGoalsListCubit>().loadGoals();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SponsorGoalsListCubit(
        getMySponsoredGoalsUseCase: context.read<GetMySponsoredGoalsUseCase>(),
      )..loadGoals(),
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Mis Objetivos'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => context.read<AuthCubit>().signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocConsumer<SponsorGoalsListCubit, SponsorGoalsListState>(
        listener: (context, state) {
          if (state is SponsorGoalsListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is SponsorGoalsListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SponsorGoalsListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar objetivos',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<SponsorGoalsListCubit>().loadGoals(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is SponsorGoalsListLoaded) {
            if (state.goals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_business_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes objetivos patrocinados',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pulsa + para crear uno',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<SponsorGoalsListCubit>().loadGoals(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.goals.length,
                itemBuilder: (context, index) {
                  final goal = state.goals[index];
                  return SponsoredGoalCard(
                    goal: goal,
                    onViewDetails: () => _openDetail(context, goal),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'sponsor_goals_list_fab',
        onPressed: _openCreate,
        child: const Icon(Icons.add),
      ),
    ),
    );
  }

  Future<void> _openDetail(BuildContext context, SponsoredGoal goal) async {
    final cubit = context.read<SponsorGoalsListCubit>();
    final refreshed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => SponsorGoalDetailSponsorPage(goal: goal),
      ),
    );
    if (!mounted) return;
    if (refreshed == true) cubit.loadGoals();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/domain/entities/daily_entry.dart';
import 'package:metas_app/features/projects/domain/entities/difficulty.dart';
import 'package:metas_app/features/projects/domain/entities/energy_change.dart';
import 'package:metas_app/features/projects/presentation/cubits/get_user_daily_entries.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/get_user_daily_entries.states.dart';
import 'package:metas_app/features/projects/presentation/pages/create_daily_entry.page.dart';
import 'package:metas_app/features/projects/presentation/cubits/create_daily_entry.cubit.dart';

/// Página que muestra la lista de todas las entradas diarias del usuario.
/// 
/// Muestra las entradas diarias ordenadas por fecha de creación descendente
/// (más recientes primero). Permite crear nuevas entradas diarias.
class DailyEntriesListPage extends StatefulWidget {
  /// Constructor de la página de lista de entradas diarias
  const DailyEntriesListPage({super.key});

  @override
  State<DailyEntriesListPage> createState() => _DailyEntriesListPageState();
}

class _DailyEntriesListPageState extends State<DailyEntriesListPage> {
  @override
  void initState() {
    super.initState();
    // Cargar entradas diarias al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetUserDailyEntriesCubit>().loadDailyEntries();
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.low:
        return Colors.green.shade100;
      case Difficulty.medium:
        return Colors.orange.shade100;
      case Difficulty.high:
        return Colors.red.shade100;
    }
  }

  Color _getEnergyChangeColor(EnergyChange energyChange) {
    switch (energyChange) {
      case EnergyChange.increased:
        return Colors.blue.shade100;
      case EnergyChange.stable:
        return Colors.grey.shade100;
      case EnergyChange.decreased:
        return Colors.purple.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entradas Diarias'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<GetUserDailyEntriesCubit, GetUserDailyEntriesState>(
        builder: (context, state) {
          if (state is GetUserDailyEntriesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GetUserDailyEntriesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error al cargar entradas diarias',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<GetUserDailyEntriesCubit>().loadDailyEntries();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is GetUserDailyEntriesLoaded) {
            if (state.dailyEntries.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay entradas diarias aún',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crea tu primera entrada diaria para comenzar a registrar tu progreso',
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

            return RefreshIndicator(
              onRefresh: () async {
                context.read<GetUserDailyEntriesCubit>().refresh();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.dailyEntries.length,
                itemBuilder: (context, index) {
                  final entry = state.dailyEntries[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(entry.createdAt),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Row(
                                children: [
                                  Chip(
                                    label: Text(
                                      entry.difficulty.displayName,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: _getDifficultyColor(entry.difficulty),
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text(
                                      entry.energyChange.displayName,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: _getEnergyChangeColor(entry.energyChange),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ayer:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.notesYesterday,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Hoy:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.notesToday,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      // No se muestra FAB porque las daily entries requieren un sprintId
      // Solo se pueden crear desde la página de detalle de sprint
    );
  }
}

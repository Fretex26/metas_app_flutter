import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/presentation/components/pending_sprints_dialog.dart';
import 'package:metas_app/features/projects/presentation/cubits/pending_sprints.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/pending_sprints.states.dart';
import 'package:metas_app/features/projects/presentation/pages/projects_list.page.dart';
import 'package:metas_app/features/projects/presentation/pages/rewards_list.page.dart';
import 'package:metas_app/features/sponsored_goals/presentation/pages/available_sponsored_goals.page.dart';
import 'package:metas_app/features/sponsored_goals/presentation/pages/sponsor_goals_list.page.dart';
import 'package:metas_app/features/sponsored_goals/presentation/pages/verify_milestones.page.dart';

/// Página principal con navegación inferior que permite cambiar entre
/// la lista de proyectos y la lista de rewards.
///
/// [isSponsor] true para portal sponsor (sin sprints pendientes, sin dailies/reviews/retro).
class MainNavigationPage extends StatefulWidget {
  final bool isSponsor;

  const MainNavigationPage({super.key, this.isSponsor = false});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  bool _hasCheckedPendingSprints = false;

  List<Widget> _buildPages() {
    if (widget.isSponsor) {
      // Para sponsors: Proyectos, Recompensas, Mis Objetivos (lista + crear/editar/eliminar), Verificar
      return [
        ProjectsListPage(isSponsor: widget.isSponsor),
        const RewardsListPage(),
        const SponsorGoalsListPage(),
        const VerifyMilestonesPage(),
      ];
    } else {
      // Para usuarios normales: Proyectos, Recompensas, Objetivos Disponibles
      return [
        ProjectsListPage(isSponsor: widget.isSponsor),
        const RewardsListPage(),
        const AvailableSponsoredGoalsPage(),
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    // Verificar sprints pendientes después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingSprints();
    });
  }

  void _checkPendingSprints() {
    if (widget.isSponsor) return;
    if (!_hasCheckedPendingSprints && mounted) {
      _hasCheckedPendingSprints = true;
      context.read<PendingSprintsCubit>().loadPendingSprints();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PendingSprintsCubit, PendingSprintsState>(
      listener: (context, state) {
        if (state is PendingSprintsLoaded && state.pendingSprints.isNotEmpty) {
          // Mostrar el diálogo solo si hay sprints pendientes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (dialogContext) => BlocProvider.value(
                  value: context.read<PendingSprintsCubit>(),
                  child: PendingSprintsDialog(
                    pendingSprints: state.pendingSprints,
                  ),
                ),
              );
            }
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _buildPages(),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2C2C2C)
                : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF64B5F6)
                : const Color(0xFF1976D2),
            unselectedItemColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF9E9E9E)
                : const Color(0xFF616161),
            selectedLabelStyle: const TextStyle(
              color: Color(0xFF1976D2),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF9E9E9E)
                  : const Color(0xFF616161),
              fontSize: 12,
            ),
            selectedIconTheme: IconThemeData(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF64B5F6)
                  : const Color(0xFF1976D2),
            ),
            unselectedIconTheme: IconThemeData(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF9E9E9E)
                  : const Color(0xFF616161),
            ),
            type: BottomNavigationBarType.fixed,
          items: widget.isSponsor
              ? const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.folder),
                    label: 'Proyectos',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.emoji_events),
                    label: 'Recompensas',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_business),
                    label: 'Objetivos',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.verified),
                    label: 'Verificar',
                  ),
                ]
              : const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.folder),
                    label: 'Proyectos',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.emoji_events),
                    label: 'Recompensas',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.flag),
                    label: 'Objetivos',
                  ),
                ],
          ),
        ),
      ),
    );
  }
}

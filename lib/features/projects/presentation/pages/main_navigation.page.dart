import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metas_app/features/projects/presentation/components/pending_sprints_dialog.dart';
import 'package:metas_app/features/projects/presentation/cubits/pending_sprints.cubit.dart';
import 'package:metas_app/features/projects/presentation/cubits/pending_sprints.states.dart';
import 'package:metas_app/features/projects/presentation/pages/projects_list.page.dart';
import 'package:metas_app/features/projects/presentation/pages/rewards_list.page.dart';

/// Página principal con navegación inferior que permite cambiar entre
/// la lista de proyectos y la lista de rewards.
/// 
/// Incluye un BottomNavigationBar con dos opciones:
/// - Proyectos: Muestra la lista de proyectos del usuario
/// - Recompensas: Muestra la lista de rewards del usuario
class MainNavigationPage extends StatefulWidget {
  /// Constructor de la página de navegación principal
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  bool _hasCheckedPendingSprints = false;

  final List<Widget> _pages = [
    const ProjectsListPage(),
    const RewardsListPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Verificar sprints pendientes después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingSprints();
    });
  }

  void _checkPendingSprints() {
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
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              label: 'Proyectos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events),
              label: 'Recompensas',
            ),
          ],
        ),
      ),
    );
  }
}

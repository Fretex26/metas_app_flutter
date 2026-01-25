import 'package:flutter/material.dart';
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

  final List<Widget> _pages = [
    const ProjectsListPage(),
    const RewardsListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}

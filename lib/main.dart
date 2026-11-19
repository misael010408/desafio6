import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'presentation/screens/config_screen.dart';
import 'presentation/screens/tareas_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('preferencias');

  runApp(const Desafio6App());
}

class Desafio6App extends StatelessWidget {
  const Desafio6App({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('preferencias');

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box prefBox, _) {
        final bool modoOscuro = prefBox.get('modoOscuro', defaultValue: false);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Desafío 6 - SQLite + Hive',
          theme: ThemeData(
            colorSchemeSeed: Colors.purple,
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.purple,
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          themeMode: modoOscuro ? ThemeMode.dark : ThemeMode.light,
          home: const InicioTabsScreen(),
        );
      },
    );
  }
}

class InicioTabsScreen extends StatefulWidget {
  const InicioTabsScreen({super.key});

  @override
  State<InicioTabsScreen> createState() => _InicioTabsScreenState();
}

class _InicioTabsScreenState extends State<InicioTabsScreen> {
  int _indiceActual = 0;

  final List<Widget> _pantallas = const [
    TareasScreen(),
    ConfigScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pantallas[_indiceActual],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceActual,
        onDestinationSelected: (int index) {
          setState(() => _indiceActual = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_box_outlined),
            selectedIcon: Icon(Icons.check_box),
            label: 'Tareas',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }
}
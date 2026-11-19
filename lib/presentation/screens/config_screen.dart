import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('preferencias');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración (Hive)'),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box prefBox, _) {
          final bool modoOscuro = prefBox.get('modoOscuro', defaultValue: false);
          final bool notificaciones =
          prefBox.get('notificaciones', defaultValue: true);

          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Modo oscuro'),
                subtitle: const Text('Cambia el tema de toda la aplicación'),
                value: modoOscuro,
                onChanged: (bool valor) {
                  prefBox.put('modoOscuro', valor);
                },
              ),
              SwitchListTile(
                title: const Text('Notificaciones'),
                subtitle: const Text('Activa o desactiva avisos locales'),
                value: notificaciones,
                onChanged: (bool valor) {
                  prefBox.put('notificaciones', valor);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
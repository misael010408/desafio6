import 'package:flutter/material.dart';
import '../../data/local/local_database.dart';
import '../../domain/entities/tarea.dart';

enum FiltroTareas { todas, pendientes, completadas }

class TareasScreen extends StatefulWidget {
  const TareasScreen({super.key});

  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  final LocalDatabase _db = LocalDatabase();
  final TextEditingController _tareaCtrl = TextEditingController();

  List<Tarea> _tareas = [];
  FiltroTareas _filtro = FiltroTareas.todas;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarTareas();
  }

  @override
  void dispose() {
    _tareaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarTareas() async {
    setState(() => _cargando = true);
    final lista = await _db.obtenerTodas();
    if (!mounted) return;
    setState(() {
      _tareas = lista;
      _cargando = false;
    });
  }

  Future<void> _agregarTarea() async {
    final titulo = _tareaCtrl.text.trim();
    if (titulo.isEmpty) return;

    final hoy = DateTime.now().toIso8601String().split('T').first;
    final nueva = Tarea(
      titulo: titulo,
      fecha: hoy,
      completada: false,
    );

    await _db.insertar(nueva);
    _tareaCtrl.clear();
    await _cargarTareas();
  }

  Future<void> _toggleCompletada(Tarea tarea, bool? valor) async {
    final actualizada = tarea.copyWith(completada: valor ?? false);
    await _db.actualizar(actualizada);
    await _cargarTareas();
  }

  Future<void> _eliminarTarea(Tarea tarea) async {
    if (tarea.id == null) return;
    await _db.eliminar(tarea.id!);
    await _cargarTareas();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Eliminaste "${tarea.titulo}"')),
    );
  }

  List<Tarea> get _tareasFiltradas {
    switch (_filtro) {
      case FiltroTareas.pendientes:
        return _tareas.where((t) => !t.completada).toList();
      case FiltroTareas.completadas:
        return _tareas.where((t) => t.completada).toList();
      case FiltroTareas.todas:
        return _tareas;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibles = _tareasFiltradas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas (SQLite)'),
        actions: [
          PopupMenuButton<FiltroTareas>(
            initialValue: _filtro,
            icon: const Icon(Icons.filter_list),
            onSelected: (FiltroTareas seleccionado) {
              setState(() => _filtro = seleccionado);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: FiltroTareas.todas,
                child: Text('Todas'),
              ),
              PopupMenuItem(
                value: FiltroTareas.pendientes,
                child: Text('Pendientes'),
              ),
              PopupMenuItem(
                value: FiltroTareas.completadas,
                child: Text('Completadas'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tareaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nueva tarea',
                      hintText: 'Ej: Estudiar SQLite',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _agregarTarea(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _agregarTarea,
                  child: const Text('Agregar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : visibles.isEmpty
                ? const Center(child: Text('No hay tareas para mostrar'))
                : ListView.builder(
              itemCount: visibles.length,
              itemBuilder: (context, index) {
                final tarea = visibles[index];
                return Dismissible(
                  key: ValueKey(tarea.id ?? '${tarea.titulo}_$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _eliminarTarea(tarea),
                  child: ListTile(
                    leading: Checkbox(
                      value: tarea.completada,
                      onChanged: (val) => _toggleCompletada(tarea, val),
                    ),
                    title: Text(
                      tarea.titulo,
                      style: TextStyle(
                        decoration: tarea.completada
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text('Fecha: ${tarea.fecha}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
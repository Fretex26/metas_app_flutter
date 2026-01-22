import 'package:flutter/material.dart';
import 'package:metas_app/features/auth/presentation/components/my_textfield.dart';

/// Modelo interno para representar un recurso con nombre y descripción.
/// 
/// Se usa dentro de [ResourceFormField] para manejar los recursos
/// de forma dinámica antes de convertirlos a JSON.
class ResourceItem {
  /// Nombre del recurso
  final String name;

  /// Descripción del recurso
  final String description;

  /// Constructor del item de recurso
  ResourceItem({required this.name, required this.description});

  /// Convierte el item a formato JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}

/// Widget de formulario dinámico para agregar recursos (nombre y descripción).
/// 
/// Permite agregar múltiples pares nombre-descripción dinámicamente.
/// Los recursos se convierten a un objeto JSON donde cada nombre es una clave
/// y su descripción es el valor.
/// 
/// Se usa para los campos `resourcesAvailable` y `resourcesNeeded` en proyectos y tasks.
class ResourceFormField extends StatefulWidget {
  /// Texto de la etiqueta del campo
  final String labelText;

  /// Recursos iniciales para pre-llenar el formulario
  final List<ResourceItem>? initialResources;

  /// Callback que se ejecuta cuando cambian los recursos
  /// Recibe un Map<String, dynamic>? donde cada clave es un nombre de recurso
  /// y su valor es la descripción. Retorna null si no hay recursos.
  final ValueChanged<Map<String, dynamic>?> onChanged;

  /// Constructor del formulario de recursos
  const ResourceFormField({
    super.key,
    required this.labelText,
    this.initialResources,
    required this.onChanged,
  });

  @override
  State<ResourceFormField> createState() => _ResourceFormFieldState();
}

class _ResourceFormFieldState extends State<ResourceFormField> {
  late List<ResourceItem> _resources;
  final Map<int, TextEditingController> _nameControllers = {};
  final Map<int, TextEditingController> _descControllers = {};

  @override
  void initState() {
    super.initState();
    _resources = widget.initialResources ?? [];
    _initializeControllers();
    // Schedule _notifyChange to run after the current frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyChange();
    });
  }

  void _initializeControllers() {
    for (var i = 0; i < _resources.length; i++) {
      _nameControllers[i] = TextEditingController(text: _resources[i].name);
      _descControllers[i] = TextEditingController(text: _resources[i].description);
      _nameControllers[i]!.addListener(() => _updateResourceFromControllers(i));
      _descControllers[i]!.addListener(() => _updateResourceFromControllers(i));
    }
  }

  void _updateResourceFromControllers(int index) {
    if (index < _resources.length) {
      _updateResource(
        index,
        _nameControllers[index]?.text ?? '',
        _descControllers[index]?.text ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _nameControllers.values) {
      controller.dispose();
    }
    for (var controller in _descControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _notifyChange() {
    // Schedule onChanged callback to run after the current frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_resources.isEmpty) {
        widget.onChanged(null);
      } else {
        final Map<String, dynamic> json = {};
        for (var resource in _resources) {
          if (resource.name.isNotEmpty) {
            json[resource.name] = resource.description;
          }
        }
        widget.onChanged(json.isEmpty ? null : json);
      }
    });
  }

  void _addResource() {
    setState(() {
      final newIndex = _resources.length;
      _resources.add(ResourceItem(name: '', description: ''));
      _nameControllers[newIndex] = TextEditingController();
      _descControllers[newIndex] = TextEditingController();
      _nameControllers[newIndex]!.addListener(() => _updateResourceFromControllers(newIndex));
      _descControllers[newIndex]!.addListener(() => _updateResourceFromControllers(newIndex));
    });
    _notifyChange();
  }

  void _removeResource(int index) {
    setState(() {
      _nameControllers[index]?.dispose();
      _descControllers[index]?.dispose();
      _nameControllers.remove(index);
      _descControllers.remove(index);
      _resources.removeAt(index);
      
      // Reindexar controllers
      final newNameControllers = <int, TextEditingController>{};
      final newDescControllers = <int, TextEditingController>{};
      for (var i = 0; i < _resources.length; i++) {
        if (i < index) {
          newNameControllers[i] = _nameControllers[i]!;
          newDescControllers[i] = _descControllers[i]!;
        } else if (i > index) {
          newNameControllers[i - 1] = _nameControllers[i]!;
          newDescControllers[i - 1] = _descControllers[i]!;
        }
      }
      _nameControllers.clear();
      _descControllers.clear();
      _nameControllers.addAll(newNameControllers);
      _descControllers.addAll(newDescControllers);
    });
    _notifyChange();
  }

  void _updateResource(int index, String name, String description) {
    setState(() {
      _resources[index] = ResourceItem(name: name, description: description);
    });
    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.labelText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            IconButton(
              onPressed: _addResource,
              icon: Icon(
                Icons.add_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(_resources.length, (index) {
          if (!_nameControllers.containsKey(index)) {
            _nameControllers[index] = TextEditingController(text: _resources[index].name);
            _descControllers[index] = TextEditingController(text: _resources[index].description);
            _nameControllers[index]!.addListener(() => _updateResourceFromControllers(index));
            _descControllers[index]!.addListener(() => _updateResourceFromControllers(index));
          }
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: MyTextField(
                    controller: _nameControllers[index]!,
                    hintText: 'Nombre',
                    obscureText: false,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: MyTextField(
                    controller: _descControllers[index]!,
                    hintText: 'Descripción',
                    obscureText: false,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removeResource(index),
                  icon: Icon(
                    Icons.remove_circle,
                    color: Colors.red.shade300,
                  ),
                ),
              ],
            ),
          );
        }),
        if (_resources.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No hay recursos. Presiona + para agregar',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

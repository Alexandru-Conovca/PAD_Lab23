import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/celestial_object.dart';
import '../models/celestial_objects_model.dart';
import '../models/domain_models.dart';
import '../models/favorites_model.dart';
import '../widgets/error_view.dart';
import '../widgets/stat_badge.dart';

class ObjectDetailScreen extends StatelessWidget {
  const ObjectDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CelestialObjectsModel>();
    final object = model.byId(id);

    if (model.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (model.errorMessage case final message?) {
      return Scaffold(
        appBar: AppBar(title: const Text('Object')),
        body: ErrorView(
          message: message,
          onRetry: () => context.read<CelestialObjectsModel>().load(),
        ),
      );
    }

    if (object == null) {
      return const Scaffold(body: Center(child: Text('Запись не существует')));
    }

    return _ObjectDetails(object: object);
  }
}

class _ObjectDetails extends StatelessWidget {
  const _ObjectDetails({required this.object});

  final CelestialObject object;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesModel>();
    final isFavorite = favorites.contains(object);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(object.name),
        actions: [
          IconButton(
            onPressed: () => _editObject(context, object),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Изменить',
          ),
          IconButton(
            onPressed: () => _deleteObject(context, object),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Удалить',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 190,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.brightness_3, size: 88, color: scheme.primary),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  object.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              StatBadge(
                label: object.isVisibleNow ? 'Visible now' : 'Not visible',
                color: object.isVisibleNow ? scheme.tertiary : scheme.outline,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            object.description,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Parameter(
                label: 'Magnitude',
                value: object.magnitude.toStringAsFixed(1),
              ),
              _Parameter(
                label: 'Distance',
                value: object.type == CelestialType.galaxy
                    ? '2.5 Mly'
                    : 'Variable',
              ),
              _Parameter(label: 'Coordinates', value: object.coordinates),
              _Parameter(label: 'Constellation', value: object.constellation),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить в квест'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    context.read<FavoritesModel>().toggle(object);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFavorite
                              ? '${object.name} удалён из избранного'
                              : '${object.name} добавлен в избранное',
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  ),
                  label: Text(
                    isFavorite ? 'Удалить из избранного' : 'В избранное',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editObject(BuildContext context, CelestialObject object) async {
    final controller = TextEditingController(text: object.name);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Изменить объект'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Название'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (name == null || name.isEmpty || !context.mounted) {
      return;
    }

    final error = await context.read<CelestialObjectsModel>().update(
      object.copyWith(name: name),
    );
    if (!context.mounted) {
      return;
    }
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    context.read<FavoritesModel>().update(object.copyWith(name: name));
  }

  Future<void> _deleteObject(
    BuildContext context,
    CelestialObject object,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить объект?'),
        content: Text('Удалить ${object.name} из каталога?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    final error = await context.read<CelestialObjectsModel>().remove(object.id);
    if (!context.mounted) {
      return;
    }
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    context.read<FavoritesModel>().remove(object);
    context.pop();
  }
}

class _Parameter extends StatelessWidget {
  const _Parameter({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: (MediaQuery.sizeOf(context).width - 42) / 2,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 5),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    ),
  );
}

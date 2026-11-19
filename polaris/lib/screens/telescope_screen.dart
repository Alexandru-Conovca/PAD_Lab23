import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/domain_models.dart';
import '../models/telescope_model.dart';
import '../widgets/error_view.dart';
import '../widgets/stat_badge.dart';

class TelescopeScreen extends StatelessWidget {
  const TelescopeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final telescopes = context.watch<TelescopeModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment'),
        actions: [
          IconButton(
            onPressed: telescopes.load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh equipment',
          ),
          IconButton(
            onPressed: () => _editTelescope(context),
            icon: const Icon(Icons.add),
            tooltip: 'Add telescope',
          ),
        ],
      ),
      body: switch ((telescopes.isLoading, telescopes.errorMessage)) {
        (true, _) => const Center(child: CircularProgressIndicator()),
        (false, final String? errorMessage) when errorMessage != null => Center(
          child: ErrorView(message: errorMessage, onRetry: telescopes.load),
        ),
        _ when telescopes.items.isEmpty => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No telescopes yet.'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _editTelescope(context),
                icon: const Icon(Icons.add),
                label: const Text('Add telescope'),
              ),
            ],
          ),
        ),
        _ => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: telescopes.items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, index) {
            final telescope = telescopes.items[index];
            return _TelescopeCard(
              telescope: telescope,
              onEdit: () => _editTelescope(context, telescope),
            );
          },
        ),
      },
    );
  }

  Future<void> _editTelescope(BuildContext context, [Telescope? telescope]) async {
    final edited = await showDialog<Telescope>(
      context: context,
      builder: (_) => _TelescopeEditorDialog(telescope: telescope),
    );
    if (edited == null || !context.mounted) return;

    final model = context.read<TelescopeModel>();
    final error = telescope == null
        ? await model.add(edited)
        : await model.update(edited);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}

class _TelescopeCard extends StatelessWidget {
  const _TelescopeCard({required this.telescope, required this.onEdit});

  final Telescope telescope;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TelescopeModel>();
    final scheme = Theme.of(context).colorScheme;
    final ratio = telescope.aperture == 0
        ? 0.0
        : telescope.focalLength / telescope.aperture;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    telescope.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (telescope.isActive)
                  StatBadge(label: 'Active', color: scheme.tertiary),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${telescope.aperture} mm • ${telescope.focalLength} mm • f/${ratio.toStringAsFixed(1)} • ${telescope.mountType}',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!telescope.isActive)
                  TextButton.icon(
                    onPressed: () async {
                      final error = await model.setActive(telescope.id);
                      if (!context.mounted || error == null) return;
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(error)));
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Set active'),
                  ),
                const Spacer(),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () => _delete(context),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete telescope?'),
        content: Text('Delete ${telescope.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final error = await context.read<TelescopeModel>().delete(telescope.id);
    if (!context.mounted || error == null) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error)));
  }
}

class _TelescopeEditorDialog extends StatefulWidget {
  const _TelescopeEditorDialog({this.telescope});

  final Telescope? telescope;

  @override
  State<_TelescopeEditorDialog> createState() => _TelescopeEditorDialogState();
}

class _TelescopeEditorDialogState extends State<_TelescopeEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _apertureController;
  late final TextEditingController _focalLengthController;
  late final TextEditingController _mountController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final telescope = widget.telescope;
    _nameController = TextEditingController(text: telescope?.name ?? '');
    _apertureController = TextEditingController(
      text: telescope == null ? '' : '${telescope.aperture}',
    );
    _focalLengthController = TextEditingController(
      text: telescope == null ? '' : '${telescope.focalLength}',
    );
    _mountController = TextEditingController(text: telescope?.mountType ?? '');
    _isActive = telescope?.isActive ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apertureController.dispose();
    _focalLengthController.dispose();
    _mountController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.telescope;
    Navigator.pop(
      context,
      Telescope(
        id: existing?.id ?? '',
        name: _nameController.text.trim(),
        aperture: int.parse(_apertureController.text.trim()),
        focalLength: int.parse(_focalLengthController.text.trim()),
        mountType: _mountController.text.trim(),
        isActive: _isActive,
        notes: existing?.notes,
        focalRatio: existing?.focalRatio ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.telescope == null ? 'Add telescope' : 'Edit telescope'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    (value == null || value.trim().length < 2)
                    ? 'Enter telescope name'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _apertureController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Aperture (mm)'),
                validator: (value) {
                  final aperture = int.tryParse(value ?? '');
                  if (aperture == null || aperture <= 0) {
                    return 'Enter a positive aperture';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _focalLengthController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Focal length (mm)'),
                validator: (value) {
                  final focalLength = int.tryParse(value ?? '');
                  if (focalLength == null || focalLength <= 0) {
                    return 'Enter a positive focal length';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mountController,
                decoration: const InputDecoration(labelText: 'Mount type'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                    ? 'Enter mount type'
                    : null,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active telescope'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

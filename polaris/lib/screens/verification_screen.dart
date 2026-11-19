import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/celestial_objects_model.dart';
import '../models/observations_model.dart';
import '../models/quests_model.dart';
import '../models/telescope_model.dart';
import '../models/weather_model.dart';
import '../widgets/error_view.dart';
import '../widgets/stat_badge.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _latitudeController = TextEditingController(text: '47.0101');
  final _longitudeController = TextEditingController(text: '28.8638');
  final _notesController = TextEditingController();

  String? _objectId;
  String? _telescopeId;
  String? _questId = '';
  bool _isSubmitting = false;
  String? _statusMessage;

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final objectId = _objectId;
    if (objectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a celestial object')),
      );
      return;
    }

    final catalog = context.read<CelestialObjectsModel>();
    final object = catalog.byId(objectId);
    if (object == null) return;

    setState(() {
      _isSubmitting = true;
      _statusMessage = 'Submitting observation…';
    });

    final observations = context.read<ObservationsModel>();
    final error = await observations.create(
      celestialObjectId: object.id,
      observedAt: DateTime.now(),
      latitude: double.parse(_latitudeController.text.trim()),
      longitude: double.parse(_longitudeController.text.trim()),
      telescopeId: _telescopeId == null ? null : int.tryParse(_telescopeId!),
      questId: _questId == null || _questId!.isEmpty ? null : _questId,
      locationName: 'Polaris observation point',
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (!mounted) return;
    if (error != null) {
      setState(() {
        _isSubmitting = false;
        _statusMessage = error;
      });
      return;
    }

    final created = observations.items.isEmpty ? null : observations.items.first;
    if (created == null) {
      setState(() {
        _isSubmitting = false;
        _statusMessage = 'Observation submitted.';
      });
      return;
    }

    setState(() => _statusMessage = 'Observation ${created.id} is PENDING. Waiting for verification…');
    await _pollVerification(created.id);
  }

  Future<void> _pollVerification(String id) async {
    final observations = context.read<ObservationsModel>();
    for (var attempt = 0; attempt < 15; attempt++) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      final observation = await observations.refresh(id);
      if (!mounted) return;
      if (observation == null) continue;
      setState(() {
        _statusMessage = observation.status == 'PENDING'
            ? 'Observation ${observation.id} is still PENDING…'
            : 'Observation ${observation.id}: ${observation.status}'
                  '${observation.verificationReason == null ? '' : '\n${observation.verificationReason}'}';
        _isSubmitting = observation.status == 'PENDING';
      });
      if (observation.status != 'PENDING') return;
    }
    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _statusMessage = 'Verification is still processing. Check history later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CelestialObjectsModel>();
    final telescopes = context.watch<TelescopeModel>();
    final quests = context.watch<QuestsModel>();
    final weather = context.watch<WeatherModel>();
    final conditions = weather.conditions;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify observation')),
      body: catalog.isLoading || telescopes.isLoading
          ? const Center(child: CircularProgressIndicator())
          : catalog.errorMessage != null
          ? ErrorView(
              message: catalog.errorMessage!,
              onRetry: catalog.load,
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Record an observation',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Polaris will send the coordinates to Observation Service, then Verification Service will check the object altitude and weather.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (conditions != null)
                    Card(
                      child: ListTile(
                        leading: Icon(
                          conditions.isSuitable
                              ? Icons.check_circle_outline
                              : Icons.cloud_off,
                          color: conditions.isSuitable
                              ? scheme.tertiary
                              : scheme.error,
                        ),
                        title: Text('${conditions.rating} sky'),
                        subtitle: Text(
                          'Cloud cover ${conditions.cloudCover.toStringAsFixed(0)}% • '
                          '${conditions.summary}',
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _objectId,
                    decoration: const InputDecoration(labelText: 'Celestial object'),
                    items: [
                      for (final object in catalog.items)
                        DropdownMenuItem(
                          value: object.id,
                          child: Text(object.name),
                        ),
                    ],
                    onChanged: (value) => setState(() => _objectId = value),
                    validator: (value) =>
                        value == null ? 'Select an object' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _telescopeId,
                    decoration: const InputDecoration(labelText: 'Telescope'),
                    items: [
                      for (final telescope in telescopes.items)
                        DropdownMenuItem(
                          value: telescope.id,
                          child: Text(telescope.name),
                        ),
                    ],
                    onChanged: (value) => setState(() => _telescopeId = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _questId,
                    decoration: const InputDecoration(labelText: 'Quest (optional)'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: '',
                        child: Text('No quest'),
                      ),
                      for (final quest in quests.quests)
                        DropdownMenuItem(
                          value: quest.id,
                          child: Text(quest.title),
                        ),
                    ],
                    onChanged: (value) => setState(() => _questId = value),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^-?\d*\.?\d*'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                          ),
                          validator: (value) {
                            final latitude = double.tryParse(value ?? '');
                            if (latitude == null ||
                                latitude < -90 ||
                                latitude > 90) {
                              return 'Enter latitude -90…90';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _longitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^-?\d*\.?\d*'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                          ),
                          validator: (value) {
                            final longitude = double.tryParse(value ?? '');
                            if (longitude == null ||
                                longitude < -180 ||
                                longitude > 180) {
                              return 'Enter longitude -180…180';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Observation notes',
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_statusMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_statusMessage!),
                    ),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.verified_outlined),
                    label: const Text('Submit for verification'),
                  ),
                  const SizedBox(height: 16),
                  StatBadge(
                    label: conditions?.rating ?? 'Weather unavailable',
                    color: conditions?.isSuitable == true
                        ? scheme.tertiary
                        : scheme.secondary,
                  ),
                ],
              ),
            ),
    );
  }
}

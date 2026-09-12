import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/repository_providers.dart';
import '../providers/plant_providers.dart';
import '../widgets/species_picker.dart';

/// Экран добавления/редактирования растения.
///
/// Если [plantId] == null — создание. Иначе — редактирование.
class PlantFormScreen extends ConsumerStatefulWidget {
  const PlantFormScreen({super.key, this.plantId});

  final int? plantId;

  bool get isEditing => plantId != null;

  @override
  ConsumerState<PlantFormScreen> createState() => _PlantFormScreenState();
}

class _PlantFormScreenState extends ConsumerState<PlantFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- Обязательные поля ---
  final _nameController = TextEditingController();

  // --- Опциональные поля растения ---
  final _locationController = TextEditingController();
  final _soilController = TextEditingController();
  final _potSizeController = TextEditingController();
  final _notesController = TextEditingController();
  final _wateringDaysController = TextEditingController();
  final _fertilizingDaysController = TextEditingController();

  // --- Поля семян ---
  final _seedVarietyController = TextEditingController();
  final _plantingLocationController = TextEditingController();

  // --- Состояние ---
  PlantSpecy? _selectedSpecies;
  String? _imagePath;
  String? _seedPacketImagePath;
  DateTime? _seedlingPlantingDate;
  bool _isSaving = false;
  bool _initialized = false;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _soilController.dispose();
    _potSizeController.dispose();
    _notesController.dispose();
    _wateringDaysController.dispose();
    _fertilizingDaysController.dispose();
    _seedVarietyController.dispose();
    _plantingLocationController.dispose();
    super.dispose();
  }

  /// Заполнение полей при редактировании.
  Future<void> _loadExisting(Plant plant) async {
    if (_initialized) return;
    _initialized = true;

    _nameController.text = plant.customName;
    _locationController.text = plant.location ?? '';
    _soilController.text = plant.soilType ?? '';
    _potSizeController.text = plant.potSize ?? '';
    _notesController.text = plant.notes ?? '';
    _wateringDaysController.text =
        plant.wateringFrequencyDays?.toString() ?? '';
    _fertilizingDaysController.text =
        plant.fertilizingFrequencyDays?.toString() ?? '';
    _seedVarietyController.text = plant.seedVarietyName ?? '';
    _plantingLocationController.text = plant.plantingLocation ?? '';
    _imagePath = plant.imagePath;
    _seedPacketImagePath = plant.seedPacketImagePath;
    _seedlingPlantingDate = plant.seedlingPlantingDate;

    if (plant.speciesId != null) {
      final species = await ref
          .read(speciesRepositoryProvider)
          .getById(plant.speciesId!);
      if (mounted) {
        setState(() => _selectedSpecies = species);
      }
    }
  }

  // ---------- Действия ----------

  Future<void> _pickSpecies() async {
    final picked = await showSpeciesPicker(context);
    if (picked == null) return;
    setState(() {
      _selectedSpecies = picked;
      if (_nameController.text.isEmpty) {
        _nameController.text = picked.commonName;
      }
      if (_wateringDaysController.text.isEmpty &&
          picked.defaultWateringDays != null) {
        _wateringDaysController.text = picked.defaultWateringDays!.toString();
      }
      if (_soilController.text.isEmpty && picked.soilType != null) {
        _soilController.text = picked.soilType!;
      }
    });
  }

  Future<void> _pickImage({required bool isSeedPacket}) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Сделать фото'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Выбрать из галереи'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось получить изображение: $e')),
        );
      }
      return;
    }

    if (picked == null) return;

    if (!mounted) return;

    setState(() {
      if (isSeedPacket) {
        _seedPacketImagePath = picked!.path;
      } else {
        _imagePath = picked!.path;
      }
    });
  }

  Future<void> _pickSeedlingDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _seedlingPlantingDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 2),
      locale: const Locale('ru'),
    );
    if (picked != null) {
      setState(() => _seedlingPlantingDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final imageStorage = ref.read(imageStorageServiceProvider);

      // Сохранить фото растения, если выбрано новое.
      String? savedImagePath = _imagePath;
      if (_imagePath != null &&
          File(_imagePath!).existsSync() &&
          !_imagePath!.contains('pocket_botanist_images')) {
        savedImagePath = await imageStorage.saveImage(
          File(_imagePath!),
          prefix: 'plant',
        );
      }

      // Сохранить фото пакетика семян, если выбрано новое.
      String? savedSeedImagePath = _seedPacketImagePath;
      if (_seedPacketImagePath != null &&
          File(_seedPacketImagePath!).existsSync() &&
          !_seedPacketImagePath!.contains('pocket_botanist_images')) {
        savedSeedImagePath = await imageStorage.saveImage(
          File(_seedPacketImagePath!),
          prefix: 'seed',
        );
      }

      final userId = ref.read(currentUserIdProvider);
      final controller = ref.read(plantControllerProvider);

      if (widget.isEditing) {
        // При редактировании используем PlantsCompanion без id —
        // обновляем только переданные поля.
        final companion = PlantsCompanion(
          speciesId: Value(_selectedSpecies?.id),
          customName: Value(_nameController.text.trim()),
          imagePath: Value(savedImagePath),
          location: Value(_nullIfEmpty(_locationController.text)),
          soilType: Value(_nullIfEmpty(_soilController.text)),
          potSize: Value(_nullIfEmpty(_potSizeController.text)),
          notes: Value(_nullIfEmpty(_notesController.text)),
          wateringFrequencyDays: Value(
            int.tryParse(_wateringDaysController.text),
          ),
          fertilizingFrequencyDays: Value(
            int.tryParse(_fertilizingDaysController.text),
          ),
          seedVarietyName: Value(_nullIfEmpty(_seedVarietyController.text)),
          plantingLocation: Value(
            _nullIfEmpty(_plantingLocationController.text),
          ),
          seedlingPlantingDate: Value(_seedlingPlantingDate),
          seedPacketImagePath: Value(savedSeedImagePath),
        );
        await controller.update(widget.plantId!, companion);
      } else {
        final companion = PlantsCompanion(
          userId: Value(userId),
          speciesId: Value(_selectedSpecies?.id),
          customName: Value(_nameController.text.trim()),
          imagePath: Value(savedImagePath),
          location: Value(_nullIfEmpty(_locationController.text)),
          soilType: Value(_nullIfEmpty(_soilController.text)),
          potSize: Value(_nullIfEmpty(_potSizeController.text)),
          notes: Value(_nullIfEmpty(_notesController.text)),
          wateringFrequencyDays: Value(
            int.tryParse(_wateringDaysController.text),
          ),
          fertilizingFrequencyDays: Value(
            int.tryParse(_fertilizingDaysController.text),
          ),
          seedVarietyName: Value(_nullIfEmpty(_seedVarietyController.text)),
          plantingLocation: Value(
            _nullIfEmpty(_plantingLocationController.text),
          ),
          seedlingPlantingDate: Value(_seedlingPlantingDate),
          seedPacketImagePath: Value(savedSeedImagePath),
        );
        await controller.create(companion);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing ? 'Растение обновлено' : 'Растение добавлено',
          ),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      final plantAsync = ref.watch(plantByIdProvider(widget.plantId!));
      return plantAsync.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, _) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('Ошибка: $err')),
        ),
        data: (plant) {
          if (plant == null) {
            return const Scaffold(
              body: Center(child: Text('Растение не найдено')),
            );
          }
          _loadExisting(plant);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Редактировать' : 'Новое растение'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(onPressed: _save, child: const Text('Сохранить')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPhotoSection(),
            const SizedBox(height: 16),
            _buildSpeciesSection(),
            const SizedBox(height: 16),
            _buildMainFields(),
            const SizedBox(height: 24),
            _buildSeedSection(),
            const SizedBox(height: 24),
            _buildNotesSection(),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.check),
              label: Text(widget.isEditing ? 'Сохранить' : 'Добавить'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    final hasImage = _imagePath != null && File(_imagePath!).existsSync();
    return Center(
      child: GestureDetector(
        onTap: () => _pickImage(isSeedPacket: false),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 160,
                height: 160,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: hasImage
                    ? Image.file(File(_imagePath!), fit: BoxFit.cover)
                    : Icon(
                        Icons.add_a_photo,
                        size: 48,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
              ),
            ),
            if (hasImage)
              Positioned(
                top: 4,
                right: 4,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  child: IconButton(
                    iconSize: 16,
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _imagePath = null),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeciesSection() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_florist),
        title: Text(_selectedSpecies?.commonName ?? 'Вид не выбран'),
        subtitle: _selectedSpecies != null
            ? Text(
                _selectedSpecies!.scientificName,
                style: const TextStyle(fontStyle: FontStyle.italic),
              )
            : const Text('Нажмите, чтобы выбрать из справочника'),
        trailing: const Icon(Icons.chevron_right),
        onTap: _pickSpecies,
      ),
    );
  }

  Widget _buildMainFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Имя растения *',
            hintText: 'Например, Моника',
            prefixIcon: Icon(Icons.label),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Введите имя' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Местоположение',
            hintText: 'Например, Кухня, подоконник',
            prefixIcon: Icon(Icons.place),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _wateringDaysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Полив, дней',
                  prefixIcon: Icon(Icons.water_drop),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _fertilizingDaysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Удобрение, дней',
                  prefixIcon: Icon(Icons.eco),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _soilController,
                decoration: const InputDecoration(
                  labelText: 'Тип почвы',
                  prefixIcon: Icon(Icons.grass),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _potSizeController,
                decoration: const InputDecoration(
                  labelText: 'Размер горшка',
                  prefixIcon: Icon(Icons.circle_outlined),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSeedSection() {
    final hasSeedImage =
        _seedPacketImagePath != null &&
        File(_seedPacketImagePath!).existsSync();

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.agriculture),
        title: const Text('Семена и рассада'),
        subtitle: const Text('Необязательно'),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _pickImage(isSeedPacket: true),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: hasSeedImage
                        ? Image.file(
                            File(_seedPacketImagePath!),
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.add_photo_alternate, size: 32),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Фото пакетика семян',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (hasSeedImage)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => _seedPacketImagePath = null),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _seedVarietyController,
            decoration: const InputDecoration(
              labelText: 'Название сорта',
              hintText: 'Например, Черри',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _plantingLocationController,
            decoration: const InputDecoration(
              labelText: 'Место высадки',
              hintText: 'Например, Теплица №2, грядка 3',
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: const Text('Дата высадки рассады'),
            subtitle: Text(
              _seedlingPlantingDate == null
                  ? 'Не указана'
                  : DateFormat(
                      'd MMMM yyyy',
                      'ru',
                    ).format(_seedlingPlantingDate!),
            ),
            trailing: _seedlingPlantingDate != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () =>
                        setState(() => _seedlingPlantingDate = null),
                  )
                : const Icon(Icons.chevron_right),
            onTap: _pickSeedlingDate,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return TextFormField(
      controller: _notesController,
      maxLines: 4,
      decoration: const InputDecoration(
        labelText: 'Заметки',
        alignLabelWithHint: true,
        prefixIcon: Icon(Icons.notes),
      ),
    );
  }
}

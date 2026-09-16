import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/profile_providers.dart';

/// Экран редактирования профиля: аватар, имя, город, описание.
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _bioController = TextEditingController();

  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(profileDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Сохранить'),
          ),
        ],
      ),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Ошибка: $err')),
        data: (data) {
          if (!_initialized) {
            _nameController.text = data.user.displayName ?? '';
            _cityController.text = data.user.city ?? '';
            _bioController.text = data.user.bio ?? '';
            _initialized = true;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _AvatarSection(avatarPath: data.user.avatarPath),
              const SizedBox(height: 24),
              _Field(
                controller: _nameController,
                label: 'Имя',
                hint: 'Как к вам обращаться',
                icon: Icons.person_outline,
                maxLength: 100,
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _cityController,
                label: 'Город',
                hint: 'Например, Москва',
                icon: Icons.location_city_outlined,
                maxLength: 100,
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _bioController,
                label: 'О себе',
                hint: 'Пара слов о вас и ваших растениях',
                icon: Icons.notes_outlined,
                maxLength: 200,
                maxLines: 3,
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final controller = ref.read(userProfileControllerProvider);
      await controller.updateName(_nameController.text);
      await controller.updateCity(_cityController.text);
      await controller.updateBio(_bioController.text);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Профиль сохранён')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// =========================================================================
//  Секции
// =========================================================================

class _AvatarSection extends ConsumerStatefulWidget {
  const _AvatarSection({required this.avatarPath});

  final String? avatarPath;

  @override
  ConsumerState<_AvatarSection> createState() => _AvatarSectionState();
}

class _AvatarSectionState extends ConsumerState<_AvatarSection> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAvatar =
        widget.avatarPath != null && File(widget.avatarPath!).existsSync();

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 56,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: hasAvatar
                    ? FileImage(File(widget.avatarPath!))
                    : null,
                child: !hasAvatar
                    ? Icon(
                        Icons.person,
                        size: 56,
                        color: theme.colorScheme.onPrimaryContainer,
                      )
                    : null,
              ),
              if (_busy)
                const Positioned.fill(
                  child: CircleAvatar(
                    backgroundColor: Colors.black38,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _busy ? null : _pickFromGallery,
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Галерея'),
              ),
              TextButton.icon(
                onPressed: _busy ? null : _pickFromCamera,
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text('Камера'),
              ),
              if (hasAvatar)
                TextButton.icon(
                  onPressed: _busy ? null : _clear,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Удалить'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromGallery() => _pick(ImageSource.gallery);

  Future<void> _pickFromCamera() => _pick(ImageSource.camera);

  Future<void> _pick(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 2048);
    if (picked == null) return;

    setState(() => _busy = true);
    try {
      final controller = ref.read(userProfileControllerProvider);
      await controller.setAvatar(File(picked.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clear() async {
    setState(() => _busy = true);
    try {
      final controller = ref.read(userProfileControllerProvider);
      await controller.clearAvatar();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLength,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int? maxLength;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        counterText: '',
      ),
    );
  }
}

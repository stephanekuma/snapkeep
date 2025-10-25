import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snapkeep/src/core/widgets/permission_modal.dart';

class PermissionService {
  static final List<Permission> _requiredPermissions = [
    Permission.storage,
    Permission.manageExternalStorage,
    Permission.notification, // Pour les notifications
    // Permissions optionnelles selon les fonctionnalités
    // Permission.camera,         // Pour capturer des photos
    // Permission.microphone,     // Pour les notes vocales
  ];

  static Future<bool> checkAllPermissions() async {
    for (final permission in _requiredPermissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        return false;
      }
    }
    return true;
  }

  static Future<List<Permission>> getMissingPermissions() async {
    final List<Permission> missing = [];

    for (final permission in _requiredPermissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        missing.add(permission);
      }
    }

    return missing;
  }

  static Future<bool> requestPermissions(BuildContext context) async {
    final missingPermissions = await getMissingPermissions();

    if (missingPermissions.isEmpty) {
      return true;
    }

    bool allGranted = false;

    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PermissionModal(
          permissions: missingPermissions,
          onAllPermissionsGranted: () {
            allGranted = true;
          },
          onPermissionDenied: () {
            allGranted = false;
          },
        ),
      );
    }

    return allGranted;
  }

  static Future<void> showPermissionDeniedSnackBar(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Permissions requises non accordées'),
        action: SnackBarAction(
          label: 'Paramètres',
          onPressed: () => openAppSettings(),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  static Future<bool> requestSpecificPermission(
    BuildContext context,
    Permission permission,
  ) async {
    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission refusée'),
            content: const Text(
              'Cette permission a été refusée de façon permanente. '
              'Veuillez l\'activer dans les paramètres de l\'application.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Paramètres'),
              ),
            ],
          ),
        );
      }
      return false;
    }

    final newStatus = await permission.request();
    return newStatus.isGranted;
  }

  static String getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.storage:
        return 'Accès au stockage';
      case Permission.manageExternalStorage:
        return 'Gestion des fichiers';
      case Permission.photos:
        return 'Photos';
      case Permission.videos:
        return 'Vidéos';
      case Permission.camera:
        return 'Caméra';
      case Permission.microphone:
        return 'Microphone';
      case Permission.notification:
        return 'Notifications';
      default:
        return 'Permission inconnue';
    }
  }

  static String getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.storage:
        return 'Accès au stockage pour sauvegarder vos statuts WhatsApp';
      case Permission.manageExternalStorage:
        return 'Gestion des fichiers pour organiser vos médias sauvegardés';
      case Permission.photos:
        return 'Accès aux photos pour sauvegarder vos images';
      case Permission.videos:
        return 'Accès aux vidéos pour sauvegarder vos clips';
      case Permission.camera:
        return 'Accès à la caméra pour capturer des photos';
      case Permission.microphone:
        return 'Accès au microphone pour les enregistrements';
      case Permission.notification:
        return 'Notifications pour vous informer des nouveaux statuts';
      default:
        return 'Permission nécessaire au fonctionnement';
    }
  }
}

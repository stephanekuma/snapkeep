import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snapkeep/src/core/services/permission_service.dart';

class PermissionChecker extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPermissionsGranted;
  final VoidCallback? onPermissionsDenied;

  const PermissionChecker({
    super.key,
    required this.child,
    this.onPermissionsGranted,
    this.onPermissionsDenied,
  });

  @override
  State<PermissionChecker> createState() => _PermissionCheckerState();
}

class _PermissionCheckerState extends State<PermissionChecker> {
  bool _isCheckingPermissions = true;
  bool _hasAllPermissions = false;

  @override
  void initState() {
    super.initState();
    // Délai pour s'assurer que le widget est complètement monté
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissions();
    });
  }

  Future<void> _checkPermissions() async {
    try {
      // Vérifier l'état de chaque permission individuellement
      final allPermissions = [
        Permission.storage,
        Permission.manageExternalStorage,
        Permission.notification,
      ];

      bool hasAllPermissions = true;
      for (final permission in allPermissions) {
        if (!mounted) return; // Vérifier si le widget est encore monté

        final status = await permission.status;
        if (!status.isGranted) {
          hasAllPermissions = false;
          break;
        }
      }

      if (mounted) {
        setState(() {
          _hasAllPermissions = hasAllPermissions;
          _isCheckingPermissions = false;
        });

        if (hasAllPermissions) {
          widget.onPermissionsGranted?.call();
        } else {
          widget.onPermissionsDenied?.call();
        }
      }
    } catch (e) {
      // En cas d'erreur, considérer que les permissions ne sont pas accordées
      if (mounted) {
        setState(() {
          _hasAllPermissions = false;
          _isCheckingPermissions = false;
        });
        widget.onPermissionsDenied?.call();
      }
    }
  }

  Future<void> _requestPermissions() async {
    try {
      // Vérifier d'abord l'état actuel des permissions
      final allPermissions = [
        Permission.storage,
        Permission.manageExternalStorage,
        Permission.notification,
      ];

      // Vérifier quelles permissions sont déjà accordées
      final Map<Permission, PermissionStatus> currentStatuses = {};
      for (final permission in allPermissions) {
        if (!mounted) return; // Vérifier si le widget est encore monté
        currentStatuses[permission] = await permission.status;
      }

      // Filtrer seulement les permissions qui ne sont pas accordées
      final missingPermissions = allPermissions.where((permission) {
        final status = currentStatuses[permission];
        return status != null && !status.isGranted;
      }).toList();

      if (missingPermissions.isEmpty) {
        if (mounted) {
          setState(() {
            _hasAllPermissions = true;
          });
          widget.onPermissionsGranted?.call();
        }
        return;
      }

      // Demander seulement les permissions manquantes avec délai
      bool allGranted = true;
      for (int i = 0; i < missingPermissions.length; i++) {
        if (!mounted) return; // Vérifier si le widget est encore monté

        final permission = missingPermissions[i];
        final status = await permission.request();

        if (!status.isGranted) {
          allGranted = false;
          if (status.isPermanentlyDenied) {
            // Rediriger vers les paramètres
            await _showPermissionDeniedDialog(permission);
          }
        }

        // Délai entre les demandes pour éviter les conflits
        if (i < missingPermissions.length - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      if (mounted) {
        setState(() {
          _hasAllPermissions = allGranted;
        });

        if (allGranted) {
          widget.onPermissionsGranted?.call();
        } else {
          widget.onPermissionsDenied?.call();
          await PermissionService.showPermissionDeniedSnackBar(context);
        }
      }
    } catch (e) {
      // En cas d'erreur, considérer que les permissions ne sont pas accordées
      if (mounted) {
        setState(() {
          _hasAllPermissions = false;
        });
        widget.onPermissionsDenied?.call();
      }
    }
  }

  Future<void> _showPermissionDeniedDialog(Permission permission) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission refusée'),
        content: Text(
          'La permission ${PermissionService.getPermissionName(permission)} a été refusée. '
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

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermissions) {
      return _buildLoadingScreen();
    }

    if (!_hasAllPermissions) {
      return _buildPermissionRequiredScreen();
    }

    return widget.child;
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Vérification des permissions...',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRequiredScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(
                  FontAwesomeIcons.shieldHalved,
                  size: 64.sp,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'Permissions requises',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'Snapkeep a besoin d\'accéder à votre stockage pour sauvegarder vos statuts WhatsApp.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: _requestPermissions,
                icon: const FaIcon(FontAwesomeIcons.shieldHalved),
                label: const Text('Autoriser les permissions'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 16.h,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () {
                  // Option pour continuer sans permissions (mode limité)
                  setState(() {
                    _hasAllPermissions = true;
                  });
                  widget.onPermissionsGranted?.call();
                },
                child: Text(
                  'Continuer en mode limité',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';

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
  Map<Permission, PermissionStatus> _permissionStatuses = {};

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

      Map<Permission, PermissionStatus> statuses = {};
      bool hasAllPermissions = true;

      for (final permission in allPermissions) {
        if (!mounted) return; // Vérifier si le widget est encore monté

        final status = await permission.status;
        statuses[permission] = status;
        if (!status.isGranted) {
          hasAllPermissions = false;
        }
      }

      if (mounted) {
        setState(() {
          _hasAllPermissions = hasAllPermissions;
          _isCheckingPermissions = false;
          _permissionStatuses = statuses;
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
    print('🔐 Début de la demande de permissions');

    try {
      // Permissions requises
      final allPermissions = [
        Permission.storage,
        Permission.manageExternalStorage,
        Permission.notification,
      ];

      // Identifier les permissions manquantes
      final missingPermissions = allPermissions.where((permission) {
        final status = _permissionStatuses[permission];
        return status == null || !status.isGranted;
      }).toList();

      print('🔐 Permissions manquantes: ${missingPermissions.length}');

      if (missingPermissions.isEmpty) {
        // Toutes les permissions sont accordées
        if (mounted) {
          setState(() {
            _hasAllPermissions = true;
          });
          widget.onPermissionsGranted?.call();
        }
        return;
      }

      // Demander chaque permission manquante individuellement
      for (final permission in missingPermissions) {
        if (!mounted) return;

        print('🔐 Demande de permission: $permission');

        // Afficher un modal spécifique pour cette permission
        final granted = await _requestSpecificPermission(permission);

        if (!granted) {
          print('🔐 Permission refusée: $permission');
          // Continuer avec les autres permissions
        } else {
          print('🔐 Permission accordée: $permission');
          // Mettre à jour le statut
          _permissionStatuses[permission] = PermissionStatus.granted;
        }
      }

      // Vérifier si toutes les permissions sont maintenant accordées
      final allGranted = allPermissions.every((permission) {
        final status = _permissionStatuses[permission];
        return status != null && status.isGranted;
      });

      if (mounted) {
        setState(() {
          _hasAllPermissions = allGranted;
        });

        if (allGranted) {
          print('🔐 Toutes les permissions accordées - appel du callback');
          widget.onPermissionsGranted?.call();
        } else {
          print('🔐 Certaines permissions refusées - appel du callback');
          widget.onPermissionsDenied?.call();
        }
      }
    } catch (e) {
      print('🔐 Erreur lors de la demande de permissions: $e');

      if (mounted) {
        setState(() {
          _hasAllPermissions = false;
        });
        widget.onPermissionsDenied?.call();
      }
    }
  }

  Future<bool> _requestSpecificPermission(Permission permission) async {
    try {
      // Afficher un modal explicatif pour cette permission
      final shouldRequest = await _showPermissionModal(permission);

      if (!shouldRequest) {
        return false;
      }

      // Demander la permission
      final status = await permission.request();

      return status.isGranted;
    } catch (e) {
      print('🔐 Erreur lors de la demande de permission $permission: $e');
      return false;
    }
  }

  Future<bool> _showPermissionModal(Permission permission) async {
    if (!mounted) return false;

    final permissionInfo = _getPermissionInfo(permission);

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  permissionInfo['icon'] as IconData,
                  color: Theme.of(context).primaryColor,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    permissionInfo['title'] as String,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  permissionInfo['description'] as String,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.info,
                        color: Colors.blue[700],
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Cette permission est nécessaire pour que l\'application fonctionne correctement.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Ignorer'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Autoriser'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Map<String, dynamic> _getPermissionInfo(Permission permission) {
    switch (permission) {
      case Permission.storage:
        return {
          'icon': LucideIcons.folder,
          'title': 'Accès au stockage',
          'description':
              'Snapkeep a besoin d\'accéder à votre stockage pour sauvegarder vos statuts WhatsApp.',
        };
      case Permission.manageExternalStorage:
        return {
          'icon': LucideIcons.settings,
          'title': 'Gestion des fichiers',
          'description':
              'Cette permission permet d\'organiser et gérer vos médias sauvegardés.',
        };
      case Permission.notification:
        return {
          'icon': LucideIcons.bell,
          'title': 'Notifications',
          'description':
              'Recevez des notifications lorsque de nouveaux statuts sont sauvegardés.',
        };
      default:
        return {
          'icon': LucideIcons.shield,
          'title': 'Permission requise',
          'description':
              'Cette permission est nécessaire au fonctionnement de l\'application.',
        };
    }
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
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.shield,
                size: 48.sp,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 32.h),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
              strokeWidth: 3.0,
            ),
            SizedBox(height: 24.h),
            Text(
              'Vérification des permissions...',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Nous vérifions que vous avez accordé les permissions nécessaires',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
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
                child: Icon(
                  LucideIcons.shield,
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
              SizedBox(height: 24.h),
              _buildPermissionList(),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      _isCheckingPermissions ? null : _requestPermissions,
                  icon: _isCheckingPermissions
                      ? SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Icon(LucideIcons.shield),
                  label: Text(_isCheckingPermissions
                      ? 'Demande en cours...'
                      : 'Autoriser les permissions'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 16.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
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

  Widget _buildPermissionList() {
    final permissions = [
      {
        'permission': Permission.storage,
        'icon': LucideIcons.folder,
        'title': 'Accès au stockage',
        'description': 'Sauvegarder vos statuts WhatsApp',
      },
      {
        'permission': Permission.manageExternalStorage,
        'icon': LucideIcons.settings,
        'title': 'Gestion des fichiers',
        'description': 'Organiser vos médias sauvegardés',
      },
      {
        'permission': Permission.notification,
        'icon': LucideIcons.bell,
        'title': 'Notifications',
        'description': 'Vous informer des nouvelles sauvegardes',
      },
    ];

    return Column(
      children: permissions.map((permissionData) {
        final permission = permissionData['permission'] as Permission;
        final status = _permissionStatuses[permission];
        final isGranted = status?.isGranted ?? false;

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isGranted ? Colors.green[50] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isGranted ? Colors.green[300]! : Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isGranted
                      ? Colors.green[100]
                      : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  permissionData['icon'] as IconData,
                  color: isGranted
                      ? Colors.green[700]
                      : Theme.of(context).primaryColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            permissionData['title'] as String,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (isGranted)
                          Icon(
                            LucideIcons.circleCheck,
                            color: Colors.green[700],
                            size: 16.sp,
                          )
                        else
                          Icon(
                            LucideIcons.x,
                            color: Colors.red[700],
                            size: 16.sp,
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      permissionData['description'] as String,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (isGranted)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          '✓ Accordée',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          '✗ Refusée',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

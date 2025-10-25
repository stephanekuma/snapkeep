import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionModal extends StatefulWidget {
  final List<Permission> permissions;
  final VoidCallback? onAllPermissionsGranted;
  final VoidCallback? onPermissionDenied;

  const PermissionModal({
    super.key,
    required this.permissions,
    this.onAllPermissionsGranted,
    this.onPermissionDenied,
  });

  @override
  State<PermissionModal> createState() => _PermissionModalState();
}

class _PermissionModalState extends State<PermissionModal>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentStep = 0;
  Map<Permission, PermissionStatus> _permissionStatuses = {};
  bool _isRequestingPermission = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
    _checkInitialPermissions();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkInitialPermissions() async {
    final Map<Permission, PermissionStatus> statuses = {};
    for (final permission in widget.permissions) {
      statuses[permission] = await permission.status;
    }
    setState(() {
      _permissionStatuses = statuses;
    });
  }

  Future<void> _requestPermission(Permission permission) async {
    if (_isRequestingPermission) {
      return;
    }

    _isRequestingPermission = true;

    try {
      final status = await permission.request();
      setState(() {
        _permissionStatuses[permission] = status;
      });

      if (status.isGranted) {
        // Vérifier si toutes les permissions sont accordées
        _checkAllPermissions();
        if (!_areAllPermissionsGranted()) {
          _nextStep();
        }
      } else if (status.isPermanentlyDenied) {
        _showPermissionDeniedDialog(permission);
      }
    } catch (e) {
      // En cas d'erreur, passer à l'étape suivante
      _nextStep();
    } finally {
      _isRequestingPermission = false;
    }
  }

  void _nextStep() {
    if (_currentStep < widget.permissions.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _checkAllPermissions();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _areAllPermissionsGranted() {
    return widget.permissions.every(
      (permission) => _permissionStatuses[permission]?.isGranted ?? false,
    );
  }

  void _checkAllPermissions() {
    if (_areAllPermissionsGranted()) {
      Navigator.of(context, rootNavigator: true).pop();
      widget.onAllPermissionsGranted?.call();
    }
  }

  void _showPermissionDeniedDialog(Permission permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission refusée'),
        content: const Text(
          'Cette permission est nécessaire pour le bon fonctionnement de l\'application. '
          'Veuillez l\'activer dans les paramètres.',
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
    return PopScope(
      canPop: false, // Empêche la fermeture par retour
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20.r,
                      offset: Offset(0, 10.h),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    _buildProgressIndicator(),
                    _buildContent(),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              FontAwesomeIcons.shield,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Permissions requises',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Étape ${_currentStep + 1} sur ${widget.permissions.length}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: List.generate(widget.permissions.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              height: 4.h,
              decoration: BoxDecoration(
                color: isActive || isCompleted
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent() {
    return SizedBox(
      height: 300.h,
      child: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.permissions.length,
        itemBuilder: (context, index) {
          final permission = widget.permissions[index];
          return _buildPermissionStep(permission);
        },
      ),
    );
  }

  Widget _buildPermissionStep(Permission permission) {
    final status = _permissionStatuses[permission];
    final isGranted = status?.isGranted ?? false;

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: isGranted
                  ? Colors.green.withValues(alpha: 0.1)
                  : Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              _getPermissionIcon(permission),
              size: 48.sp,
              color: isGranted ? Colors.green : Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            _getPermissionTitle(permission),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            _getPermissionDescription(permission),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (isGranted) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.check,
                    size: 16.sp,
                    color: Colors.green,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Permission accordée',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions() {
    final currentPermission = widget.permissions[_currentStep];
    final status = _permissionStatuses[currentPermission];
    final isGranted = status?.isGranted ?? false;

    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Précédent'),
              ),
            ),
          if (_currentStep > 0) SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isGranted
                  ? _nextStep
                  : () => _requestPermission(currentPermission),
              child: Text(
                isGranted
                    ? (_currentStep == widget.permissions.length - 1
                        ? 'Terminer'
                        : 'Suivant')
                    : 'Autoriser',
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPermissionIcon(Permission permission) {
    switch (permission) {
      case Permission.storage:
      case Permission.manageExternalStorage:
        return FontAwesomeIcons.hardDrive;
      case Permission.camera:
        return FontAwesomeIcons.camera;
      case Permission.photos:
        return FontAwesomeIcons.images;
      case Permission.videos:
        return FontAwesomeIcons.video;
      case Permission.microphone:
        return FontAwesomeIcons.microphone;
      case Permission.notification:
        return FontAwesomeIcons.bell;
      default:
        return FontAwesomeIcons.shield;
    }
  }

  String _getPermissionTitle(Permission permission) {
    switch (permission) {
      case Permission.storage:
        return 'Accès au stockage';
      case Permission.manageExternalStorage:
        return 'Gestion des fichiers';
      case Permission.camera:
        return 'Accès à la caméra';
      case Permission.photos:
        return 'Accès aux photos';
      case Permission.videos:
        return 'Accès aux vidéos';
      case Permission.microphone:
        return 'Accès au microphone';
      case Permission.notification:
        return 'Notifications';
      default:
        return 'Permission requise';
    }
  }

  String _getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.storage:
        return 'Cette permission permet à l\'application de sauvegarder vos statuts WhatsApp.';
      case Permission.manageExternalStorage:
        return 'Nécessaire pour organiser et gérer vos fichiers sauvegardés.';
      case Permission.camera:
        return 'Permet de capturer des photos directement dans l\'application.';
      case Permission.photos:
        return 'Accès à votre galerie pour sauvegarder et organiser vos images.';
      case Permission.videos:
        return 'Accès à vos vidéos pour les sauvegarder et les partager.';
      case Permission.microphone:
        return 'Nécessaire pour enregistrer des notes vocales.';
      case Permission.notification:
        return 'Pour vous notifier des nouveaux statuts et mises à jour.';
      default:
        return 'Cette permission est nécessaire pour le bon fonctionnement de l\'application.';
    }
  }
}

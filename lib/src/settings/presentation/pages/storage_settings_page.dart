import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

@RoutePage()
class StorageSettingsPage extends StatefulWidget {
  const StorageSettingsPage({super.key});

  @override
  State<StorageSettingsPage> createState() => _StorageSettingsPageState();
}

class _StorageSettingsPageState extends State<StorageSettingsPage> {
  final String _selectedStoragePath = '/storage/emulated/0/Snapkeep';
  bool _autoCleanup = false;
  bool _compressImages = false;
  int _maxStorageSize = 1000; // MB
  int _cleanupDays = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Paramètres de stockage',
          style: TextStyle(fontSize: 22.sp),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStorageInfo(),
            SizedBox(height: 24.h),
            _buildStoragePathSection(),
            SizedBox(height: 24.h),
            _buildAutoCleanupSection(),
            SizedBox(height: 24.h),
            _buildCompressionSection(),
            SizedBox(height: 24.h),
            _buildStorageLimitSection(),
            SizedBox(height: 24.h),
            _buildCleanupSection(),
            SizedBox(height: 32.h),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.hardDrive,
                color: Theme.of(context).primaryColor,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Espace de stockage',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildStorageBar(),
          SizedBox(height: 8.h),
          Text(
            'Utilisé: 245 MB / 1.2 GB disponible',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Images', style: TextStyle(fontSize: 12.sp)),
            Text('180 MB', style: TextStyle(fontSize: 12.sp)),
          ],
        ),
        SizedBox(height: 4.h),
        LinearProgressIndicator(
          value: 0.15, // 180/1200
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Vidéos', style: TextStyle(fontSize: 12.sp)),
            Text('65 MB', style: TextStyle(fontSize: 12.sp)),
          ],
        ),
        SizedBox(height: 4.h),
        LinearProgressIndicator(
          value: 0.05, // 65/1200
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
        ),
      ],
    );
  }

  Widget _buildStoragePathSection() {
    return _buildSection(
      title: 'Dossier de sauvegarde',
      icon: FontAwesomeIcons.folder,
      child: Column(
        children: [
          ListTile(
            title: const Text('Chemin actuel'),
            subtitle: Text(_selectedStoragePath),
            trailing: IconButton(
              onPressed: _selectStoragePath,
              icon: const FaIcon(FontAwesomeIcons.folderOpen),
            ),
          ),
          ListTile(
            title: const Text('Créer un nouveau dossier'),
            subtitle: const Text('Organiser vos sauvegardes'),
            trailing: const FaIcon(FontAwesomeIcons.plus),
            onTap: _createNewFolder,
          ),
        ],
      ),
    );
  }

  Widget _buildAutoCleanupSection() {
    return _buildSection(
      title: 'Nettoyage automatique',
      icon: FontAwesomeIcons.broom,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Activer le nettoyage automatique'),
            subtitle:
                const Text('Supprimer automatiquement les anciens fichiers'),
            value: _autoCleanup,
            onChanged: (value) {
              setState(() {
                _autoCleanup = value;
              });
            },
          ),
          if (_autoCleanup) ...[
            ListTile(
              title: Text('Supprimer après $_cleanupDays jours'),
              subtitle:
                  const Text('Les fichiers plus anciens seront supprimés'),
              trailing: DropdownButton<int>(
                value: _cleanupDays,
                items: [7, 15, 30, 60, 90].map((days) {
                  return DropdownMenuItem(
                    value: days,
                    child: Text('$days jours'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _cleanupDays = value!;
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompressionSection() {
    return _buildSection(
      title: 'Compression des médias',
      icon: FontAwesomeIcons.compress,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Compresser les images'),
            subtitle: const Text('Réduire la taille des images sauvegardées'),
            value: _compressImages,
            onChanged: (value) {
              setState(() {
                _compressImages = value;
              });
            },
          ),
          if (_compressImages)
            ListTile(
              title: const Text('Qualité de compression'),
              subtitle: const Text('Équilibre entre qualité et taille'),
              trailing: DropdownButton<String>(
                value: 'Moyenne',
                items: ['Haute', 'Moyenne', 'Basse'].map((quality) {
                  return DropdownMenuItem(
                    value: quality,
                    child: Text(quality),
                  );
                }).toList(),
                onChanged: (value) {},
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStorageLimitSection() {
    return _buildSection(
      title: 'Limite de stockage',
      icon: FontAwesomeIcons.gauge,
      child: Column(
        children: [
          ListTile(
            title: const Text('Taille maximale'),
            subtitle: Text('$_maxStorageSize MB'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _maxStorageSize =
                          (_maxStorageSize - 100).clamp(100, 10000);
                    });
                  },
                  icon: const FaIcon(FontAwesomeIcons.minus),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _maxStorageSize =
                          (_maxStorageSize + 100).clamp(100, 10000);
                    });
                  },
                  icon: const FaIcon(FontAwesomeIcons.plus),
                ),
              ],
            ),
          ),
          Slider(
            value: _maxStorageSize.toDouble(),
            min: 100,
            max: 10000,
            divisions: 99,
            label: '$_maxStorageSize MB',
            onChanged: (value) {
              setState(() {
                _maxStorageSize = value.round();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCleanupSection() {
    return _buildSection(
      title: 'Nettoyage manuel',
      icon: FontAwesomeIcons.trash,
      child: Column(
        children: [
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.trashCan),
            title: const Text('Vider le cache'),
            subtitle: const Text('Supprimer les fichiers temporaires'),
            onTap: _clearCache,
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.images),
            title: const Text('Supprimer les doublons'),
            subtitle: const Text('Trouver et supprimer les fichiers en double'),
            onTap: _removeDuplicates,
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.download),
            title: const Text('Supprimer les anciens téléchargements'),
            subtitle: const Text('Fichiers de plus de 30 jours'),
            onTap: _removeOldDownloads,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveSettings,
            icon: const FaIcon(FontAwesomeIcons.floppyDisk),
            label: const Text('Sauvegarder'),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _resetSettings,
            icon: const FaIcon(FontAwesomeIcons.arrowRotateLeft),
            label: const Text('Réinitialiser'),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FaIcon(
              icon,
              size: 20.sp,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        child,
      ],
    );
  }

  void _selectStoragePath() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner un dossier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Dossier par défaut'),
              subtitle: const Text('/storage/emulated/0/Snapkeep'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Dossier par défaut sélectionné')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: const Text('Parcourir'),
              subtitle: const Text('Choisir un autre dossier'),
              onTap: () {
                Navigator.pop(context);
                _showFolderPicker();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showFolderPicker() {
    // Simulation d'un sélecteur de dossier
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Parcourir les dossiers'),
        content: const Text(
            'Fonctionnalité de parcours de dossiers à implémenter avec un package comme file_picker.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _createNewFolder() {
    final TextEditingController folderController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer un nouveau dossier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: folderController,
              decoration: const InputDecoration(
                labelText: 'Nom du dossier',
                hintText: 'Ex: Mes Statuts 2024',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Le dossier sera créé dans le répertoire de stockage principal.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (folderController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _performFolderCreation(folderController.text.trim());
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _performFolderCreation(String folderName) {
    // Simulation de la création de dossier
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dossier "$folderName" créé avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vider le cache'),
        content: const Text('Êtes-vous sûr de vouloir vider le cache ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache vidé avec succès')),
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _removeDuplicates() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recherche de doublons en cours...')),
    );
  }

  void _removeOldDownloads() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Suppression des anciens téléchargements...')),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paramètres sauvegardés')),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser les paramètres'),
        content: const Text(
            'Êtes-vous sûr de vouloir réinitialiser tous les paramètres ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _autoCleanup = false;
                _compressImages = false;
                _maxStorageSize = 1000;
                _cleanupDays = 30;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paramètres réinitialisés')),
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}

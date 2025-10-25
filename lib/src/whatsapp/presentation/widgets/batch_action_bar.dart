import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:snapkeep/src/whatsapp/domain/entities/status.dart';
import 'package:snapkeep/src/whatsapp/presentation/cubit/status_cubit.dart';

class BatchActionBar extends StatelessWidget {
  const BatchActionBar({
    super.key,
    required this.selectedItems,
    required this.onClearSelection,
    required this.isStored,
  });

  final List<Status> selectedItems;
  final VoidCallback onClearSelection;
  final bool isStored;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${selectedItems.length} élément(s) sélectionné(s)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              if (!isStored) ...[
                _buildActionButton(
                  context: context,
                  icon: FontAwesomeIcons.download,
                  label: 'Sauvegarder',
                  onPressed: () => _batchSave(context),
                ),
                SizedBox(width: 8.w),
              ],
              _buildActionButton(
                context: context,
                icon: FontAwesomeIcons.shareFromSquare,
                label: 'Partager',
                onPressed: () => _batchShare(context),
              ),
              SizedBox(width: 8.w),
              if (isStored)
                _buildActionButton(
                  context: context,
                  icon: FontAwesomeIcons.trash,
                  label: 'Supprimer',
                  onPressed: () => _batchDelete(context),
                  isDestructive: true,
                ),
              SizedBox(width: 8.w),
              _buildActionButton(
                context: context,
                icon: FontAwesomeIcons.xmark,
                label: 'Annuler',
                onPressed: onClearSelection,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: FaIcon(
        icon,
        size: 16.sp,
        color: isDestructive ? Colors.red : Colors.white,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontSize: 12.sp,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDestructive
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.2),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    );
  }

  void _batchSave(BuildContext context) {
    final cubit = context.read<StatusCubit>();

    for (final status in selectedItems) {
      cubit.store(status: status);
    }

    _showSuccessMessage(
        context, '${selectedItems.length} élément(s) sauvegardé(s)');
    onClearSelection();
  }

  void _batchShare(BuildContext context) {
    if (selectedItems.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Partage multiple'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${selectedItems.length} élément(s) sélectionné(s)'),
            const SizedBox(height: 16),
            const Text('Choisissez une méthode de partage :'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Partager tous'),
              subtitle: const Text('Partager tous les éléments sélectionnés'),
              onTap: () {
                Navigator.pop(context);
                _performBatchShare(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Créer une archive'),
              subtitle:
                  const Text('Créer un fichier ZIP avec tous les éléments'),
              onTap: () {
                Navigator.pop(context);
                _createArchive(context);
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

  void _performBatchShare(BuildContext context) {
    final cubit = context.read<StatusCubit>();

    // Partager chaque élément sélectionné
    for (final status in selectedItems) {
      cubit.share(status: status);
    }

    _showSuccessMessage(
        context, '${selectedItems.length} élément(s) partagé(s)');
    onClearSelection();
  }

  void _createArchive(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Création d\'une archive avec ${selectedItems.length} élément(s)...'),
        backgroundColor: Colors.blue,
      ),
    );
    onClearSelection();
  }

  void _batchDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${selectedItems.length} élément(s) ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performBatchDelete(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _performBatchDelete(BuildContext context) {
    final cubit = context.read<StatusCubit>();

    for (final status in selectedItems) {
      cubit.destroy(path: status.path);
    }

    _showSuccessMessage(
        context, '${selectedItems.length} élément(s) supprimé(s)');
    onClearSelection();
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

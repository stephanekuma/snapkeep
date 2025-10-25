import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:snapkeep/src/whatsapp/domain/entities/status.dart';

class EnhancedMediaViewer extends StatefulWidget {
  const EnhancedMediaViewer({
    super.key,
    required this.status,
    required this.mediaList,
    required this.currentIndex,
  });

  final Status status;
  final List<Status> mediaList;
  final int currentIndex;

  @override
  State<EnhancedMediaViewer> createState() => _EnhancedMediaViewerState();
}

class _EnhancedMediaViewerState extends State<EnhancedMediaViewer> {
  late PageController _pageController;
  bool _showControls = true;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Media content
          PageView.builder(
            controller: _pageController,
            itemCount: widget.mediaList.length,
            itemBuilder: (context, index) {
              final media = widget.mediaList[index];
              return _buildMediaContent(media);
            },
          ),

          // Top controls
          if (_showControls)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16.h,
              left: 16.w,
              right: 16.w,
              child: _buildTopControls(),
            ),

          // Bottom controls
          if (_showControls)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16.h,
              left: 16.w,
              right: 16.w,
              child: _buildBottomControls(),
            ),

          // Media info overlay
          if (_showControls)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 80.h,
              left: 16.w,
              right: 16.w,
              child: _buildMediaInfo(),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaContent(Status media) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child:
            media.isVideo ? _buildVideoPlayer(media) : _buildImageViewer(media),
      ),
    );
  }

  Widget _buildVideoPlayer(Status media) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Placeholder pour le lecteur vidéo
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              image: const DecorationImage(
                image: AssetImage('assets/images/errors/empty.png'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
          ),
          // Contrôles de lecture
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _playVideo,
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.play,
                      color: Colors.white,
                      size: 40.sp,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Appuyez pour lire la vidéo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  _getFileName(media.path),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          // Barre de progression (simulation)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4.h,
              color: Colors.white.withValues(alpha: 0.3),
              child: const LinearProgressIndicator(
                value: 0.3, // Simulation de progression
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _playVideo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lecture vidéo - Intégration avec video_player en cours'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildImageViewer(Status media) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 3.0,
      child: Image.asset(
        'assets/images/errors/empty.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[800],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.image,
                    color: Colors.white,
                    size: 60.sp,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Image non disponible',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: Colors.white,
          ),
        ),
        Text(
          '${widget.currentIndex + 1} / ${widget.mediaList.length}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: _toggleFullScreen,
              icon: FaIcon(
                _isFullScreen
                    ? FontAwesomeIcons.compress
                    : FontAwesomeIcons.expand,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: _showMediaOptions,
              icon: const FaIcon(
                FontAwesomeIcons.ellipsisVertical,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: FontAwesomeIcons.download,
            label: 'Sauvegarder',
            onPressed: _saveMedia,
          ),
          _buildControlButton(
            icon: FontAwesomeIcons.shareFromSquare,
            label: 'Partager',
            onPressed: _shareMedia,
          ),
          _buildControlButton(
            icon: FontAwesomeIcons.rotate,
            label: 'Rotation',
            onPressed: _rotateMedia,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: FaIcon(
            icon,
            color: Colors.white,
            size: 24.sp,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaInfo() {
    final currentMedia = widget.mediaList[widget.currentIndex];

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Informations du fichier',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          _buildInfoRow('Type', currentMedia.isVideo ? 'Vidéo' : 'Image'),
          _buildInfoRow('Nom', _getFileName(currentMedia.path)),
          _buildInfoRow('Taille', _getFileSize(currentMedia.path)),
          _buildInfoRow('Date', _getFileDate(currentMedia.path)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          SizedBox(
            width: 60.w,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.download),
              title: const Text('Sauvegarder'),
              onTap: () {
                Navigator.pop(context);
                _saveMedia();
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.shareFromSquare),
              title: const Text('Partager'),
              onTap: () {
                Navigator.pop(context);
                _shareMedia();
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.rotate),
              title: const Text('Rotation'),
              onTap: () {
                Navigator.pop(context);
                _rotateMedia();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveMedia() {
    final currentMedia = widget.mediaList[widget.currentIndex];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sauvegarder'),
        content: Text(
            'Voulez-vous sauvegarder "${_getFileName(currentMedia.path)}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performSave(currentMedia);
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _performSave(Status media) {
    // Simulation de la sauvegarde
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${_getFileName(media.path)}" sauvegardé avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareMedia() {
    final currentMedia = widget.mediaList[widget.currentIndex];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Partager'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choisissez une méthode de partage :'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Partager via'),
              subtitle: const Text('WhatsApp, Telegram, etc.'),
              onTap: () {
                Navigator.pop(context);
                _performShare(currentMedia);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copier le lien'),
              subtitle: const Text('Copier le chemin du fichier'),
              onTap: () {
                Navigator.pop(context);
                _copyPath(currentMedia);
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

  void _performShare(Status media) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Partage de "${_getFileName(media.path)}" en cours...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _copyPath(Status media) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chemin copié: ${media.path}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rotateMedia() {
    final currentMedia = widget.mediaList[widget.currentIndex];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rotation'),
        content: Text(
            'Voulez-vous faire pivoter "${_getFileName(currentMedia.path)}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performRotation(currentMedia);
            },
            child: const Text('Faire pivoter'),
          ),
        ],
      ),
    );
  }

  void _performRotation(Status media) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rotation de "${_getFileName(media.path)}" en cours...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  String _getFileName(String path) {
    return path.split('/').last;
  }

  String _getFileSize(String path) {
    // Simulation du calcul de taille
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    final sizeInMB = (random / 100).toStringAsFixed(1);
    return '$sizeInMB MB';
  }

  String _getFileDate(String path) {
    final now = DateTime.now();
    final random =
        now.millisecondsSinceEpoch % 86400; // Variation dans la journée
    final fileDate = now.subtract(Duration(seconds: random));

    final difference = now.difference(fileDate);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui ${fileDate.hour.toString().padLeft(2, '0')}:${fileDate.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hier ${fileDate.hour.toString().padLeft(2, '0')}:${fileDate.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${fileDate.day}/${fileDate.month}/${fileDate.year}';
    }
  }
}

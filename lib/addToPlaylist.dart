import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'playingNow.dart';
import 'playlistManager.dart';

class AddToPlaylistScreen extends StatefulWidget {
  final Song song;
  final Function(String playlistId, Song song)? onAddToPlaylist;

  const AddToPlaylistScreen({
    super.key,
    required this.song,
    this.onAddToPlaylist,
  });

  @override
  State<AddToPlaylistScreen> createState() => _AddToPlaylistScreenState();
}

class _AddToPlaylistScreenState extends State<AddToPlaylistScreen> {
  final TextEditingController _playlistNameController = TextEditingController();
  
  final List<IconData> _playlistIcons = [
    Icons.music_note_rounded,
    Icons.favorite_rounded,
    Icons.star_rounded,
    Icons.headphones_rounded,
    Icons.album_rounded,
    Icons.queue_music_rounded,
    Icons.radio_rounded,
    Icons.library_music_rounded,
  ];

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  void _handleAddToPlaylist(String playlistId, String playlistName) {
    widget.onAddToPlaylist?.call(playlistId, widget.song);
    
    if (playlistId == 'favorites') {
      // This will be handled by the favorites screen
    } else {
      final playlistManager = Provider.of<PlaylistManager>(context, listen: false);
      playlistManager.addSongToPlaylist(playlistId, widget.song.id);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${widget.song.title}" to $playlistName'),
        backgroundColor: const Color(0xFF1c995d),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    Navigator.pop(context);
  }

  void _showCreatePlaylistDialog() {
    _playlistNameController.clear();
    final playlistManager = Provider.of<PlaylistManager>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1a1a1a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create New Playlist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _playlistNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Playlist Name',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1c995d), width: 2),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF333333)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_playlistNameController.text.trim().isNotEmpty) {
                          final playlistId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
                          final playlistName = _playlistNameController.text.trim();
                          
                          final icon = _playlistIcons.isEmpty 
                              ? Icons.music_note_rounded 
                              : _playlistIcons[playlistManager.playlists.length % _playlistIcons.length];
                          
                          playlistManager.addPlaylist(PlaylistData(
                            id: playlistId,
                            name: playlistName,
                            icon: icon,
                          ));
                          
                          playlistManager.addSongToPlaylist(playlistId, widget.song.id);
                          
                          Navigator.pop(context);  // Close dialog only
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Created "$playlistName" with "${widget.song.title}"'),
                              backgroundColor: const Color(0xFF1c995d),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1c995d),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text('Create', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistManager>(
      builder: (context, playlistManager, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF000000), Color(0xFF0a0a0a), Color(0xFF000000)],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Add Track To:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _buildDefaultOption(
                          title: 'New Playlist',
                          icon: Icons.add_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1c995d), Color(0xFF0c7248)],
                          ),
                          onTap: _showCreatePlaylistDialog,
                        ),
                        const SizedBox(height: 12),
                        _buildDefaultOption(
                          title: 'Favorite Tracks',
                          icon: Icons.favorite_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1c995d), Color(0xFF0c7248)],
                          ),
                          onTap: () => _handleAddToPlaylist('favorites', 'Favorite Tracks'),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Custom Playlists',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                            decorationThickness: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (playlistManager.playlists.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.queue_music_rounded,
                                    size: 64,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No custom playlists',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...playlistManager.playlists.map((playlist) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildPlaylistOption(playlist),
                          )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a1a),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2a2a2a)),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1a1a),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2a2a2a)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAmpIcon(),
                    const SizedBox(width: 8),
                    const Text(
                      'Amp',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAmpIcon() {
    return CustomPaint(
      size: const Size(20, 20),
      painter: AmpIconPainter(),
    );
  }

  Widget _buildDefaultOption({
    required String title,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2a2a2a), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1c995d).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistOption(PlaylistData playlist) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleAddToPlaylist(playlist.id, playlist.name),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2a2a2a), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1c995d), Color(0xFF0c7248)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1c995d).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(playlist.icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  playlist.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AmpIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1c995d)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 4, size.width - 4, size.height - 8),
      const Radius.circular(2),
    );
    canvas.drawRRect(rect, paint);

    canvas.drawLine(
      Offset(size.width * 0.4, 4),
      Offset(size.width * 0.4, size.height - 4),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.6, 4),
      Offset(size.width * 0.6, size.height - 4),
      paint,
    );

    final knobPaint = Paint()
      ..color = const Color(0xFF1c995d)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.5),
      2,
      knobPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.5),
      2,
      knobPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
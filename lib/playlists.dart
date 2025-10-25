import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'playingNow.dart';
import 'playlistManager.dart';
import 'musicPlayerManager.dart';
import 'playlistDetail.dart'; // Add this import

class PlaylistsScreen extends StatefulWidget {
  final Function(VoidCallback)? onAddPlaylistCallback;

  const PlaylistsScreen({super.key, this.onAddPlaylistCallback});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> with TickerProviderStateMixin {
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
  void initState() {
    super.initState();
    widget.onAddPlaylistCallback?.call(_showCreatePlaylistDialog);
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
                'Create Playlist',
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
                          final icon = _playlistIcons[playlistManager.playlists.length % _playlistIcons.length];
                          
                          playlistManager.addPlaylist(PlaylistData(
                            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                            name: _playlistNameController.text.trim(),
                            icon: icon,
                          ));
                          
                          Navigator.pop(context);
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
                      child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _showPlaylistOptionsDialog(PlaylistData playlist) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1a1a1a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2a2a2a),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF1c995d), width: 2),
                      ),
                      child: Icon(playlist.icon, color: const Color(0xFF41c08b), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        playlist.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF2a2a2a), height: 24),
              _buildDialogOption(
                icon: Icons.edit_rounded,
                label: 'Rename Playlist',
                color: const Color(0xFF41c08b),
                onTap: () {
                  Navigator.pop(context);
                  _showRenamePlaylistDialog(playlist);
                },
              ),
              const SizedBox(height: 8),
              _buildDialogOption(
                icon: Icons.delete_rounded,
                label: 'Delete Playlist',
                color: const Color(0xFFff4444),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog(playlist);
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0a0a0a),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2a2a2a)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRenamePlaylistDialog(PlaylistData playlist) {
    _playlistNameController.text = playlist.name;
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
                'Rename Playlist',
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
                  hintText: 'New Playlist Name',
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
                          playlistManager.renamePlaylist(
                            playlist.id,
                            _playlistNameController.text.trim(),
                          );
                          
                          Navigator.pop(context);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Renamed to "${_playlistNameController.text.trim()}"'),
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
                      child: const Text('Rename', style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _showDeleteConfirmationDialog(PlaylistData playlist) {
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
              const Icon(
                Icons.warning_rounded,
                color: Color(0xFFff4444),
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Playlist?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "${playlist.name}"? This action cannot be undone.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
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
                        playlistManager.removePlaylist(playlist.id);
                        
                        Navigator.pop(context);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Deleted "${playlist.name}"'),
                            backgroundColor: const Color(0xFFff4444),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFff4444),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
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
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black, Colors.black.withOpacity(0.95)],
                        ),
                      ),
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 100, top: 16),
                    children: [
                      _buildSpecialPlaylistCard(
                        title: 'Recently Added',
                        icon: Icons.add_circle_outline_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1c995d), Color(0xFF0c7248)],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSpecialPlaylistCard(
                        title: 'Recently Played',
                        icon: Icons.play_circle_outline_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF41c08b), Color(0xFF1c995d)],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Custom',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF1c995d),
                            decorationThickness: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (playlistManager.playlists.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.queue_music_rounded,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No Custom Playlists',
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
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildCustomPlaylistCard(playlist),
                        )),
                    ],
                  ),
                ),
              ),
              _buildNowPlayingBar(),
            ],
          ),
          // Floating Action Button positioned above the playing now bar
          Consumer<MusicPlayerManager>(
            builder: (context, musicPlayer, child) {
              final bool hasPlayingBar = musicPlayer.currentSong != null;
              
              return Positioned(
                right: 16,
                bottom: hasPlayingBar ? 88 : 16, // 88px when bar is visible (64 + 24)
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1c995d),
                      width: 2,
                    ),
                  ),
                  child: IconButton(
                    onPressed: null, // Functionality removed, awaiting instructions
                    icon: const Icon(
                      Icons.create_new_folder_rounded,
                      color: Color(0xFF1c995d),
                      size: 28,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              );
            },
          ),
        ],
      ),
        );
      },
    );
  }

  Widget _buildSpecialPlaylistCard({
    required String title,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Create a temporary PlaylistData for special playlists
            final specialPlaylist = PlaylistData(
              id: title.toLowerCase().replaceAll(' ', '_'),
              name: title,
              icon: icon,
            );
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaylistDetailScreen(playlist: specialPlaylist),
              ),
            );
          },
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
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomPlaylistCard(PlaylistData playlist) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to playlist detail screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaylistDetailScreen(playlist: playlist),
              ),
            );
          },
          onLongPress: () => _showPlaylistOptionsDialog(playlist),
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
                    color: const Color(0xFF2a2a2a),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFF1c995d), width: 2),
                  ),
                  child: Icon(playlist.icon, color: const Color(0xFF41c08b), size: 28),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNowPlayingBar() {
    return Consumer<MusicPlayerManager>(
      builder: (context, musicPlayer, child) {
        if (musicPlayer.currentSong == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NowPlayingScreen(),
                ),
              );
            },
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1a1a1a).withOpacity(0.95),
                    const Color(0xFF1a1a1a),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: const Color(0xFF1c995d).withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF1c995d).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1c995d), Color(0xFF0c7248)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.album_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                musicPlayer.currentSong!.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                musicPlayer.currentSong!.artist,
                                style: const TextStyle(
                                  color: Color(0xFF41c08b),
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                          iconSize: 26,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => musicPlayer.skipPrevious(),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => musicPlayer.togglePlayPause(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF41c08b), Color(0xFF1c995d)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1c995d).withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              musicPlayer.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                          iconSize: 26,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => musicPlayer.skipNext(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }
}
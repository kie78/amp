// filepath: /home/el/FltrPrctc/amp/lib/playlistDetail.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:ui';
import 'playingNow.dart';
import 'addToPlaylist.dart';
import 'musicPlayerManager.dart';
import 'playlistManager.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final PlaylistData playlist;

  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen>
    with TickerProviderStateMixin {
  // Sample songs - in real app, these would come from playlist.songIds
  List<Song> songs = [
    Song(id: 1, title: 'Midnight Dreams', artist: 'Luna Bay'),
    Song(id: 2, title: 'Electric Soul', artist: 'The Vibes'),
    Song(id: 3, title: 'Neon Lights', artist: 'City Waves'),
    Song(id: 4, title: 'Ocean Drive', artist: 'Summer Nights'),
    Song(id: 5, title: 'Starlight', artist: 'Echo Park'),
  ];

  void _removeSongFromPlaylist(int songId) {
    final playlistManager = Provider.of<PlaylistManager>(context, listen: false);
    playlistManager.removeSongFromPlaylist(widget.playlist.id, songId);
    
    setState(() {
      songs.removeWhere((s) => s.id == songId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Song removed from playlist'),
        backgroundColor: Color(0xFFff4444),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSongOptions(Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1a1a1a),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              song.artist,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildMenuOption(
                    icon: Icons.playlist_add_rounded,
                    label: 'Add to Playlist',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddToPlaylistScreen(song: song),
                        ),
                      );
                    },
                  ),
                  _buildMenuOption(
                    icon: Icons.delete_outline_rounded,
                    label: 'Remove from Playlist',
                    color: const Color(0xFFff4444),
                    onTap: () {
                      Navigator.pop(context);
                      _removeSongFromPlaylist(song.id);
                    },
                  ),
                  _buildMenuOption(
                    icon: Icons.info_outline_rounded,
                    label: 'Song Info',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Row(
            children: [
              Icon(icon, color: color ?? Colors.white, size: 24),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: color ?? Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF000000), Color(0xFF0a0a0a), Color(0xFF000000)],
          ),
        ),
        child: Consumer<MusicPlayerManager>(
          builder: (context, musicPlayer, child) {
            return Column(
              children: [
                _buildAppBar(),
                _buildHeader(),
                Expanded(
                  child: songs.isEmpty ? _buildEmptyState() : _buildSongList(musicPlayer),
                ),
                if (musicPlayer.currentSong != null) _buildBottomPlayer(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.shuffle_rounded, color: Color(0xFF1c995d), size: 28),
              onPressed: () {
                setState(() {
                  songs.shuffle();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Songs shuffled'),
                    duration: Duration(seconds: 1),
                    backgroundColor: Color(0xFF1c995d),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1c995d), Color(0xFF0c7248)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1c995d).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(widget.playlist.icon, color: Colors.white, size: 64),
          ),
          const SizedBox(height: 20),
          Text(
            widget.playlist.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${songs.length} song${songs.length != 1 ? 's' : ''}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note_rounded,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No Songs in This Playlist',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add songs to get started',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongList(MusicPlayerManager musicPlayer) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100, top: 8),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return _buildSongCard(songs[index], musicPlayer);
      },
    );
  }

  Widget _buildSongCard(Song song, MusicPlayerManager musicPlayer) {
    bool isCurrentSong = musicPlayer.currentSong?.id == song.id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => musicPlayer.playSong(song),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrentSong 
                  ? const Color(0xFF1c995d).withOpacity(0.2)
                  : const Color(0xFF1a1a1a),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrentSong 
                    ? const Color(0xFF1c995d)
                    : const Color(0xFF2a2a2a),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1c995d), Color(0xFF0c7248)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isCurrentSong && musicPlayer.isPlaying
                      ? const Visualizer(isPlaying: true)
                      : const Icon(Icons.music_note_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: TextStyle(
                          color: isCurrentSong ? const Color(0xFF41c08b) : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                  onPressed: () => _showSongOptions(song),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPlayer() {
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
}

class Visualizer extends StatefulWidget {
  final bool isPlaying;

  const Visualizer({super.key, required this.isPlaying});

  @override
  State<Visualizer> createState() => _VisualizerState();
}

class _VisualizerState extends State<Visualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _barHeights = [0.3, 0.6, 0.4, 0.8];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying) {
      return const Icon(Icons.music_note_rounded, color: Colors.white, size: 24);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: VisualizerPainter(
            heights: _barHeights.map((h) {
              final random = Random();
              return h + (random.nextDouble() * 0.3 - 0.15);
            }).toList(),
          ),
        );
      },
    );
  }
}

class VisualizerPainter extends CustomPainter {
  final List<double> heights;

  VisualizerPainter({required this.heights});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / 7;
    for (int i = 0; i < 4; i++) {
      final x = barWidth * (i + 1) + (barWidth * i);
      final barHeight = size.height * heights[i];
      final y = (size.height - barHeight) / 2;

      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(VisualizerPainter oldDelegate) => true;
}
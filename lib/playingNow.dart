import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'addToPlaylist.dart';
import 'musicPlayerManager.dart';

class Song {
  final int id;
  final String title;
  final String artist;

  Song({
    required this.id,
    required this.title,
    required this.artist,
  });
}

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({Key? key}) : super(key: key);

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _buttonAnimationController;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  void _animateButton() {
    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });
  }

  String _formatDuration(double seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds.toInt() % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicPlayerManager>(
      builder: (context, musicPlayer, child) {
        if (musicPlayer.currentSong == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                'No song playing',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

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
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! > 500) {
                    Navigator.pop(context);
                  }
                },
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              _buildStatusIndicator(musicPlayer),
                              const SizedBox(height: 16),
                              _buildAlbumArt(),
                              const SizedBox(height: 24),
                              _buildSongInfo(musicPlayer),
                              const SizedBox(height: 12),
                              _buildActionButtons(musicPlayer),
                              const SizedBox(height: 20),
                              _buildProgressBar(musicPlayer),
                              const SizedBox(height: 28),
                              _buildPlaybackControls(musicPlayer),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1a1a1a))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a1a),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2a2a2a)),
            ),
            child: Row(
              children: [
                _buildAmpIcon(),
                const SizedBox(width: 8),
                const Text(
                  'amp',
                  style: TextStyle(
                    color: Color(0xFF1c995d),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
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

  Widget _buildStatusIndicator(MusicPlayerManager musicPlayer) {
    return Text(
      musicPlayer.isPlaying ? 'Playing Now' : 'Paused',
      style: TextStyle(
        color: musicPlayer.isPlaying ? const Color(0xFF1c995d) : Colors.grey,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildAlbumArt() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2a2a2a), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1c995d).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0c7248), Color(0xFF1c995d), Color(0xFF41c08b)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.image_rounded,
                size: 80,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            Positioned(
              top: 30,
              left: 30,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              right: 40,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongInfo(MusicPlayerManager musicPlayer) {
    return Column(
      children: [
        Text(
          musicPlayer.currentSong!.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          musicPlayer.currentSong!.artist,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(MusicPlayerManager musicPlayer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            icon: Icons.shuffle_rounded,
            isActive: musicPlayer.isShuffleOn,
            onTap: () => musicPlayer.toggleShuffle(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _buildActionButton(
              icon: musicPlayer.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              isActive: musicPlayer.isFavorite,
              onTap: () => musicPlayer.toggleFavorite(),
            ),
          ),
          _buildActionButton(
            icon: Icons.add_circle_outline_rounded,
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddToPlaylistScreen(
                    song: musicPlayer.currentSong!,
                    onAddToPlaylist: (playlistId, song) {
                      print('Added ${song.title} to $playlistId');
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1c995d).withOpacity(0.2) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? const Color(0xFF1c995d) : const Color(0xFF2a2a2a),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? const Color(0xFF41c08b) : Colors.grey,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildProgressBar(MusicPlayerManager musicPlayer) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: const Color(0xFF1c995d),
            inactiveTrackColor: const Color(0xFF2a2a2a),
            thumbColor: Colors.white,
            overlayColor: const Color(0xFF1c995d).withOpacity(0.3),
          ),
          child: Slider(
            value: musicPlayer.currentPosition,
            min: 0,
            max: musicPlayer.duration,
            onChanged: (value) => musicPlayer.seek(value),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(musicPlayer.currentPosition),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Text(
                _formatDuration(musicPlayer.duration),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls(MusicPlayerManager musicPlayer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 0.9).animate(
              CurvedAnimation(
                parent: _buttonAnimationController,
                curve: Curves.easeInOut,
              ),
            ),
            child: _buildControlButton(
              icon: Icons.skip_previous_rounded,
              size: 32,
              onTap: () {
                musicPlayer.skipPrevious();
                _animateButton();
              },
            ),
          ),
          _buildPlayPauseButton(musicPlayer),
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 0.9).animate(
              CurvedAnimation(
                parent: _buttonAnimationController,
                curve: Curves.easeInOut,
              ),
            ),
            child: _buildControlButton(
              icon: Icons.skip_next_rounded,
              size: 32,
              onTap: () {
                musicPlayer.skipNext();
                _animateButton();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF2a2a2a), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size,
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton(MusicPlayerManager musicPlayer) {
    return GestureDetector(
      onTap: () => musicPlayer.togglePlayPause(),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0c7248), Color(0xFF1c995d), Color(0xFF41c08b)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1c995d).withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          musicPlayer.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 36,
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
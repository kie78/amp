import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';
import 'dart:ui';
import 'playingNow.dart';
import 'addToPlaylist.dart';
import 'musicPlayerManager.dart';

class FavoritesScreen extends StatefulWidget {
  final Function(VoidCallback)? onShuffleCallback;

  const FavoritesScreen({super.key, this.onShuffleCallback});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  List<Song> songs = [
    Song(id: 1, title: 'Midnight Dreams', artist: 'Luna Bay'),
    Song(id: 2, title: 'Electric Soul', artist: 'The Vibes'),
    Song(id: 3, title: 'Neon Lights', artist: 'City Waves'),
    Song(id: 4, title: 'Ocean Drive', artist: 'Summer Nights'),
    Song(id: 5, title: 'Starlight', artist: 'Echo Park'),
  ];

  @override
  void initState() {
    super.initState();
    widget.onShuffleCallback?.call(_shuffleSongs);
  }

  void _shuffleSongs() {
    setState(() {
      songs.shuffle();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Songs shuffled'),
          duration: Duration(seconds: 1),
          backgroundColor: Color(0xFF1c995d),
        ),
      );
    });
  }

  void _removeSong(int songId) {
    setState(() {
      songs.removeWhere((s) => s.id == songId);
    });
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
                Expanded(
                  child: songs.isEmpty ? _buildEmptyState() : _buildSongList(),
                ),
                if (musicPlayer.currentSong != null) _buildBottomPlayer(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey[800],
          ),
          const SizedBox(height: 16),
          const Text(
            'No favorite tracks',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Songs you love will appear here',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return _buildSongCard(songs[index]);
      },
    );
  }

  Widget _buildSongCard(Song song) {
    return Consumer<MusicPlayerManager>(
      builder: (context, musicPlayer, child) {
        bool isCurrentSong = musicPlayer.currentSong?.id == song.id;

        return InkWell(
          onTap: () {
            musicPlayer.playSong(song);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: const Border(
                bottom: BorderSide(color: Color(0xFF1a1a1a)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0c7248), Color(0xFF1c995d)],
                    ),
                  ),
                  child: const Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 24,
                  ),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (isCurrentSong && musicPlayer.isPlaying)
                      Visualizer(isPlaying: musicPlayer.isPlaying),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      color: const Color(0xFF1a1a1a),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFF2a2a2a)),
                      ),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _removeSong(song.id);
                        } else if (value == 'add') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddToPlaylistScreen(
                                song: song,
                                onAddToPlaylist: (playlistId, selectedSong) {
                                  print('Added ${selectedSong.title} to $playlistId');
                                },
                              ),
                            ),
                          );
                        } else if (value == 'share') {
                          Share.share(
                            'Check out this song: ${song.title} by ${song.artist}',
                            subject: 'Share Song',
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'add',
                          child: Row(
                            children: [
                              Icon(Icons.add, color: Color(0xFF41c08b), size: 18),
                              SizedBox(width: 12),
                              Text(
                                'Add to Playlist',
                                style: TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(Icons.share, color: Color(0xFF41c08b), size: 18),
                              SizedBox(width: 12),
                              Text(
                                'Share',
                                style: TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Color(0xFFff4444), size: 18),
                              SizedBox(width: 12),
                              Text(
                                'Remove from Favorites',
                                style: TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
  final List<double> _heights = [0.3, 0.6, 0.8, 0.5];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(() {
        if (widget.isPlaying) {
          setState(() {
            for (int i = 0; i < _heights.length; i++) {
              _heights[i] = _random.nextDouble() * 0.7 + 0.3;
            }
          });
        }
      });

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(Visualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying) {
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          4,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 4,
            height: _heights[index] * 20,
            decoration: BoxDecoration(
              color: const Color(0xFF1c995d),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
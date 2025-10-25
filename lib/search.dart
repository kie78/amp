import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:ui';
import 'playingNow.dart';
import 'musicPlayerManager.dart';
import 'main.dart' as main_lib;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Song> _searchResults = [];
  
  // All available songs to search from
  final List<Song> _allSongs = [
    Song(id: 1, title: 'Summer Breeze', artist: 'The Waves'),
    Song(id: 2, title: 'Digital Dreams', artist: 'Neon Pulse'),
    Song(id: 3, title: 'Midnight City', artist: 'Urban Echo'),
    Song(id: 4, title: 'Sunset Boulevard', artist: 'Coast Drive'),
    Song(id: 5, title: 'Electric Highway', artist: 'Synth Masters'),
    Song(id: 6, title: 'Crystal Rain', artist: 'Ambient Flow'),
    Song(id: 7, title: 'Golden Hour', artist: 'Luna Sound'),
    Song(id: 8, title: 'Midnight Dreams', artist: 'Luna Bay'),
    Song(id: 9, title: 'Electric Soul', artist: 'The Vibes'),
    Song(id: 10, title: 'Neon Lights', artist: 'City Waves'),
    Song(id: 11, title: 'Ocean Drive', artist: 'Summer Nights'),
    Song(id: 12, title: 'Starlight', artist: 'Echo Park'),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _searchResults = _allSongs.where((song) {
        final titleMatch = song.title.toLowerCase().contains(query);
        final artistMatch = song.artist.toLowerCase().contains(query);
        return titleMatch || artistMatch;
      }).toList();
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
        child: SafeArea(
          child: Consumer<MusicPlayerManager>(
            builder: (context, musicPlayer, child) {
              return Column(
                children: [
                  _buildAppBar(),
                  _buildSearchField(),
                  Expanded(
                    child: _buildSearchResults(),
                  ),
                  if (musicPlayer.currentSong != null) _buildBottomPlayer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
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
                CustomPaint(
                  size: const Size(20, 20),
                  painter: main_lib.AmpIconPainter(),
                ),
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

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search songs or artists...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF1c995d)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1a1a1a),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1c995d), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchController.text.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_rounded,
        title: 'Search for music',
        subtitle: 'Find your favorite songs and artists',
      );
    }

    if (_searchResults.isEmpty) {
      return _buildEmptyState(
        icon: Icons.music_off_rounded,
        title: 'No results found',
        subtitle: 'Try searching with different keywords',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildSongCard(_searchResults[index]);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
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
                        style: TextStyle(
                          color: isCurrentSong ? const Color(0xFF41c08b) : Colors.white,
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
                if (isCurrentSong && musicPlayer.isPlaying)
                  Visualizer(isPlaying: musicPlayer.isPlaying),
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

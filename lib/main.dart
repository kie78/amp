import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'playlists.dart';
import 'favorites.dart';
import 'library.dart';
import 'playlistManager.dart';
import 'musicPlayerManager.dart';

void main() {
  runApp(const MusicPlayerApp());
}

class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlaylistManager()),
        ChangeNotifierProvider(create: (_) => MusicPlayerManager()),
      ],
      child: MaterialApp(
        title: 'Music Player',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          primaryColor: const Color(0xFF1c995d),
        ),
        home: const MainNavigator(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedTab = 1; // Changed from 0 to 1 (Playlists)
  late PageController _pageController;
  VoidCallback? _onAddPlaylist;
  VoidCallback? _onShuffleFavorites;
  VoidCallback? _onShuffleLibrary;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedTab); // Now starts at page 1
    _screens = [
      LibraryScreen(
        onShuffleCallback: (callback) {
          _onShuffleLibrary = callback;
        },
      ),
      PlaylistsScreen(
        onAddPlaylistCallback: (callback) {
          _onAddPlaylist = callback;
        },
      ),
      FavoritesScreen(
        onShuffleCallback: (callback) {
          _onShuffleFavorites = callback;
        },
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildTabBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: _screens,
              ),
            ),
          ],
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
          const Icon(Icons.search, color: Colors.white, size: 24),
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
          // Show appropriate icon based on current tab
          _selectedTab == 0
              ? IconButton(
                  icon: const Icon(Icons.shuffle_rounded, color: Color(0xFF1c995d), size: 28),
                  onPressed: () {
                    _onShuffleLibrary?.call();
                  },
                )
              : _selectedTab == 1
                  ? IconButton(
                      icon: const Icon(Icons.add_rounded, color: Color(0xFF1c995d), size: 28),
                      onPressed: () {
                        _onAddPlaylist?.call();
                      },
                    )
                  : _selectedTab == 2
                      ? IconButton(
                          icon: const Icon(Icons.shuffle_rounded, color: Color(0xFF1c995d), size: 28),
                          onPressed: () {
                            _onShuffleFavorites?.call();
                          },
                        )
                      : const SizedBox(width: 48),
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

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.black.withOpacity(0.95)],
        ),
        border: const Border(bottom: BorderSide(color: Color(0xFF1a1a1a))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTab('Library', 0),
          _buildTab('Playlists', 1),
          _buildTab('Favorites', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: title.length * 8.0,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1c995d) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
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

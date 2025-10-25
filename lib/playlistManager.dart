import 'package:flutter/material.dart';

class PlaylistData {
  final String id;
  final String name;
  final IconData icon;
  final List<int> songIds;

  PlaylistData({
    required this.id,
    required this.name,
    required this.icon,
    this.songIds = const [],
  });

  PlaylistData copyWith({
    String? id,
    String? name,
    IconData? icon,
    List<int>? songIds,
  }) {
    return PlaylistData(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      songIds: songIds ?? this.songIds,
    );
  }
}

class PlaylistManager extends ChangeNotifier {
  final List<PlaylistData> _playlists = [];

  List<PlaylistData> get playlists => _playlists;

  void addPlaylist(PlaylistData playlist) {
    _playlists.add(playlist);
    notifyListeners();
  }

  void removePlaylist(String playlistId) {
    _playlists.removeWhere((p) => p.id == playlistId);
    notifyListeners();
  }

  void renamePlaylist(String playlistId, String newName) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index] = PlaylistData(
        id: _playlists[index].id,
        name: newName,
        icon: _playlists[index].icon,
        songIds: _playlists[index].songIds,
      );
      notifyListeners();
    }
  }

  void addSongToPlaylist(String playlistId, int songId) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final updatedSongIds = List<int>.from(_playlists[index].songIds);
      if (!updatedSongIds.contains(songId)) {
        updatedSongIds.add(songId);

        _playlists[index] = PlaylistData(
          id: _playlists[index].id,
          name: _playlists[index].name,
          icon: _playlists[index].icon,
          songIds: updatedSongIds,
        );
        notifyListeners();
      }
    }
  }

  void removeSongFromPlaylist(String playlistId, int songId) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final updatedSongIds = List<int>.from(_playlists[index].songIds)
        ..remove(songId);

      _playlists[index] = PlaylistData(
        id: _playlists[index].id,
        name: _playlists[index].name,
        icon: _playlists[index].icon,
        songIds: updatedSongIds,
      );
      notifyListeners();
    }
  }
}
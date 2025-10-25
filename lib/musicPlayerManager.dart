import 'package:flutter/material.dart';
import 'dart:async';
import 'playingNow.dart';

class MusicPlayerManager extends ChangeNotifier {
  Song? _currentSong;
  bool _isPlaying = false;
  double _currentPosition = 0.0;
  double _duration = 219.0;
  bool _isFavorite = false;
  bool _isShuffleOn = false;
  Timer? _timer;
  DateTime? _lastSkipPreviousTime;

  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  double get currentPosition => _currentPosition;
  double get duration => _duration;
  bool get isFavorite => _isFavorite;
  bool get isShuffleOn => _isShuffleOn;

  void playSong(Song song, {bool autoPlay = true}) {
    _currentSong = song;
    _currentPosition = 0.0;
    _isPlaying = autoPlay;
    
    if (autoPlay) {
      _startTimer();
    }
    
    notifyListeners();
  }

  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    
    if (_isPlaying) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
    
    notifyListeners();
  }

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffleOn = !_isShuffleOn;
    notifyListeners();
  }

  void skipPrevious() {
    final now = DateTime.now();
    
    if (_lastSkipPreviousTime != null && 
        now.difference(_lastSkipPreviousTime!).inSeconds < 2 ||
        _currentPosition < 3) {
      print('Previous song');
    } else {
      _currentPosition = 0;
      if (_isPlaying) {
        _startTimer();
      }
    }
    
    _lastSkipPreviousTime = now;
    notifyListeners();
  }

  void skipNext() {
    _currentPosition = 0;
    if (_isPlaying) {
      _startTimer();
    }
    print('Next song');
    notifyListeners();
  }

  void seek(double position) {
    _currentPosition = position;
    if (_isPlaying) {
      _startTimer();
    }
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentPosition < _duration) {
        _currentPosition += 1;
        notifyListeners();
      } else {
        timer.cancel();
        _isPlaying = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

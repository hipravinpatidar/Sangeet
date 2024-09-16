import 'package:just_audio/just_audio.dart';
import 'package:sangit/model/sangeet_model.dart';
import 'package:flutter/material.dart';

enum ShuffleMode {
  playNext,
  playOnceAndClose,
  playOnLoop,
}

class AudioPlayerManager extends ChangeNotifier with WidgetsBindingObserver {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Sangeet> _playlist = [];
  int _currentIndex = -1;
  bool _isPlaying = false;
  Sangeet? _currentMusic;
  Duration _duration = Duration.zero;
  Duration _currentPosition = Duration.zero;

  ShuffleMode _shuffleMode = ShuffleMode.playNext;

  // Getters
  bool get isPlaying => _isPlaying;
  int get currentIndex => _currentIndex;
  Sangeet? get currentMusic => _currentMusic;
  Duration get duration => _duration;
  Duration get currentPosition => _currentPosition;
  ShuffleMode get shuffleMode => _shuffleMode;

  // Setters
  void setShuffleMode(ShuffleMode mode) {
    _shuffleMode = mode;
    notifyListeners();
  }

  void setPlaylist(List<Sangeet> playlist) {
    _playlist = playlist;
    _currentIndex = -1;
    notifyListeners();
  }

  Future<void> playMusic(Sangeet music) async {
    try {
      await _audioPlayer.setUrl(music.audio);
      _audioPlayer.play();
      _currentMusic = music;
      _currentIndex = _playlist.indexOf(music);
      _isPlaying = true;

      print("My Songs Length Is ${_playlist.length}");

      _audioPlayer.durationStream.listen((duration) {
        _duration = duration ?? Duration.zero;
        notifyListeners();
      });

      _audioPlayer.positionStream.listen((position) {
        _currentPosition = position;
        notifyListeners();
      });

      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          switch (_shuffleMode) {
            case ShuffleMode.playNext:
              skipNext(); // Automatically skip to next
              break;
            case ShuffleMode.playOnceAndClose:
              pauseMusic();
              break;
            case ShuffleMode.playOnLoop:
              _audioPlayer.seek(Duration.zero);
              _audioPlayer.play();
              break;
          }
        }
      });

      await _updateNotification();
      notifyListeners();
    } catch (error) {
      print('Error playing music: $error');
    }
  }

  void pauseMusic() async {
    _audioPlayer.pause();
    _isPlaying = false;
    await _updateNotification();
    notifyListeners();
  }

  void togglePlayPause() async {
    if (_isPlaying) {
      pauseMusic();
    } else {
      if (_currentMusic != null) {
        _audioPlayer.play();
        _isPlaying = true;
        await _updateNotification();
        notifyListeners();
      }
    }
  }

  void skipNext() {
    if (_currentMusic != null) {
      int currentIndexInPlaylist = _playlist.indexOf(_currentMusic!);

      if (currentIndexInPlaylist < _playlist.length - 1) {
        _currentIndex = currentIndexInPlaylist + 1;
      } else {
        _currentIndex = 0;
      }

      playMusic(_playlist[_currentIndex]);
    }
  }

  void skipPrevious({List<Sangeet>? fixedTabMusicList}) {
    List<Sangeet> playlist = fixedTabMusicList ?? _playlist;

    if (_currentMusic != null) {
      int currentIndexInPlaylist = playlist.indexOf(_currentMusic!);

      if (currentIndexInPlaylist > 0) {
        _currentIndex = currentIndexInPlaylist - 1;
      } else {
        _currentIndex = playlist.length - 1;
      }

      playMusic(playlist[_currentIndex]);
    }
  }

  void seekTo(Duration position) {
    _audioPlayer.seek(position);
    _currentPosition = position;
    notifyListeners();
  }

  Future<void> _updateNotification() async {
    // Add code for updating the notification with current music info
  }
}

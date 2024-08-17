import 'package:audio_service/audio_service.dart';
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
      _isPlaying = true;
      _currentIndex = _playlist.indexOf(music);

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
              skipNext();
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
    if (_currentIndex + 1 < _playlist.length) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
    playMusic(_playlist[_currentIndex]);
  }

  void skipPrevious() {
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = _playlist.length - 1;
    }
    playMusic(_playlist[_currentIndex]);
  }

  void seekTo(Duration position) {
    _audioPlayer.seek(position);
    _currentPosition = position;
    notifyListeners();
  }

  Future<void> _updateNotification() async {
    if (_currentMusic != null) {
      await AudioServiceBackground.setMediaItem(
        MediaItem(
          id: _currentMusic!.id.toString(),
          album: _currentMusic!.image ?? '',
          title: _currentMusic!.title,
          artist: _currentMusic!.singerName,
          duration: _duration,
        ),
      );
    }

    await AudioServiceBackground.setState(
      controls: [
        MediaControl.skipToPrevious,
        _isPlaying ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const [
        MediaAction.seek,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
      ],
      playing: _isPlaying,
      processingState: AudioProcessingState.ready,
      position: _currentPosition,
    );
  }


  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}


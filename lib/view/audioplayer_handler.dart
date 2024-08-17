import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sangit/controller/audio_manager.dart';

class AudioPlayerHandler extends BaseAudioHandler {
  final AudioPlayerManager _audioPlayerManager = AudioPlayerManager();

  @override
  Future<void> play() async {
    _audioPlayerManager.togglePlayPause();
  }

  @override
  Future<void> pause() async {
    _audioPlayerManager.togglePlayPause();
  }

  @override
  Future<void> skipToNext() async {
    _audioPlayerManager.skipNext();
  }

  @override
  Future<void> skipToPrevious() async {
    _audioPlayerManager.skipPrevious();
  }

  @override
  Future<void> seek(Duration position) async {
    _audioPlayerManager.seekTo(position);
  }

// Add other overrides as needed for your background task
}

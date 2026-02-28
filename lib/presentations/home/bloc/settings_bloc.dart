import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkbattle_frontend/utils/preferences/local_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

// ---------------- EVENTS ----------------
abstract class SettingsEvent {}

class SettingsInitialEvent extends SettingsEvent {}

class UpdateSoundValue extends SettingsEvent {
  final double value;
  UpdateSoundValue(this.value);
}

// ---------------- STATE ----------------
class SettingsState {
  final double soundValue;

  SettingsState({required this.soundValue});

  SettingsState copyWith({double? soundValue}) {
    return SettingsState(
      soundValue: soundValue ?? this.soundValue,
    );
  }
}

// ---------------- BLOC ----------------
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {

  // Shared player ONLY for preview volume
  final AudioPlayer audioPlayer = AudioPlayer();

  SettingsBloc() : super(SettingsState(soundValue: 1.0)) {
    on<SettingsInitialEvent>(_onSettingsInitial);
    on<UpdateSoundValue>(_onUpdateSoundValue);
  }

  // MUST return Future<void>
  Future<void> _onSettingsInitial(
      SettingsInitialEvent event,
      Emitter<SettingsState> emit,
      ) async {

    final vol = await LocalStorageUtils.getVolume();

    await audioPlayer.setVolume(vol);

    emit(state.copyWith(soundValue: vol));
  }

  // Proper async handler
  Future<void> _onUpdateSoundValue(
      UpdateSoundValue event,
      Emitter<SettingsState> emit,
      ) async {

    final newVolume = event.value.clamp(0.0, 1.0);

    // Save locally FIRST
    await LocalStorageUtils.setVolume(newVolume);

    //  Update preview player
    await audioPlayer.setVolume(newVolume);

    // Update UI LAST
    emit(state.copyWith(soundValue: newVolume));
  }

  @override
  Future<void> close() {
    audioPlayer.dispose();
    return super.close();
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkbattle_frontend/utils/preferences/local_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
abstract class SettingsEvent {}

class SettingsInitialEvent extends SettingsEvent {}

class UpdateSoundValue extends SettingsEvent {
  final double value;
  UpdateSoundValue(this.value);
}

class SettingsState {
  final double soundValue;

  SettingsState({required this.soundValue});

  SettingsState copyWith({double? soundValue}) {
    return SettingsState(
      soundValue: soundValue ?? this.soundValue,
    );
  }
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final AudioPlayer audioPlayer = AudioPlayer();
  SettingsBloc() : super(SettingsState(soundValue: 0.4)) {
    on<SettingsInitialEvent>(_onSettingsInitial);
    on<UpdateSoundValue>(_onUpdateSoundValue);
  }

  void _onSettingsInitial(
      SettingsInitialEvent event, Emitter<SettingsState> emit) async{
        final vol = await LocalStorageUtils.getVolume();
        audioPlayer.setVolume(vol);
    emit(SettingsState(soundValue: vol));
  }

  void _onUpdateSoundValue(
      UpdateSoundValue event, Emitter<SettingsState> emit) {
    emit(state.copyWith(soundValue: event.value));
    LocalStorageUtils.setVolume(event.value);
    audioPlayer.setVolume(event.value);
  }
}

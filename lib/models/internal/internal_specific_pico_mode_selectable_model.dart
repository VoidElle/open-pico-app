import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_pico_app/utils/enums/pico_state_enum.dart';

part 'generated/internal_specific_pico_mode_selectable_model.freezed.dart';

@freezed
abstract class InternalSpecificPicoModeSelectableModel with _$InternalSpecificPicoModeSelectableModel {

  const factory InternalSpecificPicoModeSelectableModel({

    required IconData icon,
    required PicoStateEnum picoStateEnum,
    required String text,

    @Default(false)
    bool selected,

  }) = _InternalSpecificPicoModeSelectableModel;

}
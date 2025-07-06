import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/internal_grid_icon_label_cta_model.freezed.dart';

@freezed
abstract class InternalGridIconLabelCtaModel with _$InternalGridIconLabelCtaModel {

  const factory InternalGridIconLabelCtaModel({
    required String text,
    required IconData iconData,
    required VoidCallback onTap,
  }) = _InternalGridIconLabelCtaModel;

}
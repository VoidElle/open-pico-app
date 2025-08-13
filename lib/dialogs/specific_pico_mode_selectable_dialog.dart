import 'package:flutter/material.dart';

import '../models/internal/internal_specific_pico_mode_selectable_model.dart';

class SpecificPicoModeSelectableDialog extends StatelessWidget {

  const SpecificPicoModeSelectableDialog({
    required this.internalSpecificPicoModeSelectableModelList,
    super.key,
  });

  final List<InternalSpecificPicoModeSelectableModel> internalSpecificPicoModeSelectableModelList;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          const Text(
            'Seleziona una modalitá specifica',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(
            height: 16,
          ),

          Row(
            children: internalSpecificPicoModeSelectableModelList
                .map((internalSpecificPicoModeSelectableModel) => _buildSingleItem(context, internalSpecificPicoModeSelectableModel))
                .toList(),
          ),

        ],
      ),
    );
  }

  Widget _buildSingleItem(BuildContext context, InternalSpecificPicoModeSelectableModel internalSpecificPicoModeSelectableModel) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
        ),
        decoration: BoxDecoration(
          border: internalSpecificPicoModeSelectableModel.selected
              ? Border.all(
            color: Colors.black,
            width: 2,
          )
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: GestureDetector(
          onTapUp: (TapUpDetails _) => Navigator.of(context).pop(internalSpecificPicoModeSelectableModel.picoStateEnum),
          child: Column(
            children: [
              Icon(
                internalSpecificPicoModeSelectableModel.icon,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                internalSpecificPicoModeSelectableModel.text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

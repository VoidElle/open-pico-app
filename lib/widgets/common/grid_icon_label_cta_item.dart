import 'package:flutter/material.dart';

import '../../models/internal/internal_grid_icon_label_cta_model.dart';

class GridIconLabelCtaItem extends StatelessWidget {

  const GridIconLabelCtaItem({
    Key? key,
    required this.internalGridIconLabelCtaModel,
    required this.isDeviceOn,
  }) : super(key: key);

  final InternalGridIconLabelCtaModel internalGridIconLabelCtaModel;
  final bool isDeviceOn;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDeviceOn || internalGridIconLabelCtaModel.isOnOffCta
          ? internalGridIconLabelCtaModel.onTap
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: internalGridIconLabelCtaModel.selected
              ? Border.all(
                  color: internalGridIconLabelCtaModel.borderColor,
                  width: 2,
                )
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              internalGridIconLabelCtaModel.iconData,
              size: 36,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              internalGridIconLabelCtaModel.text,
              textAlign: TextAlign.center,
            ),

          ],
        ),
      ),
    );
  }
}
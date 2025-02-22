import 'package:flutter/material.dart';
import 'package:fitapp/components/theme/color_lib.dart';

class EmoticonFace extends StatelessWidget {

  final String emoticonFace;

  const EmoticonFace({
    Key? key,
    required this.emoticonFace,
}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.appColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Text(
          emoticonFace,
            style: const TextStyle(
              fontSize: 28,
        ),
        ),
      ),
    );
  }
}

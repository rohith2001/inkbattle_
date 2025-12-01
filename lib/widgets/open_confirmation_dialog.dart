import 'package:flutter/material.dart';
import 'package:inkbattle_frontend/constants/app_colors.dart';
import 'package:inkbattle_frontend/widgets/text_widget.dart';

void openConfirmationDialog({
  required context,
  required title,
  required message,
  required color,
  required positiveButtonText,
  required negativeButtonText,
  required onPositiveButtonClick,
  required onNegativeButtonClick,
}) {
  var alertDialog = ConfirmationDialog(
    context: context,
    title: title,
    message: message,
    color: color,
    positiveButtonText: positiveButtonText,
    negativeButtonText: negativeButtonText,
    onPositiveButtonClick: onPositiveButtonClick,
    onNegativeButtonClick: onNegativeButtonClick,
  );
  showDialog(context: context, builder: (context) => alertDialog);
}

class ConfirmationDialog extends StatefulWidget {
  const ConfirmationDialog({
    super.key,
    required this.context,
    required this.title,
    required this.message,
    this.color,
    required this.positiveButtonText,
    required this.negativeButtonText,
    required this.onPositiveButtonClick,
    required this.onNegativeButtonClick,
  });

  final BuildContext context;
  final String title;
  final String message;
  final Color? color;
  final String positiveButtonText;
  final String negativeButtonText;
  final Function onPositiveButtonClick;
  final Function onNegativeButtonClick;

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      backgroundColor: AppColors.backgroundLight,
      elevation: 16,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextWidget(
              text: widget.title,
              fontWeight: FontWeight.bold,
              color: AppColors.whiteColor,
              fontSize: 17,
            ),
            const SizedBox(height: 10),
            TextWidget(
              text: widget.message,
              fontSize: 14,
              color: AppColors.whiteColor,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    widget.onNegativeButtonClick();
                    Navigator.pop(context);
                    FocusNode().unfocus();
                  },
                  child: Container(
                    width: 70,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: TextWidget(
                        text: widget.negativeButtonText,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    widget.onPositiveButtonClick();
                    Navigator.pop(context);
                    FocusNode().unfocus();
                  },
                  child: Container(
                    width: 100,
                    height: 35,
                    decoration: BoxDecoration(
                      color: widget.color ?? Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: TextWidget(
                        text: widget.positiveButtonText,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

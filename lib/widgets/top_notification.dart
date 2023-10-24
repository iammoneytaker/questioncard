import 'package:flutter/material.dart';

enum NotificationType { success, fail }

class TopNotification extends StatelessWidget {
  final NotificationType type;
  final String message;

  const TopNotification({super.key, required this.type, required this.message});

  Color _getBackgroundColor() {
    switch (type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.fail:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: _getBackgroundColor(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == NotificationType.success ? Icons.check : Icons.error,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

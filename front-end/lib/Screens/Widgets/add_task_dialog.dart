import 'package:flutter/material.dart';

Future<void> showAddOrEditDialog({
  required BuildContext context,
  required TextEditingController taskController,
  required String title,
  required VoidCallback onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: taskController,
            decoration: const InputDecoration(labelText: "Enter the task"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (taskController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please enter task")),
              );
            } else {
              onConfirm();
              Navigator.pop(context);
            }
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fitapp/database/exercise.dart';

class CreateExerciseWidget extends StatefulWidget {
  final Exercise? exercise;
  final ValueChanged<String> onSubmit;

  const CreateExerciseWidget({
    Key? key,
    this.exercise,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<CreateExerciseWidget> createState() => _CreateExerciseWidgetState();
}

class _CreateExerciseWidgetState extends State<CreateExerciseWidget> {
  final nameController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.exercise?.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.exercise != null;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.transparent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    isEditing ? 'Edit Exercise' : 'Add Exercise',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                ),
                SizedBox(height: 20),
                Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        autofocus: true,
                        controller: nameController,
                        decoration: const InputDecoration(
                            hintText: 'Name',
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          )
                        ),
                        validator: (value) =>
                        value != null && value.isEmpty ? 'Name is required' : null,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white),),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          widget.onSubmit(nameController.text);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('OK', style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

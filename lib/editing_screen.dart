import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memo/note.dart';

import 'package:memo/notes_provider.dart';

class EditingScreen extends ConsumerStatefulWidget {
  final Note? note;
  const EditingScreen({
    this.note,
    super.key,
  });

  @override
  ConsumerState<EditingScreen> createState() => _EditingScreenState();
}

class _EditingScreenState extends ConsumerState<EditingScreen> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController dateController;
  String noteText = "";
  DateTime? date;
  bool pickDate = false;

  @override
  void initState() {
    super.initState();
    date = widget.note?.dateTime;
    pickDate = (widget.note?.dateTime != null);
    dateController = TextEditingController(
        text: (widget.note == null || widget.note!.dateTime == null)
            ? null
            : DateFormat.yMd().format(widget.note!.dateTime!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              SizedBox(
                height: 400,
                child: TextFormField(
                  // controller: controller,
                  initialValue: widget.note?.text,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    filled: true,
                    label: Text("Note text"),
                    hintText: "text goes here",
                  ),
                  onSaved: (newValue) {
                    noteText = newValue!;
                  },
                  validator: (value) {
                    if (value == null || value == "") {
                      return "Note text can not be empty";
                    }
                    return null;
                  },
                ),
              ),
              Checkbox(
                value: pickDate,
                onChanged: (value) {
                  setState(() {
                    pickDate = value!;
                  });
                },
              ),
              if (pickDate)
                TextFormField(
                  controller: dateController,
                  // initialValue:
                  //     date == null ? null : DateFormat.yMd().format(date!),
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2100),
                    ).then((value) {
                      date = value;
                      dateController.text = DateFormat.yMd().format(date!);
                    });
                  },
                  readOnly: true,
                  decoration: const InputDecoration(
                    filled: true,
                    label: Text("Date"),
                    hintText: "Pick date",
                  ),
                  validator: (value) {
                    if (pickDate && date == null) {
                      return "Pick a date!";
                    }
                    return null;
                  },
                ),
              const SizedBox(
                height: 10,
              ),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  formKey.currentState!.save();
                  final notesNotifier = ref.read(notesProvider.notifier);
                  if (widget.note != null) {
                    notesNotifier.remove(widget.note!);
                  }
                  notesNotifier.add(Note(
                    noteText,
                    id: widget.note?.id,
                    dateTime: pickDate ? date : null,
                  ));
                  Navigator.of(context).pop();
                },
                child: Text("Save note"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

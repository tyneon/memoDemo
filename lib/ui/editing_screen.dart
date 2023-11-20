import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:memo/helpers.dart';
import 'package:memo/src/note.dart';
import 'package:memo/src/notes_provider.dart';

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
  late TextEditingController timeController;
  String noteText = "";
  DateTime? dateTime;
  bool pickDate = false;
  bool pickTime = false;

  @override
  void initState() {
    super.initState();
    dateTime = widget.note?.dateTime;
    pickDate = (widget.note?.dateTime != null);
    pickTime = widget.note?.timed ?? false;
    dateController = TextEditingController(
      text: (widget.note == null || widget.note!.dateTime == null)
          ? null
          : DateFormat.yMd().format(widget.note!.dateTime!),
    );
    timeController = TextEditingController(
      text: (widget.note == null || widget.note!.dateTime == null)
          ? null
          : DateFormat.Hm().format(widget.note!.dateTime!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controls = <Widget>[
      Row(
        children: [
          Checkbox(
            value: pickDate,
            onChanged: (value) {
              setState(() {
                pickDate = value!;
              });
            },
          ),
          if (!pickDate || !wideModeActive(context)) const Text("Include date"),
        ],
      ),
      if (pickDate) ...[
        SizedBox(
          width: wideModeActive(context) ? 100 : null,
          child: TextFormField(
            controller: dateController,
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2023),
                lastDate: DateTime(2100),
              ).then((value) {
                if (value == null) return;
                setState(() {
                  dateTime = DateTime(
                    value.year,
                    value.month,
                    value.day,
                    dateTime?.hour ?? DateTime.now().hour,
                    dateTime?.minute ?? DateTime.now().minute,
                  );
                  dateController.text = DateFormat.yMd().format(dateTime!);
                  timeController.text = DateFormat.Hm().format(dateTime!);
                });
              });
            },
            readOnly: true,
            decoration: const InputDecoration(
              filled: true,
              label: Text("Date"),
              hintText: "Pick date",
            ),
            validator: (value) {
              if (pickDate && dateTime == null) {
                return "Pick a date!";
              }
              return null;
            },
          ),
        ),
        Row(
          children: [
            Checkbox.adaptive(
              value: pickTime,
              onChanged: (value) {
                setState(() {
                  pickTime = value!;
                });
              },
            ),
            if (!pickTime || !wideModeActive(context))
              const Text("Include time"),
          ],
        ),
        if (pickTime)
          SizedBox(
            width: wideModeActive(context) ? 100 : null,
            child: TextFormField(
              controller: timeController,
              enabled: dateTime != null,
              onTap: () {
                if (dateTime == null) return;
                showTimePicker(
                        context: context,
                        initialTime:
                            TimeOfDay.fromDateTime(dateTime ?? DateTime.now()))
                    .then((value) {
                  if (value == null || dateTime == null) return;
                  dateTime = DateTime(
                    dateTime!.year,
                    dateTime!.month,
                    dateTime!.day,
                    value.hour,
                    value.minute,
                  );
                  timeController.text = DateFormat.Hm().format(dateTime!);
                });
              },
              readOnly: true,
              decoration: const InputDecoration(
                filled: true,
                label: Text("Time"),
                hintText: "Pick time",
              ),
              validator: (value) {
                if (pickDate && pickTime && dateTime == null) {
                  return "Pick a time!";
                }
                return null;
              },
            ),
          ),
      ],
      const SizedBox(
        height: 10,
      ),
      if (wideModeActive(context)) Expanded(child: Container()),
      Padding(
        padding: wideModeActive(context)
            ? const EdgeInsets.symmetric(horizontal: 10)
            : const EdgeInsets.all(0),
        child: FilledButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) {
              return;
            }
            formKey.currentState!.save();
            final notesNotifier = ref.read(notesProvider.notifier);
            if (widget.note != null) {
              notesNotifier.replace(
                widget.note!.id,
                noteText,
                pickDate ? dateTime : null,
                pickTime,
              );
            } else {
              notesNotifier.add(
                noteText,
                pickDate ? dateTime : null,
                pickTime,
              );
            }
            Navigator.of(context).pop();
          },
          child: const Text("Save note"),
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height > 600 ? 400 : 100,
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
              if (wideModeActive(context))
                Container(
                  padding: const EdgeInsets.only(top: 20),
                  height: 80,
                  child: Row(
                    children: controls,
                  ),
                )
              else
                ...controls,
            ],
          ),
        ),
      ),
    );
  }
}

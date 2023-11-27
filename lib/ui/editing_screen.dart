import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:memo/helpers.dart';
import 'package:memo/src/location.dart';
import 'package:memo/src/location_provider.dart';
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
  late TextEditingController locationController;
  String noteText = "";
  DateTime? dateTime;
  Location? location;
  bool pickDate = false;
  bool pickTime = false;
  bool pickLocation = false;

  @override
  void initState() {
    super.initState();
    dateTime = widget.note?.dateTime;
    location = widget.note?.location;

    pickDate = (dateTime != null);
    pickTime = widget.note?.timed ?? false;
    pickLocation = (location != null);

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
    locationController = TextEditingController(
        text: (widget.note == null || widget.note!.location == null)
            ? null
            : widget.note!.location!.toString());
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
      Row(
        children: [
          Checkbox.adaptive(
            value: pickLocation,
            onChanged: (value) {
              setState(() {
                pickLocation = value!;
                location = pickLocation ? dummyLocation : null; // TODO change
              });
            },
          ),
          const Text("Include location"),
        ],
      ),
      if (pickLocation)
        Row(
          children: [
            SizedBox(
              width: wideModeActive(context)
                  ? 100
                  : MediaQuery.of(context).size.width - 100,
              child: TextFormField(
                // initialValue: widget.note?.location?.address,
                controller: locationController,
                decoration: const InputDecoration(
                  filled: true,
                  label: Text("Location"),
                  hintText: "Search location",
                ),
                validator: (value) {
                  if (pickLocation && value == "") {
                    return "Enter location!";
                  }
                  return null;
                },
                onSaved: (value) {
                  // location = ???
                },
              ),
            ),
            FilledButton.icon(
              onPressed: () async {
                location = await showDialog<Location?>(
                  context: context,
                  builder: (context) =>
                      LocationSearchResults(locationController.text),
                );
                if (location != null) {
                  locationController.text = location.toString();
                }
              },
              label: Container(),
              icon: const Icon(Icons.pin_drop_outlined),
            )
          ],
        ),
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
                pickLocation ? location : null,
              );
            } else {
              notesNotifier.add(
                noteText,
                pickDate ? dateTime : null,
                pickTime,
                pickLocation ? location : null,
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

class LocationSearchResults extends ConsumerWidget {
  final String query;
  const LocationSearchResults(this.query, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsyncValue = ref.watch(locationProvider(query));
    List<Location> locations = [];
    if (locationAsyncValue.hasValue) {
      try {
        final results = jsonDecode(locationAsyncValue.value!.body)['results']
            as List<dynamic>;
        locations = results
            .map((item) => Location(
                  lat: item['geometry']['lat'],
                  lon: item['geometry']['lng'],
                  address: item['formatted'],
                ))
            .toList();
      } catch (e) {
        print(e);
      }
    }
    return Dialog(
      child: locationAsyncValue.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: locations
                  .map(
                    (location) => ListTile(
                      onTap: () {
                        Navigator.of(context).pop<Location?>(location);
                      },
                      title: Text(
                        location.address ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text("${location.lat}, ${location.lon}"),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

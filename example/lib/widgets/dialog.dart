import 'dart:typed_data';

import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:ditto_live/ditto_live.dart';
import 'package:flutter/material.dart';

import '../image.dart';
import '../models/task.dart';

Future<(Task, AttachmentToken)?> showAddTaskDialog(
  BuildContext context,
  Ditto ditto,
) =>
    showDialog(
      context: context,
      builder: (context) => _Dialog(ditto),
    );

class _Dialog extends StatefulWidget {
  final Ditto ditto;
  const _Dialog(this.ditto);

  @override
  State<_Dialog> createState() => _DialogState();
}

class _DialogState extends State<_Dialog> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  var _done = false;
  Uint8List? _imageBytes;
  BlurHash? _hash;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final (bytes, hash) = await loadImageAndBlurhash();
    setState(() {
      _imageBytes = bytes;
      _hash = hash;
    });
  }

  Future<void> _onSave() async {
    try {

    final imageBytes = _imageBytes;

    if (imageBytes == null) return;

    final attachment = widget.ditto.store.newAttachment(
      _imageBytes!,
      AttachmentMetadata({
        "blurhash": _hash!.hash,
      }),
    );
    final token = attachment.token;

    final task = Task(
      title: _name.text,
      description: _description.text,
      done: _done,
      deleted: false,
    );

    if (mounted) Navigator.of(context).pop((task, token));
    } catch (e, trace) {
      print(e);
      print(trace);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        icon: const Icon(Icons.add_task),
        title: const Text("Add Task"),
        contentPadding: EdgeInsets.zero,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _textInput(_name, "Name"),
            _textInput(_description, "Description"),
            _doneSwitch,
            _image,
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            onPressed: _imageBytes == null ? null : _onSave,
            child: const Text("Add Task"),
          ),
        ],
      );

  Widget _textInput(TextEditingController controller, String label) => ListTile(
        title: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
          ),
        ),
      );

  Widget get _doneSwitch => SwitchListTile(
        title: const Text("Done"),
        value: _done,
        onChanged: (value) => setState(() => _done = value),
      );

  Widget get _image => _imageBytes == null
      ? Container()
      : Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.memory(_imageBytes!),
          ),
        );
}

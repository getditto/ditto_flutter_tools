import 'package:ditto_live/ditto_live.dart';
import 'package:flutter/material.dart';

import 'attachment_view.dart';
import '../models/task.dart';

class TaskView extends StatelessWidget {
  final Ditto ditto;
  final Task task;
  final Map<String, dynamic>? token;

  const TaskView({
    super.key,
    required this.ditto,
    required this.task,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final tok = token;

    return ListTile(
      title: Text(task.title),
      subtitle: Text(task.description),
      trailing: Checkbox(
        value: task.done,
        onChanged: (value) => ditto.store.execute(
          "UPDATE tasks SET done = $value WHERE _id = '${task.id}'",
        ),
      ),
      leading: tok == null
          ? null
          : SizedBox(
              width: 50,
              height: 50,
              child: AttachmentView(
                ditto: ditto,
                attachmentToken: tok,
              ),
            ),
    );
  }
}

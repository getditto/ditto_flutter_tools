import 'dart:typed_data';

import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:ditto_live/ditto_live.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class AttachmentView extends StatefulWidget {
  final Ditto ditto;
  final Map<String, dynamic> attachmentToken;

  const AttachmentView({
    super.key,
    required this.ditto,
    required this.attachmentToken,
  });

  @override
  State<AttachmentView> createState() => _AttachmentViewState();
}

class _AttachmentViewState extends State<AttachmentView> {
  late final _token = AttachmentToken.fromJson(widget.attachmentToken);
  late final String? _blurhash = _token.metadata.metadata["blurhash"];

  Uint8List? _bytes;
  double _progress = 0;

  @override
  void initState() {
    super.initState();

    widget.ditto.store.fetchAttachment(
      widget.attachmentToken,
      (event) => switch (event) {
        AttachmentFetchEventProgress progress => setState(() {
            _progress = progress.downloadedBytes / progress.totalBytes;
          }),
        AttachmentFetchEventCompleted completed =>
          _complete(completed.attachment),
        AttachmentFetchEventDeleted _ => print("deleted"),
        _ => throw Exception("Unknown event type"),
      },
    );
  }

  Future<void> _complete(Attachment attachment) async {
    final bytes = await attachment.data;
    // artificial delay to show blurhash
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _bytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;

    if (bytes == null) {
      final blurhash = _blurhash;
      if (blurhash == null) return CircularProgressIndicator(value: _progress);
      final image = BlurHash.decode(blurhash).toImage(35, 20);
      return Image.memory(Uint8List.fromList(img.encodeJpg(image)));
    }
    return Image.memory(bytes);
  }
}

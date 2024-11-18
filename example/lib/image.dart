import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:image/image.dart' as img;

// Random image service
final _uri = Uri.parse("https://picsum.photos/1000/1500");
final _fallbackUri = Uri.parse(
    "https://fakeimg.pl/440x230/282828/eae0d0/?retina=1&text=Rate-limited?%20%3C%3Apepw%3A989410572514758676%3E");

Future<(Uint8List, BlurHash)> loadImageAndBlurhash() async {
  final imageBytes = await _loadRandomImage();
  final image = await compute(img.decodeImage, imageBytes);
  final hash = await compute(BlurHash.encode, image!);

  return (imageBytes, hash);
}

Future<Uint8List> _loadRandomImage() async {
  final image = await get(_uri);
  if (image.statusCode == 200) {
    return image.bodyBytes;
  }

  return (await get(_fallbackUri)).bodyBytes;
}

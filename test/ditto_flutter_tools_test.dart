import 'package:ditto_flutter_tools/src/util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("formats bytes correctly", () {
    expect(humanReadableBytes(500), "500 B");
    expect(humanReadableBytes(1500), "1 KB");
    expect(humanReadableBytes(15000), "15 KB");
    expect(humanReadableBytes(15 * 1000 * 1000), "15 MB");
    expect(humanReadableBytes(1000 * 1000 * 1000 * 1000), "1000 GB");
  });
}

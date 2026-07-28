import 'package:ditto_flutter_tools/src/util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("formats bytes correctly", () {
    expect(humanReadableBytes(500), "500 B");
    expect(humanReadableBytes(999), "999 B");
    expect(humanReadableBytes(1000), "1 KB");
    expect(humanReadableBytes(1500), "1 KB");
    expect(humanReadableBytes(15000), "15 KB");
    expect(humanReadableBytes(999000), "999 KB");
    expect(humanReadableBytes(1000000), "1 MB");
    expect(humanReadableBytes(15 * 1000 * 1000), "15 MB");
    expect(humanReadableBytes(999000000), "999 MB");
    expect(humanReadableBytes(1000000000), "1 GB");
    expect(humanReadableBytes(1000 * 1000 * 1000 * 1000), "1000 GB");
  });
}

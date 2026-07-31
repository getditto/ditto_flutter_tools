String humanReadableBytes(int bytes) => switch (bytes) {
      < 1000 => "$bytes B",
      < 1000 * 1000 => "${bytes ~/ 1000} KB",
      < 1000 * 1000 * 1000 => "${bytes ~/ (1000 * 1000)} MB",
      _ => "${bytes ~/ (1000 * 1000 * 1000)} GB",
    };

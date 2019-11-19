import 'package:flutter/services.dart' show rootBundle;

List<Fortune> _cache;

Future<List<Fortune>> loadFortunes() async {
  if (_cache != null) {
    return _cache;
  }
  final contents =
      await rootBundle.loadString('assets/fortunes/fortunes', cache: false);

  final results = <Fortune>[];
  var current = <String>[];

  // Finalize fortune.
  void finalize() {
    if (current.isEmpty) return;
    results.add(Fortune(List.from(current)));
    current.clear();
  }

  for (final rawLine in contents.split('\n')) {
    final line = rawLine.trimRight().replaceAll('\t', '    ');
    if (line == '%') {
      finalize();
      continue;
    }
    current.add(line);
  }
  finalize();
  return results;
}

class Fortune {
  final List<String> lines;

  const Fortune(this.lines) : assert(lines != null);
}

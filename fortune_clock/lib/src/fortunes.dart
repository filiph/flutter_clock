import 'package:flutter/services.dart' show rootBundle;

List<Fortune>? _cache;

const maxLines = 5;

Future<List<Fortune>> loadFortunes() async {
  if (_cache != null) {
    return _cache!;
  }

  final assets = <Future<String>>[
    rootBundle.loadString('assets/fortunes/computers', cache: false),
    rootBundle.loadString('assets/fortunes/fortunes', cache: false),
    rootBundle.loadString('assets/fortunes/miscellaneous', cache: false),
    rootBundle.loadString('assets/fortunes/people', cache: false),
    rootBundle.loadString('assets/fortunes/platitudes', cache: false),
    rootBundle.loadString('assets/fortunes/wisdom', cache: false),
  ];

  final List<String> contents = await Future.wait(assets);

  final results = <Fortune>[];
  var current = <String>[];

  // Finalize fortune.
  void finalize() {
    if (current.isEmpty) return;
    if (current.length > maxLines) {
      // Discard fortunes with too many lines.
      current.clear();
      return;
    }
    results.add(Fortune(List.from(current)));
    current.clear();
  }

  for (final rawLine in contents.join('\n').split('\n')) {
    final line = rawLine.trimRight().replaceAll('\t', '    ');
    if (line == '%') {
      finalize();
      continue;
    }
    current.add(line);
  }
  finalize();
  _cache = results;
  return results;
}

class Fortune {
  final List<String> lines;

  const Fortune(this.lines);
}

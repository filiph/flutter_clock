// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:fortune_clock/src/fortunes.dart';

const String cursor = '█';

const _darkTheme = {
  _Element.background: Color(0xFF000000),
  _Element.text: Color(0xFFC7C7C7),
};

/// Inspired by 'Solarized Light' theme.
const _lightTheme = {
  _Element.background: Color(0xFFfdf6e3),
  _Element.text: Color(0xFF657b83),
};

/// A basic digital clock.
///
/// You can do better than this!
class FortuneClock extends StatefulWidget {
  final ClockModel model;

  const FortuneClock(this.model);

  @override
  _FortuneClockState createState() => _FortuneClockState();
}

class _ActiveLine extends StatelessWidget {
  static const humanTypeSpeed = Duration(milliseconds: 150);

  static const terminalTypeSpeed = Duration(milliseconds: 10);

  final VoidCallback onDone;

  final String text;

  final bool isUserInput;

  _ActiveLine({
    @required this.text,
    @required this.onDone,
    this.isUserInput = false,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: _TypingTween(text, isUserInput),
      onEnd: onDone,
      duration:
          (isUserInput ? humanTypeSpeed : terminalTypeSpeed) * text.length,
      builder: (context, value, child) {
        return Text(value);
      },
    );
  }
}

enum _Element {
  background,
  text,
}

class _FortuneClockState extends State<FortuneClock> {
  static final _random = Random();

  Timer _timer;

  Timer _fortuneTimer;

  _ActiveLine _activeLine;

  final List<String> _lines = [];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final fontSize = MediaQuery.of(context).size.width / 50;
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Source Code Pro',
      fontSize: fontSize,
    );

    return Container(
      color: colors[_Element.background],
      child: DefaultTextStyle(
        style: defaultStyle,
        child: ListView(
          padding: const EdgeInsets.all(16),
          reverse: true,
          children: <Widget>[
            SizedBox(height: fontSize * 10),
            if (_activeLine != null) _activeLine else const Text('\$ $cursor'),
            for (final line in _lines) Text(line),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(FortuneClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fortuneTimer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
    // Cache fortunes.
    loadFortunes();
  }

  /// Formats date according to the Unix `date` command's default configuration.
  /// For example:
  ///
  ///     $ date
  ///     Mon Nov 18 16:37:26 PST 2019
  String _formatDate(DateTime time) {
    final buf = StringBuffer();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    buf.write(days[time.weekday - 1]);
    buf.write(' ');
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    buf.write(months[time.month - 1]);
    buf.write(' ');
    buf.write(time.day);
    buf.write(' ');
    buf.write(time.hour);
    buf.write(':');
    buf.write(time.minute.toString().padLeft(2, '0'));
    buf.write(':');
    buf.write(time.second.toString().padLeft(2, '0'));
    buf.write(' ');
    buf.write(time.timeZoneName);
    buf.write(' ');
    buf.write(time.year);
    return buf.toString();
  }

  Future<void> _print(String line, {bool isUserInput = false}) async {
    if (!mounted) return;
    assert(_activeLine == null);
    final completer = Completer<void>();
    setState(() {
      _activeLine = _ActiveLine(
        key: Key(line),
        text: line,
        isUserInput: isUserInput,
        onDone: () => completer.complete(),
      );
    });
    await completer.future;
    if (isUserInput) {
      // The delay between hitting enter.
      await Future.delayed(const Duration(milliseconds: 300));
    }
    _activeLine = null;
    setState(() {
      _lines.insert(0, _TypingTween._formatEndText(line, isUserInput, false));
    });
  }

  Future<void> _updateFortune() async {
    if (!mounted) return;
    final fortunes = await loadFortunes();

    if (!mounted) return;
    await _print('fortune', isUserInput: true);

    final fortune = fortunes[_random.nextInt(fortunes.length)];
    for (final line in fortune.lines) {
      if (!mounted) return;
      await _print(line);
    }

    // Schedule time.
    if (!mounted) return;
    var dateTime = DateTime.now();
    final delayBeforeNextTime = Duration(minutes: 1) -
        Duration(seconds: dateTime.second) -
        Duration(milliseconds: dateTime.millisecond);
    _timer = Timer(delayBeforeNextTime, _updateTime);
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  Future<void> _updateTime() async {
    if (!mounted) return;
    var dateTime = DateTime.now();
    await _print('date', isUserInput: true);
    await _print(_formatDate(dateTime));

    if (!mounted) return;

    // Update once per minute.
    dateTime = DateTime.now();
    final delayBeforeNextTime = Duration(minutes: 1) -
        Duration(seconds: dateTime.second) -
        Duration(milliseconds: dateTime.millisecond);

    const timeForFortune = const Duration(seconds: 55);
    if (delayBeforeNextTime > const Duration(seconds: 30)) {
      // Print a fortune cookie before the next minute mark.
      final delayBeforeNextFortune = timeForFortune -
          Duration(seconds: dateTime.second) -
          Duration(milliseconds: dateTime.millisecond);
      _fortuneTimer = Timer(delayBeforeNextFortune, _updateFortune);
    } else {
      _timer = Timer(delayBeforeNextTime, _updateTime);
    }
  }
}

class _TypingTween extends Tween<String> {
  final bool isUserInput;

  final String endText;

  _TypingTween(this.endText, this.isUserInput)
      : super(
          begin: isUserInput ? r'$ ' : '',
          end: _formatEndText(endText, isUserInput, true),
        );

  @override
  String lerp(double t) {
    if (t >= 1) {
      return _formatEndText(endText, isUserInput, true);
    }
    final buf = StringBuffer(isUserInput ? r'$ ' : '');
    if (t >= 1) {
      buf.write(endText);
    } else if (t > 0) {
      buf.write(endText.substring(0, (endText.length * t).floor()));
    }
    buf.write(cursor);
    return buf.toString();
  }

  static String _formatEndText(String text, bool isUserInput, bool hasCursor) =>
      '${isUserInput ? '\$ ' : ''}$text${hasCursor ? cursor : ''}';
}

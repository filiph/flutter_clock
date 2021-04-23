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
    required this.text,
    required this.onDone,
    this.isUserInput = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: _TypingTween(text, isUserInput),
      onEnd: onDone,
      duration:
          (isUserInput ? humanTypeSpeed : terminalTypeSpeed) * text.length,
      builder: (context, String value, child) {
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

  Timer? _timer;

  Timer? _fortuneTimer;

  _ActiveLine? _activeLine;

  FocusNode _focusNode = FocusNode();

  final List<String> _lines = [];

  DateTime? _lastTimeShown;

  bool _currentlyPrinting = false;

  bool _fortuneRequested = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final fontSize = MediaQuery.of(context).size.width / 52;
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Source Code Pro',
      fontSize: fontSize,
    );

    return GestureDetector(
      onTap: _handleKeyboardEvent,
      child: Container(
        color: colors[_Element.background],
        child: DefaultTextStyle(
          style: defaultStyle,
          child: ListView.builder(
            padding: EdgeInsets.only(
              top: fontSize * 2,
              left: fontSize * 2,
              right: fontSize * 2,
              bottom: fontSize * 10,
            ),
            reverse: true,
            itemCount: _lines.length + 1 /* for the active line */,
            itemBuilder: (_, index) {
              if (index == 0) {
                if (_activeLine != null) {
                  return _activeLine!;
                } else {
                  return const Text('\$ $cursor');
                }
              }
              return Text(_lines[index - 1]);
            },
          ),
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
    _updateModel();
    _printFortune();
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
    buf.write(time.hour.toString().padLeft(2, '0'));
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

  Duration _getTimeSinceLastTimeShownTo(DateTime dateTime) {
    if (_lastTimeShown == null) return Duration(days: 0xFFFF);
    return dateTime.difference(_lastTimeShown!);
  }

  void _handleKeyboardEvent() {
    if (!_currentlyPrinting) {
      _timer?.cancel();
      _fortuneTimer?.cancel();
      _printFortune();
      return;
    }
    _fortuneRequested = true;
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
    if (_lines.length > 10000) {
      // Prevent memory leak. But still provide a huge amount of history
      // (6 days) for those running the clock a long time.
      _lines.removeRange(9000, _lines.length);
    }
  }

  Future<void> _printFortune() async {
    assert(!_currentlyPrinting);
    _currentlyPrinting = true;
    if (!mounted) return;
    final fortunes = await loadFortunes();

    if (!mounted) return;
    await _print('fortune', isUserInput: true);

    final fortune = fortunes[_random.nextInt(fortunes.length)];
    for (final line in fortune.lines) {
      if (!mounted) return;
      await _print(line);
    }
    _currentlyPrinting = false;

    if (!mounted) return;
    if (_fortuneRequested) {
      _fortuneRequested = false;
      _printFortune();
      return;
    }

    // Schedule time.
    var dateTime = DateTime.now();

    if (_getTimeSinceLastTimeShownTo(dateTime) >= Duration(minutes: 1)) {
      // We've spent too much time printing (e.g. the user was not watching
      // the printing by scrolling up, so the widget didn't update).
      // Rerun [_updateTime()] immediately.
      _printTime();
      return;
    }

    final delayBeforeNextTime = Duration(minutes: 1) -
        Duration(seconds: dateTime.second) -
        Duration(milliseconds: dateTime.millisecond);
    _timer = Timer(delayBeforeNextTime, _printTime);
  }

  Future<void> _printTime() async {
    assert(!_currentlyPrinting);
    _currentlyPrinting = true;
    if (!mounted) return;
    var dateTime = DateTime.now();
    _lastTimeShown = dateTime;
    await _print('date', isUserInput: true);
    await _print(_formatDate(dateTime));
    _currentlyPrinting = false;

    if (!mounted) return;

    if (_fortuneRequested) {
      _fortuneRequested = false;
      _printFortune();
      return;
    }

    // How long since now (after we've spent time printing stuff)
    // until the next whole minute?
    dateTime = DateTime.now();
    if (_getTimeSinceLastTimeShownTo(dateTime) >= Duration(minutes: 1)) {
      // We've spent too much time printing (e.g. the user was not watching
      // the printing by scrolling up, so the widget didn't update).
      // Rerun [_updateTime()] immediately.
      _printTime();
      return;
    }

    final delayBeforeNextTime = Duration(minutes: 1) -
        Duration(seconds: dateTime.second) -
        Duration(milliseconds: dateTime.millisecond);

    // The best time for fortune is 5 seconds before whole minute.
    const timeForFortune = const Duration(seconds: 55);
    if (delayBeforeNextTime > const Duration(seconds: 5)) {
      // Print a fortune cookie before the next minute mark.
      final delayBeforeNextFortune = timeForFortune -
          Duration(seconds: dateTime.second) -
          Duration(milliseconds: dateTime.millisecond);
      _fortuneTimer = Timer(delayBeforeNextFortune, _printFortune);
    } else {
      _timer = Timer(delayBeforeNextTime, _printTime);
    }
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
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

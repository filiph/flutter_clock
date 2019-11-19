// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';

const String cursor = '█';

const _darkTheme = {
  _Element.background: Color(0xFF666666),
  _Element.text: Color(0xFFEEEEEE),
};

const _lightTheme = {
  _Element.background: Color(0xFFEEEEEE),
  _Element.text: Color(0xFF666666),
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
  static const humanTypeSpeed = Duration(milliseconds: 350);

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
  Timer _timer;

  _ActiveLine _activeLine;

  final List<String> _lines = [];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final fontSize = MediaQuery.of(context).size.width / 40;
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'PressStart2P',
      fontSize: fontSize,
    );

    return Container(
      color: colors[_Element.background],
      child: Center(
        child: DefaultTextStyle(
          style: defaultStyle,
          child: ListView(
            reverse: true,
            children: <Widget>[
              SizedBox(height: fontSize * 10),
              if (_activeLine != null) _activeLine else Text('\$ $cursor'),
              for (final line in _lines) Text(line),
            ],
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
    await Future.delayed(const Duration(milliseconds: 500));
    _activeLine = null;
    setState(() {
      _lines.insert(0, _TypingTween._formatEndText(line, isUserInput, false));
    });
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

    // Update once per minute.
    dateTime = DateTime.now();
    _timer = Timer(
      Duration(minutes: 1) -
          Duration(seconds: dateTime.second) -
          Duration(milliseconds: dateTime.millisecond),
      _updateTime,
    );
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

import 'dart:async';

import 'package:flutter/material.dart';

class MinuteUpdater extends StatefulWidget {
  final Widget Function(BuildContext context) builder;

  const MinuteUpdater({super.key, required this.builder});

  @override
  State<MinuteUpdater> createState() => _MinuteUpdaterState();
}

class _MinuteUpdaterState extends State<MinuteUpdater> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scheduleNextUpdate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleNextUpdate() {
    final now = DateTime.now();
    final nextMinute =
        DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    final durationUntilNextMinute = nextMinute.difference(now);
    _timer = Timer(durationUntilNextMinute, _handleMinuteTick);
  }

  void _handleMinuteTick() {
    setState(() {});
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}

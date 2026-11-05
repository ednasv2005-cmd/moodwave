import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moodwave/core/constants/app_colors.dart';

class BreathingWidget extends StatefulWidget {
  const BreathingWidget({super.key});

  @override
  State<BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<BreathingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _currentPhase = 'Inhala';
  int _secondsRemaining = 4;
  Timer? _timer;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  void _startBreathing() {
    setState(() {
      _isActive = true;
    });
    _runCycle();
  }

  void _runCycle() {
    if (!mounted || !_isActive) return;

    // Fase 1: Inhala 4s
    setState(() {
      _currentPhase = 'Inhala profundamente';
      _secondsRemaining = 4;
    });
    _controller.duration = const Duration(seconds: 4);
    _controller.forward(from: 0.0);

    _runPhaseTimer(4, () {
      if (!mounted || !_isActive) return;
      // Fase 2: Retén 7s
      setState(() {
        _currentPhase = 'Mantén el aire';
        _secondsRemaining = 7;
      });
      _runPhaseTimer(7, () {
        if (!mounted || !_isActive) return;
        // Fase 3: Exhala 8s
        setState(() {
          _currentPhase = 'Exhala suavemente';
          _secondsRemaining = 8;
        });
        _controller.duration = const Duration(seconds: 8);
        _controller.reverse(from: 1.0);

        _runPhaseTimer(8, () {
          if (!mounted || !_isActive) return;
          _runCycle(); // Repetir ciclo
        });
      });
    });
  }

  void _runPhaseTimer(int seconds, VoidCallback onComplete) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isActive) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        onComplete();
      }
    });
  }

  void _stopBreathing() {
    _timer?.cancel();
    _controller.stop();
    setState(() {
      _isActive = false;
      _currentPhase = 'Pausa para respirar';
      _secondsRemaining = 4;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryNeon.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🫧', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    'Respiración Consciente 4-7-8',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(_isActive ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded),
                color: AppColors.primaryNeon,
                iconSize: 32,
                onPressed: _isActive ? _stopBreathing : _startBreathing,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = 0.8 + (_controller.value * 0.4);
              return Container(
                width: 130 * scale,
                height: 130 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondaryNeon.withValues(alpha: 0.4),
                      AppColors.primaryNeon.withValues(alpha: 0.15),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryNeon.withValues(alpha: 0.3 * _controller.value),
                      blurRadius: 20 * scale,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isActive ? '$_secondsRemaining' : '4-7-8',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _isActive ? _currentPhase : 'Toca play',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Inhala 4s • Retén 7s • Exhala 8s para calmar el ritmo cardíaco y la tensión.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

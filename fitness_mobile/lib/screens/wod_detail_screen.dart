import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fitness_mobile/services/api_service.dart';
import 'package:fitness_mobile/core/colors.dart';

class WodDetailScreen extends StatefulWidget {
  final Map<String, dynamic> wod;

  const WodDetailScreen({super.key, required this.wod});

  @override
  State<WodDetailScreen> createState() => _WodDetailScreenState();
}

class _WodDetailScreenState extends State<WodDetailScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _elapsedSeconds = 0;
  int _secondsLeft = 0;
  bool _isRunning = false;
  int _countdownValue = -1;
  Timer? _countdownTimer;
  int _reps = 0;
  late AnimationController _pulseController;

  // Phase-based timer variables for AMRAP/RFT
  int _currentRound = 1;
  int _totalRounds = 3;
  int _workMinutes = 3;
  int _restSeconds = 30;
  bool _isWorkPhase = true; // true = WORK, false = REST
  int _phaseSecondsLeft = 0;
  int _phaseTotalSeconds = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _initializeTimer();
  }

  void _initializeTimer() {
    final type = (widget.wod['type'] ?? 'ForTime').toLowerCase();
    final totalSeconds = (widget.wod['durationInMinutes'] ?? 0) * 60;

    if (type.contains('amrap')) {
      _secondsLeft = totalSeconds;
      // Parse AMRAP format from type string: "AMRAP - 3 rounds x 3 min AMRAP (Rest: 0 min 40 sec)"
      _parseAmrapFormat();
      _initializePhaseTimer();
    } else if (type.contains('rft')) {
      _secondsLeft = totalSeconds;
      _parseRftFormat();
      _initializePhaseTimer();
    } else if (type.contains('fortime')) {
      _elapsedSeconds = 0;
    }
  }

  void _parseAmrapFormat() {
    // Extract rounds and times from the WOD type string
    // Example: "AMRAP - 3 rounds x 3 min AMRAP (Rest: 1 min 30 sec)"
    final typeStr = widget.wod['type'] ?? '';

    // Try to extract rounds (e.g., "3 rounds")
    final roundsMatch = RegExp(r'(\d+)\s+rounds').firstMatch(typeStr);
    if (roundsMatch != null) {
      _totalRounds = int.parse(roundsMatch.group(1)!);
    }

    // Try to extract work minutes (e.g., "x 3 min")
    final minMatch = RegExp(r'x\s+(\d+)\s+min').firstMatch(typeStr);
    if (minMatch != null) {
      _workMinutes = int.parse(minMatch.group(1)!);
    }

    // Try to extract rest seconds (e.g., "Rest: 1 min 30 sec" or "Rest: 40 sec")
    final restMatch = RegExp(
      r'Rest:\s+(?:(\d+)\s+min\s+)?(\d+)\s+sec',
    ).firstMatch(typeStr);
    if (restMatch != null) {
      int restMin = 0;
      if (restMatch.group(1) != null) {
        restMin = int.parse(restMatch.group(1)!);
      }
      int restSec = int.parse(restMatch.group(2)!);
      _restSeconds = (restMin * 60) + restSec;
    }
  }

  void _parseRftFormat() {
    // Similar to AMRAP parsing
    final typeStr = widget.wod['type'] ?? '';

    final roundsMatch = RegExp(r'(\d+)\s+rounds').firstMatch(typeStr);
    if (roundsMatch != null) {
      _totalRounds = int.parse(roundsMatch.group(1)!);
    }

    final minMatch = RegExp(r'x\s+(\d+)\s+min').firstMatch(typeStr);
    if (minMatch != null) {
      _workMinutes = int.parse(minMatch.group(1)!);
    }

    final restMatch = RegExp(
      r'Rest:\s+(?:(\d+)\s+min\s+)?(\d+)\s+sec',
    ).firstMatch(typeStr);
    if (restMatch != null) {
      int restMin = 0;
      if (restMatch.group(1) != null) {
        restMin = int.parse(restMatch.group(1)!);
      }
      int restSec = int.parse(restMatch.group(2)!);
      _restSeconds = (restMin * 60) + restSec;
    }
  }

  void _initializePhaseTimer() {
    _isWorkPhase = true;
    _currentRound = 1;
    _phaseTotalSeconds = _workMinutes * 60;
    _phaseSecondsLeft = _phaseTotalSeconds;
    _elapsedSeconds = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    // If timer is running, pause it
    if (_isRunning) {
      _pauseTimer();
      return;
    }

    // If paused (elapsedSeconds > 0), resume
    if (_elapsedSeconds > 0) {
      _resumeTimer();
      return;
    }

    // If countdown already in progress, ignore
    if (_countdownValue > 0 || _countdownTimer != null) {
      return;
    }

    // Start countdown
    _startCountdown();
  }

  void _resumeTimer() {
    final type = (widget.wod['type'] ?? 'ForTime').toLowerCase();
    final totalSeconds = (widget.wod['durationInMinutes'] ?? 0) * 60;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (type.contains('amrap') || type.contains('rft')) {
          _elapsedSeconds++;
          _phaseSecondsLeft--;

          // Check if phase is complete
          if (_phaseSecondsLeft <= 0) {
            if (_isWorkPhase) {
              // Work phase finished, switch to rest
              if (_currentRound < _totalRounds) {
                _isWorkPhase = false;
                _phaseTotalSeconds = _restSeconds;
                _phaseSecondsLeft = _restSeconds;
              } else {
                // All rounds complete
                _stopAndSave();
                return;
              }
            } else {
              // Rest phase finished, switch to next round's work
              _currentRound++;
              if (_currentRound <= _totalRounds) {
                _isWorkPhase = true;
                _phaseTotalSeconds = _workMinutes * 60;
                _phaseSecondsLeft = _phaseTotalSeconds;
              } else {
                // All rounds complete
                _stopAndSave();
                return;
              }
            }
          }
        } else if (type.contains('fortime')) {
          _elapsedSeconds++;

          if (_elapsedSeconds >= totalSeconds) {
            _stopAndSave();
          }
        }
      });
    });
  }

  void _startCountdown() {
    if (_countdownValue > 0 || _countdownTimer != null) {
      return;
    }

    setState(() {
      _countdownValue = 3;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownValue > 0) {
          _countdownValue--;
        } else if (_countdownValue == 0) {
          _startTimerLogic();
          _countdownValue = -1;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _startTimerLogic() {
    if (_isRunning) return;

    final type = (widget.wod['type'] ?? 'ForTime').toLowerCase();
    final totalSeconds = (widget.wod['durationInMinutes'] ?? 0) * 60;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (type.contains('amrap') || type.contains('rft')) {
          _elapsedSeconds++;
          _phaseSecondsLeft--;

          // Check if phase is complete
          if (_phaseSecondsLeft <= 0) {
            if (_isWorkPhase) {
              // Work phase finished, switch to rest
              if (_currentRound < _totalRounds) {
                _isWorkPhase = false;
                _phaseTotalSeconds = _restSeconds;
                _phaseSecondsLeft = _restSeconds;
              } else {
                // All rounds complete
                _stopAndSave();
                return;
              }
            } else {
              // Rest phase finished, switch to next round's work
              _currentRound++;
              if (_currentRound <= _totalRounds) {
                _isWorkPhase = true;
                _phaseTotalSeconds = _workMinutes * 60;
                _phaseSecondsLeft = _phaseTotalSeconds;
              } else {
                // All rounds complete
                _stopAndSave();
                return;
              }
            }
          }
        } else if (type.contains('fortime')) {
          _elapsedSeconds++;

          if (_elapsedSeconds >= totalSeconds) {
            _stopAndSave();
          }
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _countdownValue = -1;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    setState(() {
      _elapsedSeconds = 0;
      _secondsLeft = 0;
      _isRunning = false;
      _countdownValue = -1;
      _reps = 0;
      _currentRound = 1;
      _isWorkPhase = true;
      _phaseSecondsLeft = 0;
    });
    _initializeTimer();
  }

  void _stopAndSave() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });

    // Save workout result to backend
    final wodResult = {
      'wodId': widget.wod['id'] ?? 0,
      'durationInSeconds': _elapsedSeconds,
      'reps': _reps,
    };

    print('Saving WOD result: $wodResult');

    ApiService.saveWorkoutResult(wodResult)
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Workout completed and saved!'),
              duration: Duration(seconds: 3),
            ),
          );
          // Reset after successful save
          Future.delayed(const Duration(seconds: 1), () {
            _resetTimer();
          });
        })
        .catchError((error) {
          print('Error saving workout: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving workout: $error'),
              duration: const Duration(seconds: 3),
            ),
          );
        });
  }

  void _incrementReps() {
    setState(() {
      _reps++;
    });
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  int _getDisplayTime() {
    final type = (widget.wod['type'] ?? 'ForTime').toLowerCase();
    if (type.contains('amrap') || type.contains('rft')) {
      return _phaseSecondsLeft;
    } else if (type.contains('amrap')) {
      return _secondsLeft;
    }
    return _elapsedSeconds;
  }

  String _getPhaseLabel() {
    final type = (widget.wod['type'] ?? 'ForTime').toLowerCase();
    if (type.contains('amrap') || type.contains('rft')) {
      return _isWorkPhase ? 'WORK' : 'REST';
    }
    return '';
  }

  String _getRoundInfo() {
    final type = (widget.wod['type'] ?? 'ForTime').toLowerCase();
    if (type.contains('amrap') || type.contains('rft')) {
      return 'Round $_currentRound / $_totalRounds';
    }
    return '';
  }

  String _getFormatDescription() {
    final type = (widget.wod['type'] ?? '').toLowerCase();

    if (type.contains('amrap') || type.contains('rft')) {
      return '$_totalRounds Rounds × ${_workMinutes}m Work + ${_restSeconds}s Rest';
    } else if (type.contains('emom')) {
      return '$_totalRounds Minutes EMOM';
    } else if (type.contains('tabata')) {
      return '$_totalRounds Rounds Tabata';
    } else if (type.contains('fortime')) {
      return 'For Time';
    }
    return widget.wod['type'] ?? 'Workout';
  }

  String _getTotalDuration() {
    final type = (widget.wod['type'] ?? '').toLowerCase();

    if (type.contains('amrap') || type.contains('rft')) {
      // Calculate: rounds × (work + rest) - rest (no rest after last round)
      final totalSeconds =
          (_totalRounds * (_workMinutes * 60 + _restSeconds)) - _restSeconds;
      return _formatTime(totalSeconds);
    } else if (type.contains('emom')) {
      return '${_totalRounds} min';
    } else if (type.contains('tabata')) {
      return widget.wod['durationDisplay'] ??
          '${widget.wod['durationInMinutes'] ?? '0'} min';
    } else if (type.contains('fortime')) {
      return widget.wod['durationDisplay'] ??
          '${widget.wod['durationInMinutes'] ?? '0'} min';
    }
    return widget.wod['durationDisplay'] ??
        '${widget.wod['durationInMinutes'] ?? '0'} min';
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.wod['type'] ?? 'ForTime';
    final displayTime = _getDisplayTime();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wod['name'] ?? 'Workout'),
        elevation: 0,
        backgroundColor: AppColors.primaryViolet,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.primaryGradient,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Text(
                      _getFormatDescription(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.wod['name'] ?? 'Workout',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _elapsedSeconds > 0
                            ? _formatTime(_elapsedSeconds)
                            : _getTotalDuration(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Timer Card with Countdown Overlay
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  GestureDetector(
                    // Tap timer to pause/resume
                    onTap: () {
                      if (_isRunning || _elapsedSeconds > 0) {
                        _toggleTimer();
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Timer Card
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 40,
                              horizontal: 24,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: AppColors.lightest,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _isRunning ? 'Running' : 'Tap to Start',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Phase and Round Info
                                if (_getPhaseLabel().isNotEmpty) ...[
                                  Container(
                                    decoration: BoxDecoration(
                                      color: _isWorkPhase
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _getPhaseLabel(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: _isWorkPhase
                                                ? Colors.green
                                                : Colors.orange,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _getRoundInfo(),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                ScaleTransition(
                                  scale: Tween<double>(
                                    begin: 0.95,
                                    end: 1.05,
                                  ).animate(_pulseController),
                                  child: Text(
                                    _formatTime(displayTime),
                                    style: const TextStyle(
                                      fontSize: 56,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryViolet,
                                      fontFamily: 'Courier',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Start button inside timer
                                if (_countdownValue < 0 && _elapsedSeconds == 0)
                                  ElevatedButton(
                                    onPressed: _toggleTimer,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 14,
                                      ),
                                      backgroundColor: AppColors.primaryViolet,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Start Workout'),
                                  ),
                                if (_countdownValue >= 0)
                                  ElevatedButton(
                                    onPressed: _cancelCountdown,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryViolet,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 10,
                                      ),
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Countdown Overlay - Transparent
                        if (_countdownValue >= 0)
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.7),
                            ),
                            width: 150,
                            height: 150,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_countdownValue > 0)
                                  Text(
                                    _countdownValue.toString(),
                                    style: const TextStyle(
                                      fontSize: 56,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                else
                                  const Text(
                                    'GO!',
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Finish Button - only visible when workout is running
                  if (_elapsedSeconds > 0)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.red.shade500, Colors.red.shade600],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _stopAndSave,
                          borderRadius: BorderRadius.circular(14),
                          splashColor: Colors.white.withOpacity(0.3),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 28,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Finish',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Rep Counter (for AMRAP/RFT)
            if ((widget.wod['type'] ?? '').toLowerCase().contains('amrap') ||
                (widget.wod['type'] ?? '').toLowerCase().contains('rft'))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _isRunning ? _incrementReps : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        backgroundColor: AppColors.primaryViolet,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '+',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _reps.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

            // Reset Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OutlinedButton(
                onPressed: _resetTimer,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  side: const BorderSide(
                    color: AppColors.primaryViolet,
                    width: 2,
                  ),
                  foregroundColor: AppColors.primaryViolet,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Reset Workout'),
              ),
            ),
            const SizedBox(height: 24),

            // WOD Details and Movements Combined
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppColors.lightest,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Workout Instructions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.wod['fullDescription'] ??
                            widget.wod['description'] ??
                            'No description available',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Movements',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (widget.wod['movements'] != null)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (widget.wod['movements'] as String)
                              .split(',')
                              .map((movement) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryViolet,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: Text(
                                    movement.trim(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                        )
                      else
                        Text(
                          'No movements data',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

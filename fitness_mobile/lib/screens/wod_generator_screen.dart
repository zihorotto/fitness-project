import 'package:flutter/material.dart';
import 'package:fitness_mobile/services/api_service.dart';
import 'package:fitness_mobile/core/colors.dart';

class WodGeneratorScreen extends StatefulWidget {
  const WodGeneratorScreen({super.key});

  @override
  State<WodGeneratorScreen> createState() => _WodGeneratorScreenState();
}

class _WodGeneratorScreenState extends State<WodGeneratorScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _movementInputController = TextEditingController();
  final _durationController = TextEditingController();
  final _rftRoundsController = TextEditingController();
  final _rftTimeController = TextEditingController();
  final _rftRestController = TextEditingController();
  final _amrapRoundsController = TextEditingController();
  final _amrapTimeController = TextEditingController();
  final _amrapRestController = TextEditingController();
  final _forTimeRoundsController = TextEditingController();
  final _forTimeTimeController = TextEditingController();
  final _forTimeRestController = TextEditingController();

  String _selectedType = 'Cardio';
  String _selectedFormat = 'AMRAP';
  bool _isLoading = false;
  Map<String, dynamic>? _generatedWod;
  List<String> _movements = [];
  late AnimationController _successAnimationController;

  // Format-specific settings
  int _rounds = 3;
  int _workMinutes = 3;
  int _restMinutes = 1;
  int _restSeconds = 30;
  int _workSeconds = 20;
  int _timeCapMinutes = 20;
  int _lastTimeCapMinutes = 20; // Remember last time cap value
  bool _hasTimeCap = false;

  // For Time settings
  int _forTimeRounds = 1;
  int _forTimeWorkMinutes = 20;
  int _forTimeRestMinutes = 0;
  int _forTimeRestSeconds = 0;

  final List<Map<String, dynamic>> _types = [
    {'name': 'Cardio', 'icon': Icons.directions_run, 'color': Colors.red},
    {'name': 'Strength', 'icon': Icons.fitness_center, 'color': Colors.orange},
    {'name': 'Mixed', 'icon': Icons.all_inclusive, 'color': Colors.blue},
    {'name': 'HIIT', 'icon': Icons.flash_on, 'color': Colors.purple},
  ];

  final List<Map<String, dynamic>> _formats = [
    {
      'name': 'AMRAP',
      'icon': Icons.all_inclusive,
      'description': 'As Many Reps/Rounds As Possible',
      'configType': 'duration', // needs duration
    },
    {
      'name': 'For Time',
      'icon': Icons.timer,
      'description': 'Complete for time',
      'configType': 'timecap', // optional time cap
    },
    {
      'name': 'EMOM',
      'icon': Icons.schedule,
      'description': 'Every Minute On the Minute',
      'configType': 'rounds', // needs number of rounds (minutes)
    },
    {
      'name': 'Tabata',
      'icon': Icons.timer_outlined,
      'description': '20s work / 10s rest',
      'configType': 'tabata', // needs rounds, work/rest seconds
    },
    {
      'name': 'RFT',
      'icon': Icons.repeat,
      'description': 'Rounds For Time',
      'configType': 'rounds_timecap', // needs rounds + optional time cap
    },
  ];

  @override
  void initState() {
    super.initState();
    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    // Initialize AMRAP controllers
    _amrapRoundsController.text = _rounds.toString();
    _amrapTimeController.text = _workMinutes.toString();
    _amrapRestController.text = ((_restMinutes * 60) + _restSeconds).toString();
    // Initialize RFT controllers
    _rftRoundsController.text = _rounds.toString();
    _rftTimeController.text = _workMinutes.toString();
    _rftRestController.text = ((_restMinutes * 60) + _restSeconds).toString();
    // Initialize For Time controllers
    _forTimeRoundsController.text = _forTimeRounds.toString();
    _forTimeTimeController.text = _forTimeWorkMinutes.toString();
    _forTimeRestController.text =
        ((_forTimeRestMinutes * 60) + _forTimeRestSeconds).toString();
    _updateDurationForFormat();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _movementInputController.dispose();
    _durationController.dispose();
    _rftRoundsController.dispose();
    _rftTimeController.dispose();
    _rftRestController.dispose();
    _amrapRoundsController.dispose();
    _amrapTimeController.dispose();
    _amrapRestController.dispose();
    _successAnimationController.dispose();
    super.dispose();
  }

  void _updateDurationForFormat() {
    if (_selectedFormat == 'For Time') {
      // Calculate total time in seconds: work time + rest time
      int totalSeconds = _forTimeRounds * _forTimeWorkMinutes * 60;
      if (_forTimeRestMinutes > 0 || _forTimeRestSeconds > 0) {
        int restTotalSeconds =
            (_forTimeRounds - 1) *
            ((_forTimeRestMinutes * 60) + _forTimeRestSeconds);
        totalSeconds += restTotalSeconds;
      }
      // Format as MM:SS
      int minutes = totalSeconds ~/ 60;
      int seconds = totalSeconds % 60;
      _durationController.text =
          '${minutes}:${seconds.toString().padLeft(2, '0')}';
    } else if (_selectedFormat == 'AMRAP') {
      // Calculate total time in seconds: work time + rest time
      int totalSeconds = _rounds * _workMinutes * 60;
      if (_restMinutes > 0 || _restSeconds > 0) {
        int restTotalSeconds =
            (_rounds - 1) * ((_restMinutes * 60) + _restSeconds);
        totalSeconds += restTotalSeconds;
      }
      // Format as MM:SS
      int minutes = totalSeconds ~/ 60;
      int seconds = totalSeconds % 60;
      _durationController.text =
          '${minutes}:${seconds.toString().padLeft(2, '0')}';
    } else if (_selectedFormat == 'RFT') {
      // Calculate total time in seconds: work time + rest time
      int totalSeconds = _rounds * _workMinutes * 60;
      if (_restMinutes > 0 || _restSeconds > 0) {
        int restTotalSeconds =
            (_rounds - 1) * ((_restMinutes * 60) + _restSeconds);
        totalSeconds += restTotalSeconds;
      }
      // Format as MM:SS
      int minutes = totalSeconds ~/ 60;
      int seconds = totalSeconds % 60;
      _durationController.text =
          '${minutes}:${seconds.toString().padLeft(2, '0')}';
    } else if (_selectedFormat == 'EMOM') {
      _durationController.text = '${_rounds}:00';
    } else if (_selectedFormat == 'Tabata') {
      int totalSeconds = _rounds * (_workSeconds + _restSeconds);
      int minutes = totalSeconds ~/ 60;
      int seconds = totalSeconds % 60;
      _durationController.text =
          '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  void _addMovement() {
    if (_movementInputController.text.trim().isNotEmpty) {
      setState(() {
        _movements.add(_movementInputController.text.trim());
        _movementInputController.clear();
      });
    }
  }

  void _removeMovement(String movement) {
    setState(() {
      _movements.remove(movement);
    });
  }

  String _getFormatDescription() {
    switch (_selectedFormat) {
      case 'AMRAP':
        String desc = '$_rounds rounds x $_workMinutes min AMRAP';
        if (_restMinutes > 0 || _restSeconds > 0) {
          desc += ' (Rest: $_restMinutes min $_restSeconds sec)';
        }
        return desc;
      case 'For Time':
        int totalSeconds = _forTimeRounds * _forTimeWorkMinutes * 60;
        if (_forTimeRestMinutes > 0 || _forTimeRestSeconds > 0) {
          int restTotalSeconds =
              (_forTimeRounds - 1) *
              ((_forTimeRestMinutes * 60) + _forTimeRestSeconds);
          totalSeconds += restTotalSeconds;
        }
        int minutes = totalSeconds ~/ 60;
        int seconds = totalSeconds % 60;
        return 'For Time ($_forTimeRounds rounds, ${minutes}:${seconds.toString().padLeft(2, '0')})';
      case 'EMOM':
        return '$_rounds min EMOM';
      case 'Tabata':
        return '$_rounds rounds Tabata ($_workSeconds sec work / $_restSeconds sec rest)';
      case 'Chipper':
        return _hasTimeCap
            ? 'Chipper (Time Cap: $_timeCapMinutes min)'
            : 'Chipper';
      case 'RFT':
        String desc = '$_rounds rounds x $_workMinutes min RFT';
        if (_restMinutes > 0 || _restSeconds > 0) {
          desc += ' (Rest: $_restMinutes min $_restSeconds sec)';
        }
        return desc;
      default:
        return _selectedFormat;
    }
  }

  Future<void> _generateWod() async {
    if (!_formKey.currentState!.validate()) return;

    if (_movements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one movement!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final movementsStr = _movements.join(', ');

      final formatDescription = _getFormatDescription();

      // Calculate total duration based on format
      String durationInMinutes;
      int durationInSeconds = 1200; // Default 20 minutes in seconds

      if (_selectedFormat == 'AMRAP') {
        // Calculate total time in seconds: work time + rest time
        int totalSeconds = _rounds * _workMinutes * 60;
        if (_restMinutes > 0 || _restSeconds > 0) {
          int restTotalSeconds =
              (_rounds - 1) * ((_restMinutes * 60) + _restSeconds);
          totalSeconds += restTotalSeconds;
        }
        // Format as MM:SS
        int minutes = totalSeconds ~/ 60;
        int seconds = totalSeconds % 60;
        durationInMinutes = '${minutes}:${seconds.toString().padLeft(2, '0')}';
        durationInSeconds = totalSeconds;
      } else if (_selectedFormat == 'Tabata') {
        int totalSeconds = _rounds * (_workSeconds + _restSeconds);
        int minutes = totalSeconds ~/ 60;
        int seconds = totalSeconds % 60;
        durationInMinutes = '${minutes}:${seconds.toString().padLeft(2, '0')}';
        durationInSeconds = totalSeconds;
      } else if (_selectedFormat == 'EMOM') {
        int totalSeconds = _rounds * 60;
        durationInMinutes = '${_rounds}:00';
        durationInSeconds = totalSeconds;
      } else if (_selectedFormat == 'For Time') {
        // Calculate total time in seconds: work time + rest time
        int totalSeconds = _forTimeRounds * _forTimeWorkMinutes * 60;
        if (_forTimeRestMinutes > 0 || _forTimeRestSeconds > 0) {
          int restTotalSeconds =
              (_forTimeRounds - 1) *
              ((_forTimeRestMinutes * 60) + _forTimeRestSeconds);
          totalSeconds += restTotalSeconds;
        }
        // Format as MM:SS
        int minutes = totalSeconds ~/ 60;
        int seconds = totalSeconds % 60;
        durationInMinutes = '${minutes}:${seconds.toString().padLeft(2, '0')}';
        durationInSeconds = totalSeconds;
      } else if (_selectedFormat == 'RFT') {
        // Calculate total time in seconds: work time + rest time
        int totalSeconds = _rounds * _workMinutes * 60;
        if (_restMinutes > 0 || _restSeconds > 0) {
          int restTotalSeconds =
              (_rounds - 1) * ((_restMinutes * 60) + _restSeconds);
          totalSeconds += restTotalSeconds;
        }
        // Format as MM:SS
        int minutes = totalSeconds ~/ 60;
        int seconds = totalSeconds % 60;
        durationInMinutes = '${minutes}:${seconds.toString().padLeft(2, '0')}';
        durationInSeconds = totalSeconds;
      } else {
        durationInMinutes = _durationController.text.isNotEmpty
            ? _durationController.text
            : '20:00';
        // Try to parse numeric value from MM:SS format
        try {
          List<String> parts = durationInMinutes.split(':');
          int minutes = int.parse(parts[0]);
          int seconds = parts.length > 1 ? int.parse(parts[1]) : 0;
          durationInSeconds = (minutes * 60) + seconds;
        } catch (e) {
          print('Error parsing duration: $e');
          durationInSeconds = 1200; // Default 20 minutes
        }
      }

      // Ensure durationInSeconds is a valid positive integer
      if (durationInSeconds < 60) {
        durationInSeconds = 60; // Minimum 1 minute
      }

      final data = {
        'name': _nameController.text,
        'type':
            '$_selectedFormat - $formatDescription', // WOD format with details
        'category': _selectedType, // Workout category (Cardio, Strength, etc.)
        'movements': movementsStr,
        'durationInSeconds': durationInSeconds, // Exact duration in seconds
        'durationDisplay':
            durationInMinutes, // Format: MM:SS display (e.g., "10:20")
        'description': _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : 'Custom workout',
      };

      // Log for debugging
      print('=== WOD Generation Debug ===');
      print('Display Duration: $durationInMinutes');
      print('Duration Seconds: $durationInSeconds');
      print('Full Data:');
      data.forEach((key, value) {
        print('  $key: $value (Type: ${value.runtimeType})');
      });
      print('=============================');

      final result = await ApiService.generateAndSaveWod(data);

      setState(() {
        _generatedWod = result;
        _isLoading = false;
      });

      _successAnimationController.forward(from: 0.0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('WOD successfully created!'),
              ],
            ),
            backgroundColor: AppColors.primaryViolet,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Hiba: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      _generatedWod = null;
      _nameController.clear();
      _descriptionController.clear();
      _movementInputController.clear();
      _durationController.clear();
      _movements.clear();
      _selectedType = 'Cardio';
      _selectedFormat = 'AMRAP';
      _rounds = 3;
      _workMinutes = 3;
      _restMinutes = 1;
      _restSeconds = 30;
      _workSeconds = 20;
      _timeCapMinutes = 20;
      _hasTimeCap = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create WOD'),
        elevation: 0,
        backgroundColor: AppColors.primaryViolet,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: _generatedWod != null ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  Widget _buildSuccessView() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.0).animate(
        CurvedAnimation(
          parent: _successAnimationController,
          curve: Curves.easeOut,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.lightest,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 60,
                      color: AppColors.primaryViolet,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Success!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryViolet,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCompactInfoRow(
                      'Name',
                      _generatedWod?['name'] ?? 'N/A',
                    ),
                    _buildCompactInfoRow(
                      'Format',
                      _generatedWod?['type'] ?? 'N/A',
                    ),
                    _buildCompactInfoRow(
                      'Category',
                      _generatedWod?['category'] ?? 'N/A',
                    ),
                    _buildCompactInfoRow(
                      'Duration',
                      '${_generatedWod?['durationInMinutes']} min',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _resetForm,
                icon: const Icon(Icons.add_circle),
                label: const Text('Create Another'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primaryViolet,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSettings() {
    final format = _formats.firstWhere((f) => f['name'] == _selectedFormat);
    final configType = format['configType'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [const SizedBox(height: 12), ..._buildConfigInputs(configType)],
    );
  }

  List<Widget> _buildConfigInputs(String configType) {
    switch (configType) {
      case 'duration':
        // AMRAP - simple input fields
        return [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppColors.primaryViolet.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryViolet.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryViolet.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First row: Rounds and Time per Round
                Row(
                  children: [
                    Expanded(
                      child: _buildControlledInput(
                        'Rounds',
                        Icons.repeat,
                        _amrapRoundsController,
                        (val) {
                          final parsed = int.tryParse(val);
                          if (parsed != null && parsed > 0) {
                            setState(() {
                              _rounds = parsed;
                              _updateDurationForFormat();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildControlledInput(
                        'Time (min)',
                        Icons.timer,
                        _amrapTimeController,
                        (val) {
                          final parsed = int.tryParse(val);
                          if (parsed != null && parsed > 0) {
                            setState(() {
                              _workMinutes = parsed;
                              _updateDurationForFormat();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Second row: Rest
                _buildControlledInput(
                  'Rest Between Rounds (sec)',
                  Icons.pause_circle_outline,
                  _amrapRestController,
                  (val) {
                    final parsed = int.tryParse(val);
                    if (parsed != null && parsed >= 0) {
                      setState(() {
                        _restMinutes = parsed ~/ 60;
                        _restSeconds = parsed % 60;
                        _updateDurationForFormat();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ];

      case 'rounds':
        // EMOM - needs number of rounds (minutes)
        return [
          _buildSimpleInput(
            'Number of Minutes',
            Icons.schedule,
            _rounds.toString(),
            (val) {
              final parsed = int.tryParse(val);
              if (parsed != null && parsed > 0) {
                setState(() {
                  _rounds = parsed;
                  _updateDurationForFormat();
                });
              }
            },
          ),
        ];

      case 'tabata':
        // Tabata - needs rounds, work seconds, rest seconds
        return [
          _buildModernNumberSetting(
            'Rounds',
            _rounds,
            Icons.repeat,
            (val) => setState(() {
              _rounds = val;
              _updateDurationForFormat();
            }),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryViolet.withOpacity(0.1),
                  AppColors.primaryViolet.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryViolet.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        color: AppColors.primaryViolet,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Work',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildCompactNumberInput('sec', _workSeconds, (val) {
                        setState(() {
                          _workSeconds = val;
                          _updateDurationForFormat();
                        });
                      }),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 80,
                  color: AppColors.primaryViolet.withOpacity(0.2),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.self_improvement,
                        color: AppColors.primaryViolet,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rest',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCompactNumberInput('sec', _restSeconds, (val) {
                        setState(() {
                          _restSeconds = val;
                          _updateDurationForFormat();
                        });
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ];

      case 'timecap':
        // For Time - similar to AMRAP with rounds, time per round, and optional rest
        return [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppColors.primaryViolet.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryViolet.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryViolet.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First row: Rounds and Time per Round
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.repeat,
                            color: AppColors.primaryViolet,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rounds',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildCompactNumberInput('', _forTimeRounds, (val) {
                            setState(() {
                              _forTimeRounds = val;
                              _forTimeRoundsController.text = val.toString();
                              _updateDurationForFormat();
                            });
                          }),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 80,
                      color: AppColors.primaryViolet.withOpacity(0.2),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: AppColors.primaryViolet,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Time/Round (min)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildCompactNumberInput('min', _forTimeWorkMinutes, (
                            val,
                          ) {
                            setState(() {
                              _forTimeWorkMinutes = val;
                              _forTimeTimeController.text = val.toString();
                              _updateDurationForFormat();
                            });
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Second row: Rest
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.self_improvement,
                            color: AppColors.primaryViolet,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rest (min)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildCompactNumberInput('min', _forTimeRestMinutes, (
                            val,
                          ) {
                            setState(() {
                              _forTimeRestMinutes = val;
                              _updateDurationForFormat();
                            });
                          }),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 80,
                      color: AppColors.primaryViolet.withOpacity(0.2),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.self_improvement,
                            color: AppColors.primaryViolet,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rest (sec)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildCompactNumberInput('sec', _forTimeRestSeconds, (
                            val,
                          ) {
                            setState(() {
                              _forTimeRestSeconds = val;
                              _updateDurationForFormat();
                            });
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ];

      case 'rounds_timecap':
        // RFT - similar to AMRAP with rounds, time per round, and rest
        return [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppColors.primaryViolet.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryViolet.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryViolet.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First row: Rounds and Time per Round
                Row(
                  children: [
                    Expanded(
                      child: _buildControlledInput(
                        'Rounds',
                        Icons.repeat,
                        _rftRoundsController,
                        (val) {
                          final parsed = int.tryParse(val);
                          if (parsed != null && parsed > 0) {
                            setState(() {
                              _rounds = parsed;
                              _updateDurationForFormat();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildControlledInput(
                        'Time (min)',
                        Icons.timer,
                        _rftTimeController,
                        (val) {
                          final parsed = int.tryParse(val);
                          if (parsed != null && parsed > 0) {
                            setState(() {
                              _workMinutes = parsed;
                              _updateDurationForFormat();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Second row: Rest
                _buildControlledInput(
                  'Rest Between Rounds (sec)',
                  Icons.pause_circle_outline,
                  _rftRestController,
                  (val) {
                    final parsed = int.tryParse(val);
                    if (parsed != null && parsed >= 0) {
                      setState(() {
                        _restMinutes = parsed ~/ 60;
                        _restSeconds = parsed % 60;
                        _updateDurationForFormat();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ];

      default:
        return [];
    }
  }

  Widget _buildNumberSetting(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                if (value > 1) onChanged(value - 1);
              },
              icon: const Icon(Icons.remove_circle_outline),
              color: AppColors.primaryViolet,
            ),
            Text(
              '$value',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.primaryViolet,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernNumberSetting(
    String label,
    int value,
    IconData icon,
    Function(int) onChanged, {
    String unit = '',
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.primaryViolet.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryViolet.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryViolet.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryViolet.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryViolet, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          _buildModernCounter(value, onChanged, unit),
        ],
      ),
    );
  }

  Widget _buildModernCounter(int value, Function(int) onChanged, String unit) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryViolet.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              if (value > 0) onChanged(value - 1);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.remove,
                color: AppColors.primaryViolet,
                size: 20,
              ),
            ),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 50),
            alignment: Alignment.center,
            child: Text(
              unit.isNotEmpty ? '$value $unit' : '$value',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryViolet,
              ),
            ),
          ),
          InkWell(
            onTap: () => onChanged(value + 1),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.add, color: AppColors.primaryViolet, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernToggle(
    String label,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: value
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryViolet.withOpacity(0.15),
                    AppColors.primaryViolet.withOpacity(0.05),
                  ],
                )
              : null,
          color: value ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value ? AppColors.primaryViolet : Colors.grey[300]!,
            width: value ? 2 : 1,
          ),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: AppColors.primaryViolet.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: value
                    ? AppColors.primaryViolet.withOpacity(0.2)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: value ? AppColors.primaryViolet : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: value ? AppColors.primaryViolet : Colors.grey[700],
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 50,
              height: 28,
              decoration: BoxDecoration(
                gradient: value
                    ? LinearGradient(
                        colors: [
                          AppColors.primaryViolet,
                          AppColors.primaryViolet.withOpacity(0.7),
                        ],
                      )
                    : null,
                color: value ? null : Colors.grey[300],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: value ? 24 : 2,
                    top: 2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactNumberInput(
    String label,
    int value,
    Function(int) onChanged,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 100,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primaryViolet.withOpacity(0.5)),
          ),
          child: TextFormField(
            initialValue: '$value',
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryViolet,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (val) {
              final parsed = int.tryParse(val);
              if (parsed != null && parsed >= 0) {
                onChanged(parsed);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInlineCounter(
    int value,
    Function(int) onChanged, {
    String unit = '',
    bool compact = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryViolet.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              if (value > 0) onChanged(value - 1);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: EdgeInsets.all(compact ? 4 : 6),
              child: Icon(
                Icons.remove,
                color: AppColors.primaryViolet,
                size: compact ? 16 : 18,
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(minWidth: compact ? 40 : 50),
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 12,
              vertical: compact ? 4 : 6,
            ),
            alignment: Alignment.center,
            child: Text(
              unit.isNotEmpty ? '$value $unit' : '$value',
              style: TextStyle(
                fontSize: compact ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryViolet,
              ),
            ),
          ),
          InkWell(
            onTap: () => onChanged(value + 1),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: EdgeInsets.all(compact ? 4 : 6),
              child: Icon(
                Icons.add,
                color: AppColors.primaryViolet,
                size: compact ? 16 : 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleInput(
    String label,
    IconData icon,
    String initialValue,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primaryViolet, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryViolet,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildControlledInput(
    String label,
    IconData icon,
    TextEditingController controller,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primaryViolet, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryViolet,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WOD Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'WOD Name *',
                prefixIcon: const Icon(Icons.fitness_center),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primaryViolet,
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required field';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // What do you want?
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'What do you want to work on?',
                hintText: 'e.g., I want a full body workout with cardio...',
                prefixIcon: const Icon(Icons.lightbulb_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primaryViolet,
                    width: 2,
                  ),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Category Selection - Compact
            Text(
              'Category',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types.map((type) {
                final isSelected = _selectedType == type['name'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type['name']),
                  child: Chip(
                    avatar: Icon(
                      type['icon'],
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : AppColors.primaryViolet,
                    ),
                    label: Text(type['name']),
                    backgroundColor: isSelected
                        ? AppColors.primaryViolet
                        : Colors.grey[200],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // WOD Format Selection
            Text(
              'WOD Format',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _formats.map((format) {
                final isSelected = _selectedFormat == format['name'];
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedFormat = format['name'];
                    // Reset settings when format changes
                    _rounds = 3;
                    _workMinutes = 3;
                    _restMinutes = 1;
                    _restSeconds = 30;
                    _workSeconds = 20;
                    _timeCapMinutes = 20;
                    _hasTimeCap = false;

                    // Reset For Time settings
                    _forTimeRounds = 1;
                    _forTimeWorkMinutes = 20;
                    _forTimeRestMinutes = 0;
                    _forTimeRestSeconds = 0;

                    // Update all format controllers
                    _amrapRoundsController.text = _rounds.toString();
                    _amrapTimeController.text = _workMinutes.toString();
                    _amrapRestController.text =
                        ((_restMinutes * 60) + _restSeconds).toString();
                    _rftRoundsController.text = _rounds.toString();
                    _rftTimeController.text = _workMinutes.toString();
                    _rftRestController.text =
                        ((_restMinutes * 60) + _restSeconds).toString();
                    _forTimeRoundsController.text = _forTimeRounds.toString();
                    _forTimeTimeController.text = _forTimeWorkMinutes
                        .toString();
                    _forTimeRestController.text =
                        ((_forTimeRestMinutes * 60) + _forTimeRestSeconds)
                            .toString();
                    _updateDurationForFormat();
                  }),
                  child: Chip(
                    avatar: Icon(
                      format['icon'],
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : AppColors.primaryViolet,
                    ),
                    label: Text(format['name']),
                    backgroundColor: isSelected
                        ? AppColors.primaryViolet
                        : Colors.grey[200],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),

            // Format-specific settings
            _buildFormatSettings(),
            const SizedBox(height: 16),

            // Movements - Compact
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _movementInputController,
                    decoration: InputDecoration(
                      labelText: 'Add Movement',
                      hintText: 'e.g., Burpees',
                      prefixIcon: const Icon(Icons.directions_run),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryViolet,
                          width: 2,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _addMovement(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addMovement,
                  icon: const Icon(Icons.add_circle),
                  color: AppColors.primaryViolet,
                  iconSize: 32,
                ),
              ],
            ),
            if (_movements.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _movements.map((movement) {
                  return Chip(
                    label: Text(movement),
                    backgroundColor: AppColors.primaryViolet,
                    labelStyle: const TextStyle(color: Colors.white),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),

            // Duration - Compact
            TextFormField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              readOnly:
                  _selectedFormat == 'For Time' ||
                  _selectedFormat == 'RFT' ||
                  _selectedFormat == 'AMRAP' ||
                  _selectedFormat == 'EMOM' ||
                  _selectedFormat == 'Tabata',
              decoration: InputDecoration(
                labelText: 'Duration (minutes) *',
                prefixIcon: const Icon(Icons.timer),
                suffixText: 'min',
                hintText:
                    [
                      'For Time',
                      'RFT',
                      'AMRAP',
                      'EMOM',
                      'Tabata',
                    ].contains(_selectedFormat)
                    ? 'Auto-calculated'
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primaryViolet,
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required field';
                // Accept both number and MM:SS format
                if (!value!.contains(':')) {
                  if (int.tryParse(value) == null)
                    return 'Must be a number or MM:SS format';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateWod,
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome, size: 28),
                label: Text(
                  _isLoading ? 'Creating WOD...' : 'Create WOD',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: AppColors.primaryViolet,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.primaryViolet.withOpacity(0.5),
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

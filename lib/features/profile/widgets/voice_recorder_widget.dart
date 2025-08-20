// lib/features/profile/widgets/voice_recorder_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../../../core/utils/helpers.dart';

class VoiceRecorderWidget extends StatefulWidget {
  final Function(String) onTranscriptionComplete;

  const VoiceRecorderWidget({super.key, required this.onTranscriptionComplete});

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isProcessing = false;
  bool _permissionDenied = false;

  String? _recordingPath;
  int _recordingDuration = 0;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    // Don't auto-initialize - wait for user action
  }

  @override
  void dispose() {
    if (_isRecorderInitialized) {
      _recorder.closeRecorder();
    }
    super.dispose();
  }

  Future<bool> _requestPermission() async {
    // First check current status
    PermissionStatus status = await Permission.microphone.status;

    // If not determined yet, request it
    if (status.isDenied) {
      status = await Permission.microphone.request();
    }

    // If still denied after request, show settings dialog
    if (status.isDenied) {
      if (mounted) {
        final bool shouldOpenSettings = await _showPermissionDialog();
        if (shouldOpenSettings) {
          await openAppSettings();
          // User needs to restart the process after changing settings
          return false;
        } else {
          setState(() {
            _permissionDenied = true;
          });
          return false;
        }
      }
      return false;
    }

    // Check if permanently denied - need to open settings
    if (status.isPermanentlyDenied) {
      if (mounted) {
        final bool shouldOpenSettings = await _showPermissionDialog(
          isPermanent: true,
        );
        if (shouldOpenSettings) {
          await openAppSettings();
          // User needs to restart after changing settings
          return false;
        } else {
          setState(() {
            _permissionDenied = true;
          });
          return false;
        }
      }
      return false;
    }

    // Permission granted
    return status.isGranted;
  }

  Future<bool> _showPermissionDialog({bool isPermanent = false}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Microphone Permission Required'),
          content: Text(
            isPermanent
                ? 'Microphone permission is required for voice recording. Please enable it in your device settings.'
                : 'We need microphone permission to record your voice. Without this permission, you won\'t be able to use the voice recording feature.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.textMedium),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                isPermanent ? 'Open Settings' : 'Allow',
                style: TextStyle(color: AppColors.primaryDarkBlue),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _initRecorder() async {
    if (_isRecorderInitialized) return;

    final hasPermission = await _requestPermission();

    if (!hasPermission) {
      return;
    }

    try {
      await _recorder.openRecorder();
      setState(() {
        _isRecorderInitialized = true;
        _permissionDenied = false;
      });
    } catch (e) {
      if (mounted) {
        Helpers.showErrorModal(
          context,
          message: 'Failed to initialize recorder: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _startRecording() async {
    // If we need to initialize first
    if (!_isRecorderInitialized) {
      await _initRecorder();

      // If initialization failed, exit
      if (!_isRecorderInitialized) return;
    }

    try {
      final directory = await getTemporaryDirectory();
      _recordingPath =
          '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _recorder.startRecorder(
        toFile: _recordingPath,
        codec: Codec.aacADTS,
      );

      setState(() {
        _isRecording = true;
        _isPaused = false;
        _recordingDuration = 0;
        _startTime = DateTime.now();
      });

      // Start timer for recording duration
      _startTimer();
    } catch (e) {
      if (mounted) {
        Helpers.showErrorModal(
          context,
          message: 'Failed to start recording: ${e.toString()}',
        );
      }
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording && !_isPaused && mounted) {
        setState(() {
          _recordingDuration = DateTime.now().difference(_startTime).inSeconds;
        });

        // Max recording duration: 2 minutes
        if (_recordingDuration >= 120) {
          _stopRecording();
        } else {
          _startTimer();
        }
      }
    });
  }

  Future<void> _pauseRecording() async {
    if (_isRecording && !_isPaused) {
      await _recorder.pauseRecorder();
      setState(() {
        _isPaused = true;
      });
    } else if (_isRecording && _isPaused) {
      await _recorder.resumeRecorder();
      setState(() {
        _isPaused = false;
      });
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      final recordingResult = await _recorder.stopRecorder();

      setState(() {
        _isRecording = false;
        _isPaused = false;
        _isProcessing = true;
      });

      // In a real app, this would send the audio to a speech-to-text service
      // For this demo, we'll simulate transcription with a delay
      await _simulateTranscription(recordingResult!);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRecording = false;
          _isPaused = false;
          _isProcessing = false;
        });

        Helpers.showErrorModal(
          context,
          message: 'Failed to stop recording: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _simulateTranscription(String audioPath) async {
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // In a real app, this would be the result from a speech-to-text service
    // For this demo, we'll use a predefined response
    final transcription = _getSimulatedTranscription();

    widget.onTranscriptionComplete(transcription);

    setState(() {
      _isProcessing = false;
    });

    // Delete the temporary recording file
    try {
      final file = File(audioPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting temporary recording: $e');
    }
  }

  String _getSimulatedTranscription() {
    // List of sample transcriptions about core values
    final List<String> sampleTranscriptions = [
      "I believe strongly in Honesty and Integrity. These are the foundation of all my relationships. I also value Family very highly, and I think maintaining a Work-Life Balance is essential. The fifth value that guides me is Personal Growth.",

      "For me, Compassion is the most important value. I try to approach everyone with empathy. I also believe in Independence and the freedom to make my own choices. Creativity drives me daily, and I value Adventure and experiencing new things.",

      "Trust is the foundation of any relationship for me. I also value Spirituality and my connection to something greater. Loyalty to friends and family is non-negotiable. Health and wellbeing matter greatly to me, and I believe in Respect for all people.",

      "My core values include Ambition and achieving my goals. I believe in Community and supporting those around me. Reliability is important to me - I want to be someone people can count on. I value Knowledge and continuous learning, and I think Optimism is essential for a good life.",
    ];

    // Randomly select one of the sample transcriptions
    return sampleTranscriptions[DateTime.now().second %
        sampleTranscriptions.length];
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            children: [
              // Permission denied message
              if (_permissionDenied)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppDimensions.paddingM,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Microphone permission denied',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingS),
                        Text(
                          'Please use text input instead or grant microphone permission in device settings.',
                          style: AppTextStyles.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.paddingM),
                        TextButton(
                          onPressed: () async {
                            await openAppSettings();
                          },
                          child: Text(
                            'Open Settings',
                            style: TextStyle(color: AppColors.primaryDarkBlue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Recording timer
              if (_isRecording || _isPaused)
                DelayedDisplay(
                  delay: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.paddingM,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isRecording && !_isPaused ? Icons.mic : Icons.pause,
                          color:
                              _isRecording && !_isPaused
                                  ? Colors.red
                                  : AppColors.textMedium,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.paddingS),
                        Text(
                          _formatDuration(_recordingDuration),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingM),
                        Text(
                          _isPaused ? "Paused" : "Recording...",
                          style: AppTextStyles.bodySmall.copyWith(
                            fontStyle: FontStyle.italic,
                            color:
                                _isPaused ? AppColors.textMedium : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Microphone button and controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isRecording)
                    IconButton(
                      onPressed: _pauseRecording,
                      icon: Icon(
                        _isPaused ? Icons.play_arrow : Icons.pause,
                        color: AppColors.textDark,
                      ),
                      tooltip: _isPaused ? 'Resume' : 'Pause',
                    ),

                  // Main record button
                  GestureDetector(
                    onTap:
                        _isProcessing || _permissionDenied
                            ? null
                            : (_isRecording ? _stopRecording : _startRecording),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _isProcessing || _permissionDenied
                                ? AppColors.divider
                                : (_isRecording
                                    ? Colors.red
                                    : AppColors.primaryDarkBlue),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child:
                            _isProcessing
                                ? const SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    strokeWidth: 3,
                                  ),
                                )
                                : Icon(
                                  _isRecording ? Icons.stop : Icons.mic,
                                  color:
                                      _permissionDenied
                                          ? AppColors.textMedium
                                          : Colors.white,
                                  size: 32,
                                ),
                      ),
                    ),
                  ),

                  if (_isRecording)
                    IconButton(
                      onPressed: _stopRecording,
                      icon: const Icon(Icons.check, color: AppColors.success),
                      tooltip: 'Save',
                    ),
                ],
              ),

              // Status text
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.paddingM),
                child: Text(
                  _permissionDenied
                      ? 'Voice recording unavailable'
                      : (_isProcessing
                          ? 'Processing recording...'
                          : (_isRecording
                              ? 'Tap stop when you\'re done'
                              : 'Tap to record your core values')),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Remaining time indicator
              if (_isRecording)
                DelayedDisplay(
                  delay: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.paddingS),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Max recording time: ',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMedium,
                          ),
                        ),
                        Text(
                          '${(120 - _recordingDuration).toString()} seconds remaining',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMedium,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

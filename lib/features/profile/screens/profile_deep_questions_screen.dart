// lib/features/profile/screens/profile_deep_questions_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../../../app/locator.dart';
import '../widgets/ai_chat_bubble.dart';
import '../widgets/profile_step_indicator.dart';
import '../widgets/user_chat_bubble.dart';
import 'profile_assessment_screen.dart';

class ProfileDeepQuestionsScreen extends StatefulWidget {
  const ProfileDeepQuestionsScreen({super.key});

  @override
  State<ProfileDeepQuestionsScreen> createState() =>
      _ProfileDeepQuestionsScreenState();
}

class _ProfileDeepQuestionsScreenState
    extends State<ProfileDeepQuestionsScreen> {
  final _authService = locator<AuthService>();
  final _firebaseService = locator<FirebaseService>();
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isLoading = false;
  bool _isSending = false;
  bool _allQuestionsAnswered = false;
  bool _isInputVisible = false;

  // Deep questions and responses
  List<Map<String, dynamic>> _conversation = [];

  // List of deep questions to ask
  final List<String> _deepQuestions = [
    'How have your past relationships shaped who you are today?',
    'What does a healthy relationship look like to you?',
    'How do you typically handle conflicts in relationships?',
    'What role does vulnerability play in your close relationships?',
    'What are your expectations for emotional support in a relationship?',
    'How do you maintain your individuality while being in a relationship?',
    'What does trust mean to you, and how is it built?',
    'How do you express and receive love in relationships?',
  ];

  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadConversation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadConversation() async {
    setState(() => _isLoading = true);

    try {
      final user = _authService.getCurrentUser();

      if (user != null) {
        final profileDoc = await _firebaseService.getDocumentById(
          'profiles',
          user.uid,
        );

        if (profileDoc.exists) {
          final data = profileDoc.data() as Map<String, dynamic>;

          // Check if deep questions conversation exists
          if (data['deepQuestionsConversation'] != null &&
              data['deepQuestionsConversation'] is List) {
            setState(() {
              _conversation = List<Map<String, dynamic>>.from(
                data['deepQuestionsConversation'],
              );

              // Determine current question index based on conversation
              int aiMessageCount = 0;
              for (final message in _conversation) {
                if (message['sender'] == 'ai') {
                  aiMessageCount++;
                }
              }

              _currentQuestionIndex = aiMessageCount - 1;
              if (_currentQuestionIndex < 0) _currentQuestionIndex = 0;

              // Check if all questions have been answered
              _checkIfAllQuestionsAnswered();
            });
          } else {
            // Start the conversation with the first question
            _addAIMessage(_deepQuestions[0]);
          }
        }
      }

      setState(() => _isLoading = false);

      // Scroll to bottom after loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        Helpers.showErrorModal(
          context,
          message: 'Failed to load conversation: ${e.toString()}',
        );
      }
    }
  }

  void _addAIMessage(String text) {
    setState(() {
      _conversation.add({
        'text': text,
        'sender': 'ai',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    });

    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _conversation.add({
        'text': text,
        'sender': 'user',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      _isSending = true;
      _isInputVisible = false;
    });

    // Clear the text field
    _textController.clear();

    // Hide bottom sheet if visible
    Navigator.of(context).pop();

    _scrollToBottom();

    // Save the conversation to Firebase
    _saveConversation();

    // Move to the next question after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      setState(() {
        _isSending = false;

        // Check if we have more questions
        if (_currentQuestionIndex < _deepQuestions.length - 1) {
          _currentQuestionIndex++;
          _addAIMessage(_deepQuestions[_currentQuestionIndex]);
        } else {
          _allQuestionsAnswered = true;
        }
      });

      _scrollToBottom();
    });
  }

  Future<void> _saveConversation() async {
    try {
      final user = _authService.getCurrentUser();

      if (user != null) {
        await _firebaseService.updateDocument('profiles', user.uid, {
          'deepQuestionsConversation': _conversation,
          'completionStatus.deepQuestions': 'completed',
          'completionPercentage': FieldValue.increment(12.5),
          'lastUpdated': Timestamp.now(),
        });
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorModal(
          context,
          message: 'Failed to save conversation: ${e.toString()}',
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _checkIfAllQuestionsAnswered() {
    // Count user responses
    int userMessageCount = 0;
    for (final message in _conversation) {
      if (message['sender'] == 'user') {
        userMessageCount++;
      }
    }

    // Check if all questions have been answered
    if (userMessageCount >= _deepQuestions.length) {
      setState(() {
        _allQuestionsAnswered = true;
      });
    }
  }

  // Replace your _showInputBottomSheet method:
  void _showInputBottomSheet() {
    setState(() => _isInputVisible = true);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7, // 70% height
      ),
      builder: (context) => _buildResponsiveBottomSheet(),
    ).then((_) {
      setState(() => _isInputVisible = false);
    });
  }

  // New responsive bottom sheet builder:
  Widget _buildResponsiveBottomSheet() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;

        return Container(
          width: double.infinity, // Full width
          height: MediaQuery.of(context).size.height * 0.7, // 70% height
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                isTablet ? AppDimensions.radiusXL : AppDimensions.radiusL,
              ),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: isTablet ? 16 : 12),
                width: isTablet ? 60 : 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(
                    isTablet
                        ? AppDimensions.paddingXXL
                        : AppDimensions.paddingL,
                  ),
                  child: _buildBottomSheetContent(isTablet),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Updated content with responsive parameters:
  Widget _buildBottomSheetContent(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Answer',
              style: AppTextStyles.heading3.copyWith(
                fontSize: isTablet ? 28 : 20,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: isTablet ? 28 : 24),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),

        SizedBox(height: isTablet ? 16 : 8),

        // Question reminder
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            color: AppColors.primarySageGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(
              color: AppColors.primarySageGreen.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            _deepQuestions[_currentQuestionIndex],
            style: AppTextStyles.bodyMedium.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.primarySageGreen,
              fontSize: isTablet ? 18 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        SizedBox(height: isTablet ? 24 : 16),

        // Input field
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(color: AppColors.borderPrimary, width: 1),
            ),
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              autofocus: true,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              textCapitalization: TextCapitalization.sentences,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: isTablet ? 18 : 16,
                height: 1.5,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText:
                    'Share your thoughts...\n\nTake your time to reflect on this question.',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMedium,
                  fontSize: isTablet ? 18 : 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(isTablet ? 24 : 16),
              ),
            ),
          ),
        ),

        SizedBox(height: isTablet ? 24 : 16),

        // Send button
        SizedBox(
          width: double.infinity,
          height: isTablet ? 60 : 56,
          child: CustomButton(
            text: 'Send Answer',
            onPressed: () => _addUserMessage(_textController.text),
            type: ButtonType.primary,
            icon: Icons.send,
          ),
        ),

        // Bottom padding for keyboard
        SizedBox(
          height:
              MediaQuery.of(context).viewInsets.bottom + (isTablet ? 16 : 8),
        ),
      ],
    );
  }

  Future<void> _continueToNextStep() async {
    // Navigate to the next step
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProfileAssessmentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Deeper Understanding'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Column(
                  children: [
                    // Step Indicator
                    const ProfileStepIndicator(currentStep: 6, totalSteps: 8),

                    // Introduction Card
                    Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: DelayedDisplay(
                        delay: const Duration(milliseconds: 100),
                        child: Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusL,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryDarkBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.psychology,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: AppDimensions.paddingM),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'AI Interviewer',
                                          style: AppTextStyles.heading3
                                              .copyWith(fontSize: 18),
                                        ),
                                        const SizedBox(
                                          height: AppDimensions.paddingXS,
                                        ),
                                        Text(
                                          'Let\'s explore some deeper questions',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: AppColors.textMedium,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimensions.paddingM),
                              Text(
                                'These questions will help us understand your relationship style and values. Your thoughtful responses will enhance our ability to find truly compatible matches for you.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.backgroundDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Chat content
                    Expanded(
                      child: GestureDetector(
                        onTap: () => FocusScope.of(context).unfocus(),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          itemCount:
                              _conversation.length + (_isSending ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Show typing indicator if sending
                            if (_isSending && index == _conversation.length) {
                              return DelayedDisplay(
                                delay: const Duration(milliseconds: 200),
                                child: const AIChatBubble(
                                  text: 'Thinking...',
                                  isTyping: true,
                                ),
                              );
                            }

                            final message = _conversation[index];
                            final isUser = message['sender'] == 'user';
                            final text = message['text'];

                            return DelayedDisplay(
                              delay: Duration(milliseconds: 200 * (index + 1)),
                              child:
                                  isUser
                                      ? UserChatBubble(text: text)
                                      : AIChatBubble(text: text),
                            );
                          },
                        ),
                      ),
                    ),

                    // Bottom Button Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      child:
                          _allQuestionsAnswered
                              ? DelayedDisplay(
                                delay: const Duration(milliseconds: 300),
                                child: Column(
                                  children: [
                                    Text(
                                      'You\'ve completed all the deep questions!',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.paddingM,
                                    ),
                                    CustomButton(
                                      text: 'Continue to Next Step',
                                      onPressed: _continueToNextStep,
                                      type: ButtonType.primary,
                                      icon: Icons.arrow_forward,
                                    ),
                                  ],
                                ),
                              )
                              : CustomButton(
                                text: 'Respond to Question',
                                onPressed: _showInputBottomSheet,
                                type: ButtonType.primary,
                                icon: Icons.message,
                                isFullWidth: true,
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}

// lib/features/courtship/widgets/courtship_journey_carousel.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

class CourtshipJourneyCarousel extends StatefulWidget {
  const CourtshipJourneyCarousel({super.key});

  @override
  State<CourtshipJourneyCarousel> createState() =>
      _CourtshipJourneyCarouselState();
}

class _CourtshipJourneyCarouselState extends State<CourtshipJourneyCarousel> {
  final PageController _stagesController = PageController();
  int _currentStageIndex = 0;

  @override
  void dispose() {
    _stagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        _buildHeader(),
        const SizedBox(height: 16),

        // Hero Images Carousel
        _buildHeroImagesCarousel(),
        const SizedBox(height: 16),

        // Stages Details Carousel
        _buildStagesCarousel(),

        // Page Indicators
        _buildPageIndicators(),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The Courtship Journey',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.primaryDarkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Four carefully designed stages over 14 days',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMedium),
        ),
      ],
    );
  }

  Widget _buildHeroImagesCarousel() {
    final heroImages = [
      'assets/images/courtship_journey_a.jpeg',
      'assets/images/courtship_journey_b.jpeg',
      'assets/images/courtship_journey_c.jpeg',
    ];

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: PageView.builder(
          controller: _stagesController,
          onPageChanged: (index) {
            setState(() {
              _currentStageIndex = index % _getStages().length;
            });
          },
          itemCount: heroImages.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryDarkBlue.withValues(alpha: 0.1),
                    AppColors.primarySageGreen.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.asset(
                      heroImages[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback gradient if image not found
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryDarkBlue.withValues(
                                  alpha: 0.2,
                                ),
                                AppColors.primaryGold.withValues(alpha: 0.2),
                                AppColors.primarySageGreen.withValues(
                                  alpha: 0.2,
                                ),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.favorite,
                              size: 60,
                              color: AppColors.primaryDarkBlue.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Overlay gradient for better text readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Journey Title Overlay
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '14 Days of Intentional Connection',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.primaryDarkBlue,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStagesCarousel() {
    final stages = _getStages();

    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _stagesController,
        onPageChanged: (index) {
          setState(() {
            _currentStageIndex = index;
          });
        },
        itemCount: stages.length,
        itemBuilder: (context, index) {
          final stage = stages[index];
          return Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryDarkBlue.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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
                      decoration: BoxDecoration(
                        color: _getStageColor(index).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        stage['icon'] as IconData,
                        color: _getStageColor(index),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stage ${index + 1}: ${stage['title']}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDarkBlue,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStageColor(
                                index,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              stage['days'] as String,
                              style: AppTextStyles.caption.copyWith(
                                color: _getStageColor(index),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Text(
                    stage['description'] as String,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryGold,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicators() {
    final stages = _getStages();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(stages.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _currentStageIndex == index ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color:
                _currentStageIndex == index
                    ? AppColors.primaryDarkBlue
                    : AppColors.primaryDarkBlue.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  List<Map<String, dynamic>> _getStages() {
    return [
      {
        'title': 'Introduction',
        'days': '3 days',
        'description':
            'Share core values and build initial connection through guided questions.',
        'icon': Icons.handshake_outlined,
      },
      {
        'title': 'Compatibility',
        'days': '4 days',
        'description':
            'Explore daily life compatibility, communication styles, and relationship approaches.',
        'icon': Icons.psychology_outlined,
      },
      {
        'title': 'Discovery',
        'days': '4 days',
        'description':
            'Meet in person and explore deeper life vision alignment.',
        'icon': Icons.explore_outlined,
      },
      {
        'title': 'Decision',
        'days': '3 days',
        'description':
            'Reflect on the journey and decide on next steps together.',
        'icon': Icons.dashboard_customize_outlined,
      },
    ];
  }

  Color _getStageColor(int index) {
    final colors = [
      AppColors.primaryDarkBlue, // Introduction
      AppColors.primaryGold, // Compatibility
      AppColors.primarySageGreen, // Discovery
      AppColors.primaryDarkBlue, // Decision
    ];
    return colors[index % colors.length];
  }
}

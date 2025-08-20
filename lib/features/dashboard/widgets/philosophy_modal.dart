// lib/features/dashboard/widgets/philosophy_modal.dart
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';

import '../../courtship/widgets/courtship_journey_widget.dart';
import 'philosophy_widgets/courtship_philosophy_widget.dart';
import 'philosophy_widgets/philosophy_hero_section.dart';
import 'philosophy_widgets/core_values_grid.dart';
import 'philosophy_widgets/philosophy_principles.dart';
import 'philosophy_widgets/philosophy_promise.dart';
import 'philosophy_widgets/philosophy_cta.dart';

class PhilosophyModal extends StatefulWidget {
  const PhilosophyModal({super.key});

  @override
  State<PhilosophyModal> createState() => _PhilosophyModalState();
}

class _PhilosophyModalState extends State<PhilosophyModal>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatingController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );
  }

  void _startAnimations() {
    _mainController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _floatingController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Manifesto Section
                  PhilosophyHeroSection(
                    scaleAnimation: _scaleAnimation,
                    floatingController: _floatingController,
                  ),

                  const SizedBox(height: 8),
                  CourtshipPhilosophyWidget(),
                  // Core Values Grid   const SizedBox(height: 16),
                  const CoreValuesGrid(),

                  const SizedBox(height: 16),

                  // Philosophy Principles
                  const PhilosophyPrinciples(),

                  const SizedBox(height: 24),
                  // Courtship Journey Carousel - Using the new widget
                  DelayedDisplay(
                    delay: const Duration(milliseconds: 400),
                    child: const CourtshipJourneyCarousel(),
                  ),

                  // The Promise Section
                  const PhilosophyPromise(),

                  const SizedBox(height: 24),

                  // Call to Action
                  const PhilosophyCTA(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Extract your existing PhilosophyModal content to this widget
class PhilosophyModalContent extends StatefulWidget {
  const PhilosophyModalContent({super.key});

  @override
  State<PhilosophyModalContent> createState() => _PhilosophyModalContentState();
}

class _PhilosophyModalContentState extends State<PhilosophyModalContent>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatingController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );
  }

  void _startAnimations() {
    _mainController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _floatingController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Manifesto Section
                PhilosophyHeroSection(
                  scaleAnimation: _scaleAnimation,
                  floatingController: _floatingController,
                ),

                const SizedBox(height: 8),
                CourtshipPhilosophyWidget(),

                const SizedBox(height: 16),
                // Core Values Grid
                const CoreValuesGrid(),

                const SizedBox(height: 16),

                // Philosophy Principles
                const PhilosophyPrinciples(),

                const SizedBox(height: 24),
                // Courtship Journey Carousel
                DelayedDisplay(
                  delay: const Duration(milliseconds: 400),
                  child: const CourtshipJourneyCarousel(),
                ),
                const SizedBox(height: 16),
                // The Promise Section
                const PhilosophyPromise(),

                const SizedBox(height: 24),

                // Call to Action
                const PhilosophyCTA(),
              ],
            ),
          ),
        );
      },
    );
  }
}

// lib/features/psychological_profile/data/psychology_questions_data.dart

import '../../../core/models/psych_question.dart';

class PsychologyQuestionsData {
  static List<PsychologyQuestion> getAllQuestions() {
    return [
      // Question 1: Problem-solving approach
      PsychologyQuestion(
        id: 'Q001',
        scenario:
            'Your best friend is getting married next month, and you\'re in the wedding party. Two weeks before the ceremony, they call you panicking. The venue just canceled due to a "booking error," and all other venues in town are booked. They\'re devastated and considering postponing the wedding indefinitely, which would affect guests who\'ve already bought flights and taken time off work.',
        optionA:
            'Drop everything and spend the entire weekend calling venues in neighboring cities, researching alternatives, and creating backup plans. Offer to help coordinate logistics and reassure your friend that you\'ll find a solution together.',
        optionB:
            'Give your friend space to process their emotions and make their own decisions. Offer to listen when they need to talk, but believe they need to figure out what feels right for them without outside pressure.',
        principleA: 'Action-Oriented Problem Solver',
        principleB: 'Emotional Support Provider',
        psychologicalDimension: 'crisis_response_style',
        readingTimeSeconds: 80,
      ),

      // Question 2: Risk tolerance
      PsychologyQuestion(
        id: 'Q002',
        scenario:
            'You inherit \$50,000 from a distant relative you barely knew. The money comes with a letter explaining it was saved specifically to help family members "take meaningful risks they otherwise couldn\'t afford." You have a stable job you moderately enjoy, some student debt, and have always wondered about starting your own business or traveling extensively.',
        optionA:
            'Invest the money conservatively, pay off debts, and use the remainder to build a solid emergency fund. Financial security creates opportunities for meaningful risks later when you\'re more prepared.',
        optionB:
            'Use the money to fund a passion project or experience you\'ve always dreamed about. Take a sabbatical to travel, start that business idea, or pursue an artistic endeavor you\'ve been putting off.',
        principleA: 'Security-First Planner',
        principleB: 'Experience-Driven Risk Taker',
        psychologicalDimension: 'risk_tolerance',
        readingTimeSeconds: 85,
      ),

      // Question 3: Communication style
      PsychologyQuestion(
        id: 'Q003',
        scenario:
            'You\'ve been dating someone for three months, and you really care about them. However, they have a habit that bothers you significantly—they\'re consistently 15-30 minutes late to everything, including dates you\'ve specifically planned. When you mention being ready to leave, they often say "just five more minutes" but it stretches much longer.',
        optionA:
            'Have a direct conversation about how their lateness affects you and the relationship. Explain specific examples and work together to find solutions that respect both of your needs and communication styles.',
        optionB:
            'Adjust your own expectations and planning to accommodate their timing. Build buffer time into plans and focus on enjoying their company rather than changing their natural rhythm.',
        principleA: 'Direct Communicator',
        principleB: 'Adaptive Accommodator',
        psychologicalDimension: 'communication_directness',
        readingTimeSeconds: 75,
      ),

      // Question 4: Energy management
      PsychologyQuestion(
        id: 'Q004',
        scenario:
            'It\'s Friday night after a demanding work week. Your close friend group is meeting at a new restaurant downtown—somewhere you\'ve wanted to try. But you\'re also feeling emotionally drained and know that socializing, while ultimately enjoyable, will require energy you\'re not sure you have.',
        optionA:
            'Push through the tiredness and go to dinner. Being with friends usually re-energizes you once you get there, and maintaining these relationships is important even when it requires effort.',
        optionB:
            'Stay home to recharge and suggest meeting up with friends individually over the next week when you can give them your full, present attention rather than showing up depleted.',
        principleA: 'Social Energizer',
        principleB: 'Solitary Recharger',
        psychologicalDimension: 'energy_management',
        readingTimeSeconds: 90,
      ),

      // Question 5: Career vs. life balance
      PsychologyQuestion(
        id: 'Q005',
        scenario:
            'You\'re offered a promotion at work that comes with significantly more responsibility, a 40% salary increase, and the opportunity to lead a team on projects you\'re passionate about. However, it would require 60+ hour work weeks for at least the first year, weekend availability, and would limit time for hobbies, relationships, and personal pursuits.',
        optionA:
            'Accept the promotion and fully commit to professional growth. Use this opportunity to establish your career trajectory and build financial security, knowing that personal time can be reclaimed later with a stronger foundation.',
        optionB:
            'Decline the promotion and prioritize work-life balance. Focus on finding fulfillment through relationships, hobbies, and personal growth rather than primarily through career advancement and financial gains.',
        principleA: 'Ambition-Driven Achiever',
        principleB: 'Balance-Focused Harmonizer',
        psychologicalDimension: 'achievement_orientation',
        readingTimeSeconds: 85,
      ),

      // Question 6: Conflict approach
      PsychologyQuestion(
        id: 'Q006',
        scenario:
            'Your family is having a reunion where extended relatives you see once a year will gather. Your cousin, who you love but who has very different political and social views, tends to bring up controversial topics and seems to enjoy debating. In the past, these conversations have led to tension and hurt feelings among family members.',
        optionA:
            'Engage thoughtfully in the conversations while steering toward finding common ground. Try to understand their perspective and share yours respectfully, believing that open dialogue strengthens relationships even when it\'s challenging.',
        optionB:
            'Redirect conversations toward neutral topics and focus on enjoying family time together. Prioritize harmony and connection over discussing differences, believing that some topics are better avoided in certain settings.',
        principleA: 'Dialogue Seeker',
        principleB: 'Harmony Preserver',
        psychologicalDimension: 'conflict_engagement',
        readingTimeSeconds: 80,
      ),

      // Question 7: Living priorities
      PsychologyQuestion(
        id: 'Q007',
        scenario:
            'You\'re moving to a new city and have two housing options that fit your budget. Option 1: A beautiful, spacious apartment in a quiet residential area with great amenities, but it\'s 45 minutes from downtown. Option 2: A smaller, older apartment in the heart of the city, walking distance to restaurants, galleries, and nightlife.',
        optionA:
            'Choose the quiet, spacious apartment and create a comfortable, organized home base. Invest in making your living space a sanctuary where you can entertain friends and enjoy privacy and peace.',
        optionB:
            'Choose the smaller downtown apartment and prioritize access to experiences, spontaneous social opportunities, and cultural engagement over personal space and comfort.',
        principleA: 'Sanctuary Seeker',
        principleB: 'Experience Maximizer',
        psychologicalDimension: 'lifestyle_priority',
        readingTimeSeconds: 85,
      ),

      // Question 8: Emotional boundaries
      PsychologyQuestion(
        id: 'Q008',
        scenario:
            'A close friend regularly vents to you about their job, relationship problems, and family drama. You care about them deeply, but lately, these conversations happen almost daily and can last hours. While you want to be supportive, you\'re starting to feel emotionally drained and notice it\'s affecting your own mood and productivity.',
        optionA:
            'Continue being available as their primary emotional support while finding ways to manage your own energy. Research better listening techniques and perhaps suggest you both engage in more positive activities together to balance the dynamic.',
        optionB:
            'Lovingly set boundaries around these conversations by limiting frequency or duration, and encourage your friend to diversify their support system or consider professional counseling for ongoing issues.',
        principleA: 'Caretaking Supporter',
        principleB: 'Boundary Setting Protector',
        psychologicalDimension: 'emotional_boundaries',
        readingTimeSeconds: 90,
      ),

      // Question 9: Planning vs. spontaneity
      PsychologyQuestion(
        id: 'Q009',
        scenario:
            'A friend invites you to join them on a month-long backpacking trip through Southeast Asia, departing in six weeks. The trip would be relatively affordable since you\'d be staying in hostels and traveling budget-style. However, you\'d need to take unpaid leave from work, cancel existing commitments, and wouldn\'t have much time to research or plan details.',
        optionA:
            'Book the trip immediately and figure out the details as you go. Embrace the spontaneity and trust that the experience will be enriching even if everything doesn\'t go according to plan.',
        optionB:
            'Decline this particular trip but start planning a similar adventure for next year when you can properly research destinations, save additional money, and arrange time off without professional consequences.',
        principleA: 'Spontaneous Adventurer',
        principleB: 'Strategic Planner',
        psychologicalDimension: 'planning_approach',
        readingTimeSeconds: 85,
      ),

      // Question 10: Relationship pacing
      PsychologyQuestion(
        id: 'Q010',
        scenario:
            'You\'ve been seeing someone wonderful for two months. The connection feels natural and promising, and you\'ve both expressed genuine interest in each other. They\'ve mentioned wanting to introduce you to their close friends and has suggested planning a weekend trip together. While you\'re excited about the relationship\'s potential, you also value taking time to really know someone.',
        optionA:
            'Embrace the natural progression and meet their friends and plan the weekend trip. Trust your instincts about this person and allow the relationship to develop at the pace that feels right for both of you in the moment.',
        optionB:
            'Express appreciation for their enthusiasm while suggesting a slightly slower pace. Explain that you prefer to build intimacy gradually and would like more one-on-one time before expanding into group settings and travel.',
        principleA: 'Intuitive Flow Follower',
        principleB: 'Deliberate Pace Setter',
        psychologicalDimension: 'relationship_pacing',
        readingTimeSeconds: 85,
      ),

      // Question 11: Decision making style
      PsychologyQuestion(
        id: 'Q011',
        scenario:
            'You\'re considering buying a car and have researched extensively. You\'ve found two options: one is a reliable, well-reviewed model that meets all your practical needs perfectly but doesn\'t particularly excite you. The other is a slightly less practical but more stylish car that makes you genuinely happy when you see it, though it has mixed reviews and costs a bit more.',
        optionA:
            'Choose the practical, reliable option. Make decisions based on logical analysis, long-term value, and proven performance rather than emotional response or aesthetic appeal.',
        optionB:
            'Choose the car that makes you happy. Trust that emotional connection and daily joy matter more than perfect practicality, and that you\'ll find ways to manage any practical challenges.',
        principleA: 'Logic-Driven Decider',
        principleB: 'Emotion-Guided Chooser',
        psychologicalDimension: 'decision_making_style',
        readingTimeSeconds: 75,
      ),

      // Question 12: Social dynamics
      PsychologyQuestion(
        id: 'Q012',
        scenario:
            'You\'re at a party where you know the host but few other people. You notice someone sitting alone who looks a bit uncomfortable and out of place. At the same time, there\'s a lively group conversation happening nearby about a topic you\'re passionate about and would love to join.',
        optionA:
            'Approach the person sitting alone and strike up a conversation. Focus on making them feel welcomed and included, believing that helping others feel comfortable is more important than your own entertainment.',
        optionB:
            'Join the group conversation about the topic you\'re passionate about. Engage authentically in what energizes you, trusting that genuine enthusiasm contributes positive energy to the social environment.',
        principleA: 'Inclusive Caretaker',
        principleB: 'Authentic Engager',
        psychologicalDimension: 'social_approach',
        readingTimeSeconds: 80,
      ),

      // Question 13: Change adaptation
      PsychologyQuestion(
        id: 'Q013',
        scenario:
            'Your company announces a major restructuring that will significantly change your role, team, and daily responsibilities. While your job security isn\'t threatened, the work environment and processes you\'ve grown comfortable with will be completely different. Some colleagues are excited about the changes, while others are worried and resistant.',
        optionA:
            'Embrace the change as an opportunity for growth and new experiences. Focus on the potential benefits and approach the transition with curiosity about what you might learn and how you might develop new skills.',
        optionB:
            'Acknowledge the change while focusing on maintaining stability where possible. Take time to process the transition, preserve valuable aspects of the current system, and adapt gradually rather than rushing into the new way of doing things.',
        principleA: 'Change Embracer',
        principleB: 'Stability Seeker',
        psychologicalDimension: 'change_adaptation',
        readingTimeSeconds: 85,
      ),

      // Question 14: Competition vs. collaboration
      PsychologyQuestion(
        id: 'Q014',
        scenario:
            'You\'re working on a group project at work where individual contributions will be evaluated for a potential promotion. You have an idea that could significantly improve the project\'s success, but sharing it openly means others might get credit, while keeping it to yourself could make your individual contribution stand out more.',
        optionA:
            'Share your idea with the team and work collaboratively to implement it effectively. Focus on the project\'s overall success and trust that your contributions will be recognized through the collaborative process.',
        optionB:
            'Develop your idea independently and present it as your individual contribution. Focus on distinguishing your work and ensuring your efforts are clearly attributed to you in the evaluation process.',
        principleA: 'Collaborative Team Builder',
        principleB: 'Individual Achievement Focuser',
        psychologicalDimension: 'competition_approach',
        readingTimeSeconds: 80,
      ),

      // Question 15: Emotional expression
      PsychologyQuestion(
        id: 'Q015',
        scenario:
            'You\'re going through a difficult time personally—perhaps a family issue or health concern that\'s weighing on you heavily. Your friends and colleagues have noticed you seem different lately. You have the option to open up about what you\'re experiencing or to handle it privately while maintaining your usual social demeanor.',
        optionA:
            'Open up to trusted friends and family about what you\'re going through. Share your feelings and accept support, believing that vulnerability strengthens relationships and that community support helps during difficult times.',
        optionB:
            'Handle the situation privately while maintaining your usual social interactions. Work through your feelings independently, believing that processing internally first allows you to maintain stability for others and approach relationships from a position of strength.',
        principleA: 'Open Vulnerability Sharer',
        principleB: 'Private Strength Maintainer',
        psychologicalDimension: 'emotional_expression',
        readingTimeSeconds: 85,
      ),

      // Question 16: Learning style
      PsychologyQuestion(
        id: 'Q016',
        scenario:
            'You want to learn a new skill that interests you—perhaps cooking, a musical instrument, or a language. You have the choice between taking a structured class with a curriculum and teacher, or exploring and learning independently through books, videos, and experimentation at your own pace.',
        optionA:
            'Enroll in a structured class with an instructor and fellow students. Benefit from expert guidance, structured progression, and the motivation that comes from scheduled commitments and group learning.',
        optionB:
            'Learn independently through self-directed exploration. Set your own pace, follow your curiosity, and develop your own understanding through experimentation and diverse resources.',
        principleA: 'Structured Learning Seeker',
        principleB: 'Independent Explorer',
        psychologicalDimension: 'learning_approach',
        readingTimeSeconds: 75,
      ),

      // Question 17: Future planning
      PsychologyQuestion(
        id: 'Q017',
        scenario:
            'You\'re thinking about where you want to be in five years. You can approach this by creating detailed goals, timelines, and plans for your career, relationships, and personal development. Alternatively, you can focus on cultivating qualities and skills that will help you adapt to whatever opportunities and challenges arise.',
        optionA:
            'Create specific, measurable goals and develop detailed plans for achieving them. Set clear timelines and milestones, believing that intentional planning and consistent progress toward defined objectives leads to the most fulfilling outcomes.',
        optionB:
            'Focus on personal growth and developing adaptability rather than specific outcomes. Cultivate skills, relationships, and inner resources that will serve you well regardless of how circumstances change.',
        principleA: 'Goal-Oriented Planner',
        principleB: 'Adaptive Growth Focuser',
        psychologicalDimension: 'future_orientation',
        readingTimeSeconds: 80,
      ),

      // Question 18: Authority approach
      PsychologyQuestion(
        id: 'Q018',
        scenario:
            'You\'re in a meeting where a senior colleague presents an idea that has significant flaws you can clearly see. The meeting includes your boss and other senior team members. You know your input could improve the proposal substantially, but pointing out the issues might make the presenter look bad in front of leadership.',
        optionA:
            'Respectfully raise your concerns and suggestions in the meeting. Focus on improving the outcome and trust that constructive feedback, even if challenging, ultimately serves everyone\'s best interests.',
        optionB:
            'Approach the presenter privately after the meeting to share your thoughts. Preserve their dignity in the group setting while still ensuring your insights contribute to better decision-making.',
        principleA: 'Direct Truth Teller',
        principleB: 'Diplomatic Influencer',
        psychologicalDimension: 'authority_interaction',
        readingTimeSeconds: 85,
      ),

      // Question 19: Leisure preferences
      PsychologyQuestion(
        id: 'Q019',
        scenario:
            'You have a completely free weekend with no obligations. You can spend it however you choose. You\'re considering between having an active, social weekend filled with various activities, events, and time with different people, or having a peaceful, restorative weekend focused on solitary activities, reflection, and personal projects.',
        optionA:
            'Plan an active, social weekend with friends, activities, and new experiences. Visit that new museum, meet friends for brunch, attend a social event, and pack the weekend with stimulating interactions and adventures.',
        optionB:
            'Enjoy a peaceful, restorative weekend focused on personal time. Read that book you\'ve been meaning to get to, work on a creative project, take long walks, and recharge through solitude and quiet activities.',
        principleA: 'Stimulation Seeker',
        principleB: 'Restoration Prioritizer',
        psychologicalDimension: 'leisure_preference',
        readingTimeSeconds: 80,
      ),

      // Question 20: Values expression
      PsychologyQuestion(
        id: 'Q020',
        scenario:
            'You discover that a company you regularly support through purchases has practices that conflict with your personal values—perhaps environmental policies or labor practices that concern you. The company\'s products or services are convenient and well-integrated into your life, and alternatives are less convenient or more expensive.',
        optionA:
            'Immediately stop supporting the company and find alternatives, even if it\'s less convenient or more expensive. Align your actions with your values consistently, believing that personal integrity requires making difficult choices when necessary.',
        optionB:
            'Gradually transition away while finding practical alternatives that work for your situation. Balance your values with practical considerations, believing that sustainable change happens through thoughtful adaptation rather than sudden disruption.',
        principleA: 'Principled Action Taker',
        principleB: 'Pragmatic Value Balancer',
        psychologicalDimension: 'values_expression',
        readingTimeSeconds: 85,
      ),
    ];
  }

  static List<PsychologyQuestion> getRandomQuestions(int count) {
    final allQuestions = getAllQuestions();
    allQuestions.shuffle();
    return allQuestions.take(count).toList();
  }
}

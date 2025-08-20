// lib/features/worldview_assessment/data/worldview_questions_data.dart

import '../../core/models/worldview_question.dart';

class WorldviewQuestionsData {
  static List<WorldviewQuestion> getAllQuestions() {
    return [
      // Question 1: Government role in society
      WorldviewQuestion(
        id: 'WV001',
        scenario:
            'Your city is facing a housing affordability crisis. Young professionals and families are being priced out, while some neighborhoods have become unaffordable even for middle-class residents. The city council is debating two main approaches to address this issue.',
        optionA:
            'The government should implement rent control policies, require developers to include affordable housing units, and increase public housing development funded by higher taxes on luxury properties.',
        optionB:
            'The city should reduce zoning restrictions, streamline building permits, and offer tax incentives to private developers to increase housing supply, trusting market forces to eventually lower prices.',
        worldviewA: 'Government Intervention Advocate',
        worldviewB: 'Free Market Believer',
        valuesDimension: 'government_role',
        dealBreakerLevel: 'high',
        readingTimeSeconds: 85,
      ),

      // Question 2: Economic inequality approach
      WorldviewQuestion(
        id: 'WV002',
        scenario:
            'You learn that the CEO of a major company in your area makes 400 times more than the median worker salary, while some employees qualify for government assistance despite working full-time. This disparity has become a topic of local discussion and debate.',
        optionA:
            'This level of inequality is fundamentally unjust and harmful to society. Wealth should be redistributed through progressive taxation, higher minimum wages, and stronger worker protections to ensure everyone can live with dignity.',
        optionB:
            'Income differences reflect different levels of skill, risk-taking, and value creation. Successful individuals and companies should keep most of their earnings, as this incentivizes innovation and economic growth that benefits everyone.',
        worldviewA: 'Economic Equality Advocate',
        worldviewB: 'Meritocracy Defender',
        valuesDimension: 'economic_philosophy',
        dealBreakerLevel: 'high',
        readingTimeSeconds: 80,
      ),

      // Question 3: Climate change response
      WorldviewQuestion(
        id: 'WV003',
        scenario:
            'Your country is developing its energy policy for the next 20 years. Climate scientists warn of severe consequences if carbon emissions aren\'t dramatically reduced, while economists warn that rapid changes could disrupt industries and cost jobs in certain regions.',
        optionA:
            'We must prioritize immediate, aggressive action on climate change, including banning fossil fuel extraction, mandating renewable energy transitions, and accepting short-term economic disruption to prevent environmental catastrophe.',
        optionB:
            'We should pursue gradual, market-driven solutions that balance environmental concerns with economic stability, supporting innovation in clean technology while not destroying existing industries and jobs overnight.',
        worldviewA: 'Climate Emergency Activist',
        worldviewB: 'Balanced Transition Advocate',
        valuesDimension: 'environmental_priority',
        dealBreakerLevel: 'high',
        readingTimeSeconds: 85,
      ),

      // Question 4: Social change pace
      WorldviewQuestion(
        id: 'WV004',
        scenario:
            'Your community is discussing how to address historical inequalities and modernize social institutions. Some advocate for rapid, comprehensive changes to systems and traditions, while others prefer gradual evolution that honors existing structures while making improvements.',
        optionA:
            'Social justice requires dismantling systems that perpetuate inequality, even if it means rapid changes to traditional institutions. Progress demands challenging existing power structures and making bold reforms quickly.',
        optionB:
            'Lasting change comes through gradual reform that builds on existing foundations. Preserving valuable traditions while making thoughtful improvements creates more stable and widely accepted progress.',
        worldviewA: 'Revolutionary Progressive',
        worldviewB: 'Evolutionary Conservative',
        valuesDimension: 'social_change_pace',
        dealBreakerLevel: 'medium',
        readingTimeSeconds: 80,
      ),

      // Question 5: Individual vs. collective responsibility
      WorldviewQuestion(
        id: 'WV005',
        scenario:
            'A talented student from a low-income family can\'t afford college, while another student from a wealthy family struggles academically but has every educational advantage. This highlights broader questions about opportunity and responsibility in society.',
        optionA:
            'Society has failed both students - one by not providing equal opportunities, the other by not teaching the value of effort. We need systemic changes to ensure everyone has fair access to education and support.',
        optionB:
            'Both students are primarily responsible for their own outcomes. The talented student can find scholarships and loans, while the struggling student needs to work harder. Personal effort matters more than circumstances.',
        worldviewA: 'Systemic Responsibility Advocate',
        worldviewB: 'Individual Accountability Believer',
        valuesDimension: 'responsibility_attribution',
        dealBreakerLevel: 'high',
        readingTimeSeconds: 85,
      ),

      // Question 6: Cultural diversity approach
      WorldviewQuestion(
        id: 'WV006',
        scenario:
            'Your city has become increasingly diverse, with many new immigrants bringing different languages, religious practices, and cultural traditions. Some residents celebrate this diversity, while others worry about community cohesion and shared values.',
        optionA:
            'Cultural diversity strengthens our community by bringing new perspectives, skills, and traditions. We should actively celebrate differences and adapt our institutions to be more inclusive of all cultural backgrounds.',
        optionB:
            'While welcoming newcomers, we should emphasize shared values and common culture that unite us. Immigrants should adapt to existing community standards while maintaining their private cultural practices.',
        worldviewA: 'Multiculturalism Champion',
        worldviewB: 'Cultural Integration Advocate',
        valuesDimension: 'cultural_approach',
        dealBreakerLevel: 'medium',
        readingTimeSeconds: 85,
      ),

      // Question 7: Technology and privacy
      WorldviewQuestion(
        id: 'WV007',
        scenario:
            'A major tech company wants to implement facial recognition cameras throughout your city to reduce crime and improve emergency response. The technology is effective but requires collecting and storing biometric data on all residents and visitors.',
        optionA:
            'Privacy is a fundamental right that shouldn\'t be sacrificed for security. The risks of surveillance and data misuse outweigh the potential benefits, and people should be free from constant monitoring.',
        optionB:
            'Public safety justifies reasonable surveillance measures. If the technology prevents crime and saves lives while being properly regulated, the community benefit outweighs individual privacy concerns.',
        worldviewA: 'Privacy Rights Defender',
        worldviewB: 'Security First Pragmatist',
        valuesDimension: 'privacy_vs_security',
        dealBreakerLevel: 'medium',
        readingTimeSeconds: 80,
      ),

      // Question 8: Education philosophy
      WorldviewQuestion(
        id: 'WV008',
        scenario:
            'Your local school district is redesigning its curriculum. One proposal emphasizes critical thinking about social issues, systemic inequalities, and diverse perspectives. Another focuses on core academic skills, traditional subjects, and preparing students for economic success.',
        optionA:
            'Education should primarily develop critical consciousness about social justice, inequality, and systems of power. Students need to understand how to challenge unfairness and create a more equitable society.',
        optionB:
            'Education should focus on fundamental skills, knowledge, and preparing students to succeed economically. Schools should teach facts and skills rather than promoting particular political or social viewpoints.',
        worldviewA: 'Critical Education Advocate',
        worldviewB: 'Traditional Learning Supporter',
        valuesDimension: 'education_philosophy',
        dealBreakerLevel: 'medium',
        readingTimeSeconds: 85,
      ),

      // Question 9: Justice system approach
      WorldviewQuestion(
        id: 'WV009',
        scenario:
            'Your community is experiencing rising crime rates, particularly theft and drug-related offenses. Local leaders are debating whether to focus resources on enforcement and punishment or on addressing root causes through social programs and rehabilitation.',
        optionA:
            'Crime stems from poverty, inequality, and lack of opportunity. Invest in education, mental health services, job training, and addiction treatment to address root causes rather than just punishing symptoms.',
        optionB:
            'Strong enforcement and appropriate consequences deter crime and protect law-abiding citizens. Focus on effective policing, swift prosecution, and ensuring that criminal behavior has clear, consistent consequences.',
        worldviewA: 'Restorative Justice Advocate',
        worldviewB: 'Law and Order Supporter',
        valuesDimension: 'justice_philosophy',
        dealBreakerLevel: 'high',
        readingTimeSeconds: 85,
      ),

      // Question 10: Family structure values
      WorldviewQuestion(
        id: 'WV010',
        scenario:
            'Census data shows your area has increasingly diverse family structures: single parents, blended families, multigenerational households, same-sex parents, and child-free couples. Community organizations are deciding how to design programs and messaging.',
        optionA:
            'All family structures are equally valid and should be celebrated. Programs should be inclusive of diverse arrangements and challenge traditional assumptions about what constitutes a "normal" family.',
        optionB:
            'While respecting all families, traditional two-parent households provide the most stable environment for raising children. Programs should support all families while recognizing the benefits of traditional structures.',
        worldviewA: 'Family Diversity Celebrant',
        worldviewB: 'Traditional Family Supporter',
        valuesDimension: 'family_values',
        dealBreakerLevel: 'medium',
        readingTimeSeconds: 85,
      ),

      // Question 11: Religious role in public life
      WorldviewQuestion(
        id: 'WV011',
        scenario:
            'Your town council meetings have traditionally opened with a religious prayer, but the community has become more religiously diverse, including many non-religious residents. There\'s debate about whether to continue this practice, modify it, or end it.',
        optionA:
            'Religious expressions should be kept out of government functions to ensure separation of church and state. Public institutions should remain neutral and inclusive of all beliefs, including non-religious perspectives.',
        optionB:
            'Religious traditions are part of our cultural heritage and provide moral grounding for civic life. Public acknowledgment of faith, done respectfully, strengthens community values and shouldn\'t be erased.',
        worldviewA: 'Secular Governance Advocate',
        worldviewB: 'Faith-Informed Civic Life Supporter',
        valuesDimension: 'religion_public_role',
        dealBreakerLevel: 'medium',
        readingTimeSeconds: 80,
      ),

      // Question 12: International engagement
      WorldviewQuestion(
        id: 'WV012',
        scenario:
            'Your country is deciding how to respond to a humanitarian crisis in another region where civilians are suffering due to conflict. Options range from military intervention to humanitarian aid to focusing on domestic priorities instead.',
        optionA:
            'We have a moral obligation to help people suffering anywhere in the world. International cooperation, foreign aid, and even military intervention can be justified to protect human rights and prevent atrocities.',
        optionB:
            'Our primary responsibility is to our own citizens. While humanitarian aid is good, we shouldn\'t risk our resources or military in foreign conflicts when we have problems to solve at home.',
        worldviewA: 'Global Humanitarian Interventionist',
        worldviewB: 'National Interest Prioritizer',
        valuesDimension: 'international_engagement',
        dealBreakerLevel: 'medium',
        readingTimeSeconds: 85,
      ),

      // Question 13: Success and achievement
      WorldviewQuestion(
        id: 'WV013',
        scenario:
            'Two people grew up in the same neighborhood. One became very successful through a combination of natural talent, hard work, and lucky breaks. The other worked equally hard but faced setbacks due to health issues and family obligations, and struggles financially.',
        optionA:
            'Success largely depends on circumstances beyond individual control - privilege, luck, systemic barriers, and social support. Society should redistribute resources to ensure everyone has genuine opportunity regardless of background.',
        optionB:
            'While circumstances matter, individual choices, work ethic, and personal responsibility are the primary determinants of success. People should be able to keep what they earn through their efforts and decisions.',
        worldviewA: 'Systemic Advantage Recognizer',
        worldviewB: 'Personal Agency Emphasizer',
        valuesDimension: 'success_attribution',
        dealBreakerLevel: 'high',
        readingTimeSeconds: 85,
      ),

      // Question 14: Authority and tradition
      WorldviewQuestion(
        id: 'WV014',
        scenario:
            'A local institution with a 150-year history is facing criticism for outdated practices that some consider exclusionary or harmful. Leaders must decide whether to make major changes to align with modern values or preserve traditions that have worked for generations.',
        optionA:
            'Institutions must evolve with changing social understanding. Even valuable traditions should be reformed or abandoned if they cause harm or exclude people, regardless of their historical significance.',
        optionB:
            'Time-tested institutions and traditions have proven their worth and provide stability. Changes should be made carefully and gradually, preserving what works while making minimal necessary adjustments.',
        worldviewA: 'Progressive Reform Advocate',
        worldviewB: 'Traditional Institution Preserver',
        valuesDimension: 'tradition_vs_progress',
        dealBreakerLevel: 'medium',
        readingTimeSeconds: 80,
      ),

      // Question 15: Personal responsibility vs. social support
      WorldviewQuestion(
        id: 'WV015',
        scenario:
            'Your friend has been unemployed for eight months despite applying for jobs. They\'re considering accepting government assistance for housing and food, but they feel conflicted about it. Some people say they should take any job, while others say they deserve support.',
        optionA:
            'Social safety nets exist for exactly this situation. Everyone deserves housing, food, and dignity while seeking appropriate employment. Government assistance prevents desperation and allows people to find suitable work.',
        optionB:
            'While temporary help can be appropriate, long-term assistance creates dependency. Your friend should take any available job, even if it\'s not ideal, and work their way up rather than relying on government support.',
        worldviewA: 'Social Safety Net Supporter',
        worldviewB: 'Self-Reliance Advocate',
        valuesDimension: 'social_support_philosophy',
        dealBreakerLevel: 'high',
        readingTimeSeconds: 85,
      ),

      // Question 16: Business regulation approach
      WorldviewQuestion(
        id: 'WV016',
        scenario:
            'A popular rideshare company wants to expand in your city, but existing taxi drivers say it will destroy their livelihoods because the company doesn\'t follow the same regulations they do. City officials must decide how to handle this disruption.',
        optionA:
            'Innovation and consumer choice should drive the market. Outdated regulations shouldn\'t protect established businesses from competition. Let consumers decide which service provides better value.',
        optionB:
            'Regulations exist to ensure fair competition, worker protections, and service standards. New companies should follow the same rules as existing businesses, or regulations should be updated to apply equally to all.',
        worldviewA: 'Market Innovation Supporter',
        worldviewB: 'Fair Competition Regulator',
        valuesDimension: 'business_regulation',
        dealBreakerLevel: 'medium',
        readingTimeSeconds: 85,
      ),

      // Question 17: Community identity and change
      WorldviewQuestion(
        id: 'WV017',
        scenario:
            'Your long-established neighborhood is experiencing rapid change - new businesses, rising property values, and an influx of higher-income residents. Long-time residents worry about losing their community character and being displaced.',
        optionA:
            'Gentrification displaces communities and destroys cultural identity. Implement policies to prevent displacement, preserve affordable housing, and prioritize the needs of existing residents over newcomers and developers.',
        optionB:
            'Neighborhood improvement brings better services, safety, and opportunities. Change is natural in dynamic communities, and rising property values benefit existing homeowners while attracting investment.',
        worldviewA: 'Anti-Gentrification Activist',
        worldviewB: 'Development Progress Supporter',
        valuesDimension: 'community_change',
        dealBreakerLevel: 'medium',
        readingTimeSeconds: 85,
      ),

      // Question 18: Information and truth
      WorldviewQuestion(
        id: 'WV018',
        scenario:
            'Social media platforms are struggling with misinformation that can harm public health and democratic processes. Some propose strict content moderation and fact-checking, while others worry about censorship and who decides what\'s "true."',
        optionA:
            'Platforms should aggressively remove misinformation and promote authoritative sources, even if some legitimate viewpoints get censored. The harm from false information outweighs concerns about limiting speech.',
        optionB:
            'Free speech is fundamental, and censorship is dangerous even with good intentions. People should be exposed to diverse viewpoints and make their own judgments rather than having information filtered by platforms.',
        worldviewA: 'Information Quality Controller',
        worldviewB: 'Free Speech Absolutist',
        valuesDimension: 'information_control',
        dealBreakerLevel: 'medium',
        readingTimeSeconds: 85,
      ),

      // Question 19: Gender and society
      WorldviewQuestion(
        id: 'WV019',
        scenario:
            'A local organization is updating its policies around gender identity, including restroom access, sports participation, and pronoun usage. Community members have different views on how to balance inclusion, safety, and traditional gender concepts.',
        optionA:
            'Gender identity is personal and should be respected in all contexts. Organizations should update policies to fully include transgender individuals in all activities based on their identified gender, even when it challenges traditional practices.',
        optionB:
            'While treating everyone with respect, biological sex matters in certain contexts like sports and private facilities. Policies should balance inclusion with concerns about fairness and safety for all participants.',
        worldviewA: 'Gender Identity Affirmer',
        worldviewB: 'Biological Reality Acknowledger',
        valuesDimension: 'gender_philosophy',
        dealBreakerLevel: 'high',
        readingTimeSeconds: 85,
      ),

      // Question 20: Future orientation and risk
      WorldviewQuestion(
        id: 'WV020',
        scenario:
            'Your city is planning for the next 50 years amid uncertainty about climate change, technology, and social change. Planners debate whether to make bold, transformative investments or focus on adaptable, proven approaches.',
        optionA:
            'The scale of future challenges requires radical transformation now. Make bold investments in new technologies, social systems, and infrastructure, even if they\'re unproven, because incremental change won\'t be sufficient.',
        optionB:
            'Uncertainty demands flexibility and proven approaches. Focus on adaptable solutions that have worked in the past, make gradual improvements, and avoid risky bets that could waste resources or make things worse.',
        worldviewA: 'Transformational Risk Taker',
        worldviewB: 'Cautious Incrementalist',
        valuesDimension: 'future_planning_approach',
        dealBreakerLevel: 'low',
        readingTimeSeconds: 85,
      ),
    ];
  }

  static List<WorldviewQuestion> getRandomQuestions(int count) {
    final allQuestions = getAllQuestions();
    allQuestions.shuffle();
    return allQuestions.take(count).toList();
  }
}

// lib/features/worldview_assessment/services/worldview_service.dart

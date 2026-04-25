import 'package:flutter/material.dart';

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({super.key});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  final PageController _pageController = PageController();
  int _currentQuestionIndex = 0;
  final Map<int, String?> _answers = {};

  final List<Question> _questions = [
    // Personal Information
    Question(
      category: 'Personal Information',
      question: 'What is your age?',
      type: QuestionType.singleChoice,
      options: ['18-24', '25-35', '36-45', '46-55', '56-65', 'Over 65'],
      isCritical: true,
    ),
    Question(
      category: 'Personal Information',
      question: 'What is your weight?',
      type: QuestionType.singleChoice,
      options: ['Less than 50 kg', '50-60 kg', '61-70 kg', '71-80 kg', '81-90 kg', 'Over 90 kg'],
      isCritical: true,
    ),

    // General Health
    Question(
      category: 'General Health',
      question: 'Are you currently in good health?',
      type: QuestionType.yesNo,
      isCritical: true,
    ),
    Question(
      category: 'General Health',
      question: 'Have you had any major surgery in the last 6 months?',
      type: QuestionType.yesNo,
      isCritical: true,
    ),
    Question(
      category: 'General Health',
      question: 'Do you have any chronic diseases? (Diabetes, Cancer, HIV, etc.)',
      type: QuestionType.yesNo,
      isCritical: true,
    ),

    // Recent Activities
    Question(
      category: 'Recent Activities',
      question: 'Have you gotten a tattoo or piercing in the last 6 months?',
      type: QuestionType.yesNo,
      isCritical: true,
    ),
    Question(
      category: 'Recent Activities',
      question: 'Have you traveled to any malaria-endemic areas in the last 12 months?',
      type: QuestionType.yesNo,
      isCritical: true,
    ),
    Question(
      category: 'Recent Activities',
      question: 'Have you received a blood transfusion in the last 12 months?',
      type: QuestionType.yesNo,
      isCritical: true,
    ),

    // Medications
    Question(
      category: 'Medications',
      question: 'Are you currently taking any medications?',
      type: QuestionType.singleChoice,
      options: [
        'No medications',
        'Antibiotics (completed course)',
        'Aspirin/Blood thinners',
        'Blood pressure medication',
        'Other chronic medication'
      ],
      isCritical: true,
    ),

    // Lifestyle
    Question(
      category: 'Lifestyle',
      question: 'Do you smoke?',
      type: QuestionType.singleChoice,
      options: ['No', 'Occasionally', 'Regularly (1-10/day)', 'Heavy smoker (10+/day)'],
      isCritical: false,
    ),
    Question(
      category: 'Lifestyle',
      question: 'Have you consumed alcohol in the last 24 hours?',
      type: QuestionType.yesNo,
      isCritical: true,
    ),

    // Pregnancy (for females)
    Question(
      category: 'Health History',
      question: 'Are you currently pregnant or breastfeeding?',
      type: QuestionType.yesNo,
      isCritical: true,
      showIf: [Gender.female],
    ),
    Question(
      category: 'Health History',
      question: 'Have you been pregnant in the last 12 months?',
      type: QuestionType.yesNo,
      isCritical: true,
      showIf: [Gender.female],
    ),

    // Recent Illness
    Question(
      category: 'Health History',
      question: 'Have you had a cold, flu, or fever in the last 7 days?',
      type: QuestionType.yesNo,
      isCritical: true,
    ),
    Question(
      category: 'Health History',
      question: 'Have you had any vaccinations in the last 8 weeks?',
      type: QuestionType.singleChoice,
      options: ['No vaccinations', 'COVID-19 vaccine', 'Flu vaccine', 'Other vaccine'],
      isCritical: true,
    ),

    // High-Risk Behaviors
    Question(
      category: 'Safety',
      question: 'Have you ever used injected drugs?',
      type: QuestionType.yesNo,
      isCritical: true,
    ),
    Question(
      category: 'Safety',
      question: 'Have you had intimate contact with anyone at risk for HIV/AIDS?',
      type: QuestionType.yesNo,
      isCritical: true,
    ),

    // Sleep & Food
    Question(
      category: 'Preparation',
      question: 'Did you sleep at least 6 hours last night?',
      type: QuestionType.yesNo,
      isCritical: false,
    ),
    Question(
      category: 'Preparation',
      question: 'Have you eaten a healthy meal today?',
      type: QuestionType.yesNo,
      isCritical: false,
    ),
  ];

  int _getProgress() {
    return ((_currentQuestionIndex + 1) / _questions.length * 100).round();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showResults();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _selectAnswer(String answer) {
    setState(() {
      _answers[_currentQuestionIndex] = answer;
    });

    // Auto-advance after a short delay
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        _nextQuestion();
      }
    });
  }

  void _showResults() {
    final results = _evaluateEligibility();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionnaireResultPage(
          result: results,
          answers: _answers,
          questions: _questions,
        ),
      ),
    );
  }

  EligibilityResult _evaluateEligibility() {
    int disqualifyingAnswers = 0;
    List<String> reasons = [];

    // Check age
    final ageAnswer = _answers[0];
    if (ageAnswer == 'Over 65') {
      disqualifyingAnswers++;
      reasons.add('Age over 65 requires medical approval');
    }

    // Check weight
    final weightAnswer = _answers[1];
    if (weightAnswer == 'Less than 50 kg') {
      disqualifyingAnswers++;
      reasons.add('Weight must be at least 50 kg');
    }

    // Check good health
    if (_answers[2] == 'No') {
      disqualifyingAnswers++;
      reasons.add('Must be in good health to donate');
    }

    // Check recent surgery
    if (_answers[3] == 'Yes') {
      disqualifyingAnswers++;
      reasons.add('Recent surgery requires 6-month waiting period');
    }

    // Check chronic diseases
    if (_answers[4] == 'Yes') {
      disqualifyingAnswers++;
      reasons.add('Chronic diseases may temporarily disqualify donation');
    }

    // Check tattoo/piercing
    if (_answers[5] == 'Yes') {
      disqualifyingAnswers++;
      reasons.add('Recent tattoo/piercing requires 6-month waiting period');
    }

    // Check travel to malaria areas
    if (_answers[6] == 'Yes') {
      disqualifyingAnswers++;
      reasons.add('Travel to malaria-endemic areas requires 12-month waiting period');
    }

    // Check blood transfusion
    if (_answers[7] == 'Yes') {
      disqualifyingAnswers++;
      reasons.add('Recent blood transfusion requires 12-month waiting period');
    }

    // Check medications
    final medicationAnswer = _answers[8];
    if (medicationAnswer != null && medicationAnswer.contains('Blood thinners')) {
      disqualifyingAnswers++;
      reasons.add('Blood thinners require medical consultation');
    }

    // Check alcohol
    if (_answers[10] == 'Yes') {
      disqualifyingAnswers++;
      reasons.add('Alcohol consumption in last 24 hours - please wait 24 hours');
    }

    // Check pregnancy
    if (_answers[11] == 'Yes' || _answers[12] == 'Yes') {
      disqualifyingAnswers++;
      reasons.add('Pregnancy or recent childbirth requires 6-month waiting period');
    }

    // Check recent illness
    if (_answers[13] == 'Yes') {
      disqualifyingAnswers++;
      reasons.add('Recent illness requires 7-day waiting period after full recovery');
    }

    // Check high-risk behaviors
    if (_answers[15] == 'Yes' || _answers[16] == 'Yes') {
      return EligibilityResult(
        eligible: false,
        isDeferral: true,
        reasons: ['High-risk factors detected - please consult healthcare provider'],
        recommendations: ['Contact a healthcare provider for more information'],
      );
    }

    // Determine eligibility
    if (disqualifyingAnswers == 0) {
      return EligibilityResult(
        eligible: true,
        isDeferral: false,
        reasons: [],
        recommendations: [
          'Drink plenty of water before donation',
          'Eat a healthy meal rich in iron',
          'Get a good night\'s sleep',
          'Bring valid ID proof',
        ],
      );
    } else {
      return EligibilityResult(
        eligible: false,
        isDeferral: true,
        reasons: reasons,
        recommendations: [
          'Please address the issues mentioned above',
          'Consult a healthcare provider if needed',
          'You can retake this questionnaire after the waiting period',
        ],
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Eligibility Check',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentQuestionIndex + 1}/${_questions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      question.category,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${_getProgress()}%',
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _getProgress() / 100,
                    backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade900),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          // Question pages
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentQuestionIndex = index;
                });
              },
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionPage(_questions[index], isDark);
              },
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (_currentQuestionIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousQuestion,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.shade900, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Previous',
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: _currentQuestionIndex > 0 ? 1 : 2,
                    child: ElevatedButton(
                      onPressed: _answers[_currentQuestionIndex] != null
                          ? _nextQuestion
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade900,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _currentQuestionIndex < _questions.length - 1
                            ? 'Next'
                            : 'See Results',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(Question question, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Question icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red.shade900, width: 2),
            ),
            child: Icon(
              _getQuestionIcon(question.category),
              color: Colors.red.shade900,
              size: 30,
            ),
          ),

          const SizedBox(height: 24),

          // Question text
          Text(
            question.question,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 8),

          // Critical indicator
          if (question.isCritical)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Important for eligibility',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),

          // Answer options
          if (question.type == QuestionType.yesNo) ...[
            _buildAnswerOption('Yes', Icons.check_circle, isDark),
            const SizedBox(height: 12),
            _buildAnswerOption('No', Icons.cancel, isDark),
          ] else if (question.type == QuestionType.singleChoice && question.options != null) ...[
            for (String option in question.options!) ...[
              _buildAnswerOption(option, null, isDark),
              const SizedBox(height: 12),
            ],
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(String answer, IconData? icon, bool isDark) {
    final isSelected = _answers[_currentQuestionIndex] == answer;

    return InkWell(
      onTap: () => _selectAnswer(answer),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.red.shade50
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.red.shade900 : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                isSelected ? icon : Icons.radio_button_unchecked,
                color: isSelected ? Colors.red.shade900 : Colors.grey.shade500,
                size: 24,
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.red.shade900
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.red.shade900,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getQuestionIcon(String category) {
    switch (category) {
      case 'Personal Information':
        return Icons.person;
      case 'General Health':
        return Icons.health_and_safety;
      case 'Recent Activities':
        return Icons.event;
      case 'Medications':
        return Icons.medication;
      case 'Lifestyle':
        return Icons.favorite;
      case 'Health History':
        return Icons.history;
      case 'Safety':
        return Icons.shield;
      case 'Preparation':
        return Icons.checklist;
      default:
        return Icons.help;
    }
  }
}

// Result Page
class QuestionnaireResultPage extends StatelessWidget {
  final EligibilityResult result;
  final Map<int, String?> answers;
  final List<Question> questions;

  const QuestionnaireResultPage({
    super.key,
    required this.result,
    required this.answers,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Eligibility Results',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Result icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: result.eligible ? Colors.green.shade50 : Colors.red.shade50,
                shape: BoxShape.circle,
                border: Border.all(
                  color: result.eligible ? Colors.green.shade700 : Colors.red.shade700,
                  width: 3,
                ),
              ),
              child: Icon(
                result.eligible ? Icons.check_circle : Icons.cancel,
                color: result.eligible ? Colors.green.shade700 : Colors.red.shade700,
                size: 70,
              ),
            ),

            const SizedBox(height: 32),

            // Result title
            Text(
              result.eligible ? 'Congratulations!' : 'Not Eligible Currently',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: result.eligible ? Colors.green.shade700 : Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Result subtitle
            Text(
              result.eligible
                  ? 'You are eligible to donate blood!'
                  : result.isDeferral
                      ? 'You are temporarily deferred'
                      : 'Please address the following issues',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Reasons card
            if (!result.eligible && result.reasons.isNotEmpty)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.red.shade900, width: 2.5),
                ),
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.red.shade900),
                          const SizedBox(width: 8),
                          Text(
                            'Reasons',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...result.reasons.map((reason) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    reason,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isDark ? Colors.white : Colors.black87,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Recommendations card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: result.eligible ? Colors.green.shade700 : Colors.blue.shade700,
                  width: 2.5,
                ),
              ),
              color: result.eligible ? Colors.green.shade50 : Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          result.eligible ? Icons.lightbulb : Icons.recommend,
                          color: result.eligible
                              ? Colors.green.shade700
                              : Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          result.eligible ? 'Recommendations' : 'What to do next',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: result.eligible
                                ? Colors.green.shade700
                                : Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...result.recommendations.map((recommendation) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: result.eligible
                                      ? Colors.green.shade700
                                      : Colors.blue.shade700,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  recommendation,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDark ? Colors.white : Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade900, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Retake Quiz',
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: result.eligible
                        ? () {
                            Navigator.pop(context);
                            // Navigate to donation form
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: result.eligible
                          ? Colors.red.shade900
                          : Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      result.eligible ? 'Donate Now' : 'Donate Later',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Models and Enums
class Question {
  final String category;
  final String question;
  final QuestionType type;
  final List<String>? options;
  final bool isCritical;
  final List<Gender>? showIf;

  Question({
    required this.category,
    required this.question,
    required this.type,
    this.options,
    this.isCritical = false,
    this.showIf,
  });
}

enum QuestionType {
  yesNo,
  singleChoice,
}

enum Gender {
  male,
  female,
  other,
}

class EligibilityResult {
  final bool eligible;
  final bool isDeferral;
  final List<String> reasons;
  final List<String> recommendations;

  EligibilityResult({
    required this.eligible,
    required this.isDeferral,
    required this.reasons,
    required this.recommendations,
  });
}

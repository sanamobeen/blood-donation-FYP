import 'package:flutter/material.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late AnimationController _typingController;
  late Animation<double> _typingAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize typing animation
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _typingController,
        curve: Curves.easeInOut,
      ),
    );

    // Add welcome message
    _addMessage(
      'Hello! I\'m your Blood Donation AI Assistant. 🩸\n\nI can help you with:\n• Donation eligibility\n• Preparation tips\n• After-care instructions\n• Blood type information\n• And much more!\n\nHow can I assist you today?',
      isUser: false,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  // Quick action questions
  final List<QuickAction> _quickActions = [
    QuickAction(
      icon: Icons.water_drop,
      title: 'Eligibility',
      question: 'Who can donate blood?',
    ),
    QuickAction(
      icon: Icons.schedule,
      title: 'Frequency',
      question: 'How often can I donate?',
    ),
    QuickAction(
      icon: Icons.restaurant,
      title: 'Preparation',
      question: 'How should I prepare for donation?',
    ),
    QuickAction(
      icon: Icons.health_and_safety,
      title: 'Benefits',
      question: 'What are the benefits of donating blood?',
    ),
    QuickAction(
      icon: Icons.bloodtype,
      title: 'Blood Types',
      question: 'Tell me about blood types',
    ),
    QuickAction(
      icon: Icons.local_hospital,
      title: 'After Care',
      question: 'What should I do after donating?',
    ),
  ];

  void _addMessage(String text, {required bool isUser}) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: isUser,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _addMessage(text, isUser: true);
    _messageController.clear();

    // Show typing indicator
    setState(() {
      _isTyping = true;
    });

    // Simulate AI thinking time
    await Future.delayed(const Duration(milliseconds: 1500));

    // Generate AI response
    final response = _generateAIResponse(text);

    // Hide typing indicator and add response
    setState(() {
      _isTyping = false;
    });
    _addMessage(response, isUser: false);
  }

  String _generateAIResponse(String question) {
    final lowerQuestion = question.toLowerCase();

    // Eligibility questions
    if (lowerQuestion.contains('eligible') || lowerQuestion.contains('who can donate') || lowerQuestion.contains('requirement')) {
      return '''**Eligibility Requirements:** ✅

• **Age:** 18-65 years old
• **Weight:** At least 50 kg (110 lbs)
• **Health:** Good overall health
• **Hemoglobin:** Minimum 12.5 g/dL for women, 13.0 g/dL for men

**Temporary deferrals:**
• Pregnancy or recent childbirth (6 months)
• Recent tattoo/piercing (6 months)
• Recent surgery (6 months)
• Recent travel to certain countries

Would you like to know about anything else?''';
    }

    // Frequency questions
    if (lowerQuestion.contains('often') || lowerQuestion.contains('frequency') || lowerQuestion.contains('how many times')) {
      return '''**Donation Frequency:** 📅

• **Whole Blood:** Every 56 days (8 weeks)
• **Platelets:** Every 7 days, up to 24 times/year
• **Plasma:** Every 28 days (4 weeks)
• **Power Red:** Every 112 days (16 weeks)

**Important:** Your body replenishes the donated blood volume within 24-48 hours!

Is there anything else you'd like to know?''';
    }

    // Preparation questions
    if (lowerQuestion.contains('prepare') || lowerQuestion.contains('before') || lowerQuestion.contains('prior')) {
      return '''**Before Donation:** 🍎

**Do:**
• Eat iron-rich foods (spinach, red meat, beans)
• Drink plenty of water (16 oz extra)
• Get a good night's sleep
• Bring ID and donor card
• Eat a healthy meal 2-4 hours before

**Avoid:**
• Fatty foods (affects blood testing)
• Alcohol 24 hours before
• Caffeine (can dehydrate)
• Strenuous exercise right before

**Pro tip:** Take 500mg Vitamin C for better iron absorption!

Any other questions about preparation?''';
    }

    // Benefits questions
    if (lowerQuestion.contains('benefit') || lowerQuestion.contains('why donate') || lowerQuestion.contains('advantage')) {
      return '''**Benefits of Donating Blood:** ❤️

**For Recipients:**
• Save up to 3 lives per donation!
• Help cancer patients, surgery patients, trauma victims
• Support premature babies

**For Donors:**
• Free health screening
• Reduces risk of heart disease
• Burns calories (~650 calories per donation!)
• Reveals potential health issues
• Gives a sense of accomplishment

**Every 2 seconds, someone needs blood.** You can make a difference!

Want to know when you're eligible to donate?''';
    }

    // Blood type questions
    if (lowerQuestion.contains('blood type') || lowerQuestion.contains('type') || lowerQuestion.contains('o positive') || lowerQuestion.contains('o negative')) {
      return '''**Blood Type Information:** 🩸

**Universal Donor:** O- can give to anyone
**Universal Recipient:** AB+ can receive from anyone

**Compatibility Chart:**
• O+ → A+, B+, AB+, O+
• O- → All types (emergency situations)
• A+ → A+, AB+
• A- → A+, A-, AB+, AB-
• B+ → B+, AB+
• B- → B+, B-, AB+, AB-
• AB+ → AB+ only
• AB- → AB+, AB-

**Did you know?** O- is most needed because only 7% of the population has it!

What's your blood type?''';
    }

    // After care questions
    if (lowerQuestion.contains('after') || lowerQuestion.contains('post') || lowerQuestion.contains('care')) {
      return '''**After Donation Care:** 💪

**Immediately After:**
• Rest for 10-15 minutes
• Enjoy provided snacks & juice
• Keep bandage on for 4-6 hours

**Next 24 Hours:**
• Drink extra fluids
• Avoid heavy lifting (5+ hours)
• No strenuous exercise
• Keep the bandage clean & dry

**What to Expect:**
• Slight fatigue (normal)
• Mild soreness at needle site
• Feeling good about saving lives! 🌟

**Warning Signs:** Call your doctor if you experience:
• Dizziness that persists
• Numbness or tingling in arm
• Fever or infection signs

Any other questions about after-care?''';
    }

    // Default response
    return '''Thanks for your question!

I'm here to help with blood donation-related topics. Here are some things I can assist with:

• 🩸 Eligibility requirements
• 📅 Donation frequency
• 🍎 Preparation tips
• ❤️ Benefits of donating
• 🔬 Blood type information
• 💪 After-care instructions

Could you please rephrase your question, or select one of the quick action buttons below?

I'm learning every day to serve you better!''';
  }

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
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy, color: Colors.red.shade900, size: 22),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'AI Assistant',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Online',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.white),
            onPressed: () {
              setState(() {
                _messages.clear();
                _addMessage(
                  'Chat cleared! How can I help you? 🩸',
                  isUser: false,
                );
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.smart_toy,
                          size: 80,
                          color: Colors.red.shade900.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start a conversation',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return _buildTypingIndicator();
                      }
                      final message = _messages[index];
                      return _buildMessageBubble(message, isDark);
                    },
                  ),
          ),

          // Quick actions
          if (_messages.length <= 2)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                border: Border(
                  top: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _quickActions.length,
                      itemBuilder: (context, index) {
                        final action = _quickActions[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildQuickActionButton(action, isDark),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.white,
              border: Border(
                top: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              ),
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
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'Ask me anything...',
                                hintStyle: TextStyle(
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              maxLines: null,
                              textInputAction: TextInputAction.newline,
                              onSubmitted: _sendMessage,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.emoji_emotions_outlined,
                              color: Colors.grey.shade500,
                            ),
                            onPressed: () {
                              // TODO: Add emoji picker
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade900,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => _sendMessage(_messageController.text),
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

  Widget _buildMessageBubble(ChatMessage message, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!message.isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Card(
                  elevation: 3,
                  shadowColor: message.isUser
                      ? Colors.red.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: message.isUser
                          ? Colors.red.shade900
                          : Colors.red.shade900,
                      width: 2.5,
                    ),
                  ),
                  color: message.isUser
                      ? Colors.red.shade900
                      : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      message.text,
                      style: TextStyle(
                        color: message.isUser
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black87),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              if (message.isUser) ...[
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 18),
                ),
              ],
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 40, right: 40),
            child: Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(QuickAction action, bool isDark) {
    return InkWell(
      onTap: () => _sendMessage(action.question),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.red.shade900.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              action.icon,
              size: 18,
              color: Colors.red.shade900,
            ),
            const SizedBox(width: 6),
            Text(
              action.title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Card(
            elevation: 3,
            shadowColor: Colors.red.withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Colors.red.shade900,
                width: 2.5,
              ),
            ),
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: AnimatedBuilder(
                animation: _typingAnimation,
                builder: (context, child) {
                  return Row(
                    children: [
                      _buildDot(0),
                      const SizedBox(width: 6),
                      _buildDot(1),
                      const SizedBox(width: 6),
                      _buildDot(2),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _typingAnimation,
      builder: (context, child) {
        // Calculate opacity based on animation value and dot index
        final double delay = index * 0.3;
        double opacity = 0.3;

        if (_typingAnimation.value >= delay && _typingAnimation.value < delay + 0.3) {
          opacity = 1.0;
        } else if (_typingAnimation.value >= delay + 0.3) {
          opacity = 0.3;
        }

        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: (isDark ? Colors.grey.shade400 : Colors.grey.shade600)
                .withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class QuickAction {
  final IconData icon;
  final String title;
  final String question;

  QuickAction({
    required this.icon,
    required this.title,
    required this.question,
  });
}

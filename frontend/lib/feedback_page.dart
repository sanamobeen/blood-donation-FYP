import 'package:flutter/material.dart';
import 'services/language_service.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final LanguageProvider _languageProvider = LanguageProvider();
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _languageProvider.currentLanguage;
  }

  String _translate(String key) {
    return AppTranslations.getText(key, _selectedLanguage);
  }

  void _openFeedbackForm(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackFormPage(type: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _translate('feedback'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              _translate('feedback_title'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _translate('feedback_hint'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Feedback Options
            _buildFeedbackCard(
              context,
              icon: Icons.feedback,
              title: _translate('feedback'),
              description: 'Share your thoughts and suggestions',
              color: Colors.red.shade700,
              type: 'general',
            ),
            const SizedBox(height: 16),

            _buildFeedbackCard(
              context,
              icon: Icons.star,
              title: _translate('rate_us'),
              description: 'Rate your experience with our app',
              color: Colors.red.shade700,
              type: 'rating',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required String type,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _openFeedbackForm(context, type),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackFormPage extends StatefulWidget {
  final String type;

  const FeedbackFormPage({super.key, required this.type});

  @override
  State<FeedbackFormPage> createState() => _FeedbackFormPageState();
}

class _FeedbackFormPageState extends State<FeedbackFormPage> {
  final LanguageProvider _languageProvider = LanguageProvider();
  String _selectedLanguage = 'en';
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;
  int _currentRating = 0;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _languageProvider.currentLanguage;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String _translate(String key) {
    return AppTranslations.getText(key, _selectedLanguage);
  }

  String _getTitle() {
    switch (widget.type) {
      case 'rating':
        return _translate('rate_us');
      default:
        return _translate('feedback');
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case 'rating':
        return Icons.star;
      default:
        return Icons.feedback;
    }
  }

  Color _getColor() {
    return Colors.red.shade700;
  }

  String _getRatingText() {
    switch (_currentRating) {
      case 1:
        return _selectedLanguage == 'ur' ? 'بہت خراب' : 'Poor';
      case 2:
        return _selectedLanguage == 'ur' ? 'خراب' : 'Fair';
      case 3:
        return _selectedLanguage == 'ur' ? 'اچھا' : 'Good';
      case 4:
        return _selectedLanguage == 'ur' ? 'بہت اچھا' : 'Very Good';
      case 5:
        return _selectedLanguage == 'ur' ? 'بہت زبردست' : 'Excellent';
      default:
        return _selectedLanguage == 'ur' ? 'درجہ دیں' : 'Tap to rate';
    }
  }

  void _submitFeedback() async {
    // Validate rating for 'rating' type
    if (widget.type == 'rating' && _currentRating == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedLanguage == 'ur' ? 'براہ کرم درجہ دیں' : 'Please provide a rating'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Validate message for non-rating types
    if (widget.type != 'rating' && _messageController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_translate('feedback_error')),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate network request
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      Navigator.pop(context); // Go back to feedback page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_translate('feedback_submitted')),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getColor();

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: color,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getTitle(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getIcon(), color: color, size: 40),
              ),
            ),
            const SizedBox(height: 24),

            // Star Rating (only for 'rating' type)
            if (widget.type == 'rating') ...[
              Center(
                child: Column(
                  children: [
                    Text(
                      _selectedLanguage == 'ur' ? 'اپنی درجہ دیں' : 'Rate your experience',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starNumber = index + 1;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentRating = starNumber;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              _currentRating >= starNumber
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 48,
                              color: _currentRating >= starNumber
                                  ? Colors.amber
                                  : Colors.grey.shade400,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getRatingText(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Subject field (only for non-rating types)
            if (widget.type != 'rating')
              TextField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: _translate('subject'),
                  labelStyle: TextStyle(color: color),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: color, width: 2),
                  ),
                  prefixIcon: Icon(Icons.subject, color: color),
                ),
              ),
            if (widget.type != 'rating')
              const SizedBox(height: 16),

            // Message field (only for non-rating types)
            if (widget.type != 'rating')
              TextField(
                controller: _messageController,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: _translate('feedback_message'),
                  labelStyle: TextStyle(color: color),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: color, width: 2),
                  ),
                  prefixIcon: Icon(Icons.message, color: color),
                  hintText: _translate('feedback_hint'),
                  alignLabelWithHint: true,
                ),
              ),
            // Optional comment field for rating
            if (widget.type == 'rating')
              TextField(
                controller: _messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: _selectedLanguage == 'ur' ? 'غیر ضروری تبصرہ' : 'Add a comment (optional)',
                  labelStyle: TextStyle(color: color),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: color, width: 2),
                  ),
                  prefixIcon: Icon(Icons.comment, color: color),
                  hintText: _selectedLanguage == 'ur' ? 'اپنی رائے کے بارے میں بتائیں...' : 'Tell us more about your experience...',
                ),
              ),
            SizedBox(height: widget.type != 'rating' ? 24 : 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.type == 'rating'
                            ? (_selectedLanguage == 'ur' ? 'درجہ جمع کروائیں' : 'Submit Rating')
                            : _translate('send_feedback'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
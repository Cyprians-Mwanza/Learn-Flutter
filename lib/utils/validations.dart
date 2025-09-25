class ValidationUtils {
  // Validate title
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    if (value.length < 2) {
      return 'Title must be at least 2 characters long';
    }
    if (value.length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  // Validate body
  static String? validateBody(String? value) {
    if (value == null || value.isEmpty) {
      return 'Body is required';
    }
    if (value.length < 5) {
      return 'Body must be at least 5 characters long';
    }
    if (value.length > 1000) {
      return 'Body must be less than 1000 characters';
    }
    return null;
  }

  // Validate both title and body
  static Map<String, String?> validateNote(String? title, String? body) {
    return {
      'title': validateTitle(title),
      'body': validateBody(body),
    };
  }

  // Check if note is valid (no errors)
  static bool isNoteValid(String? title, String? body) {
    final errors = validateNote(title, body);
    return errors['title'] == null && errors['body'] == null;
  }

  // Check if note content has changed
  static bool hasChanges(String originalTitle, String originalBody, String newTitle, String newBody) {
    return originalTitle != newTitle || originalBody != newBody;
  }
}
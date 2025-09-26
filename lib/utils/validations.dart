class ValidationUtils {
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

  static bool hasChanges(String originalTitle, String originalBody, String newTitle, String newBody) {
    return originalTitle != newTitle || originalBody != newBody;
  }
}
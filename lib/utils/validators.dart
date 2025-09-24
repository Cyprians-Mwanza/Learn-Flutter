class Validators {
  /// Validate Note title
  static String? validateTitle(String title) {
    if (title
        .trim()
        .isEmpty) {
      return "Title cannot be empty";
    }
    if (title.length < 3) {
      return "Title must be at least 3 characters long";
    }
    // Regex to allow only letters, numbers, spaces, and basic punctuation
    final regex = RegExp(r"^[a-zA-Z0-9\s\.,!?'-]+$");
    if (!regex.hasMatch(title)) {
      return "Title contains invalid characters";
    }
    return null; // valid
  }

  /// Validate Note body
  static String? validateBody(String body) {
    if (body
        .trim()
        .isEmpty) {
      return "Body cannot be empty";
    }
    if (body.length < 5) {
      return "Body must be at least 5 characters long";
    }
    return null;
  }
}
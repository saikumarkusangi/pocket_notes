class GoogleAuthUser {
  const GoogleAuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.idToken,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? idToken;
}

enum GoogleAuthAction { signIn, logout }

class GoogleAuthResult {
  const GoogleAuthResult._({
    required this.isSuccess,
    required this.isCancelled,
    this.user,
    this.errorMessage,
    this.action,
  });

  final bool isSuccess;
  final bool isCancelled;
  final GoogleAuthUser? user;
  final String? errorMessage;
  final GoogleAuthAction? action;

  factory GoogleAuthResult.success(
    GoogleAuthUser user,
    GoogleAuthAction action,
  ) {
    return GoogleAuthResult._(
      isSuccess: true,
      isCancelled: false,
      user: user,
      action: action,
    );
  }

  factory GoogleAuthResult.cancelled() {
    return const GoogleAuthResult._(
      isSuccess: false,
      isCancelled: true,
    );
  }

  factory GoogleAuthResult.failure(String message) {
    return GoogleAuthResult._(
      isSuccess: false,
      isCancelled: false,
      errorMessage: message,
    );
  }

  factory GoogleAuthResult.logout() {
    return GoogleAuthResult._(
      isSuccess: true,
      isCancelled: false,
      user: null,
      action: GoogleAuthAction.logout,
    );
  }

  @override
  String toString() {
    return 'GoogleAuthResult(isSuccess: $isSuccess, isCancelled: $isCancelled, '
        'errorMessage: $errorMessage, user: ${user?.email})';
  }
}

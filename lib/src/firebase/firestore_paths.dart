abstract final class FirestorePaths {
  static String userDoc(String uid) => 'users/$uid';
  static String userEntriesCollection(String uid) => 'users/$uid/entries';
}


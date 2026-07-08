abstract class AiAssistantRepository {
  Future<String> summarizeNote(String noteId);
  Future<String> rewriteText(String text);
  Future<String> correctGrammar(String text);
  Future<String> translateText({
    required String text,
    required String language,
  });
  Future<String> generateTitle(String text);
  Future<List<String>> extractKeywords(String text);
  Future<List<String>> convertNoteIntoTasks(String noteId);
  Future<List<String>> generateIdeas(String topic);
}

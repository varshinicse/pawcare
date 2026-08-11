import 'dart:async';
import '../models/chat_message_model.dart';

class AiChatService {
  static final List<ChatMessage> _memory = [];

  static List<ChatMessage> get conversationHistory => List.unmodifiable(_memory);

  static Future<ChatMessage> sendMessage(String text) async {
    // 1. Store User Message in memory
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _memory.add(userMsg);

    // 2. Generate simulated AI response with domain intelligence
    final cleanText = text.toLowerCase();
    String responseText = 'That\'s a great question! For specific concerns, I recommend discussing this with your regular veterinarian. Can you share more details about your pet\'s age or breed?';

    if (cleanText.contains('hello') || cleanText.contains('hi')) {
      responseText = 'Hello! 🐾 I am your PawCare AI Assistant. Ask me anything about your pet\'s health, nutrition, vaccines, behavior, or training!';
    } else if (cleanText.contains('vomit') || cleanText.contains('diarrhea') || cleanText.contains('sick')) {
      responseText = 'If your pet is vomiting or has diarrhea, it could indicate digestive issues. Fast them for 12 hours and offer small amounts of water. Seek emergency care immediately if they are lethargic, show pale gums, or vomit blood.';
    } else if (cleanText.contains('eat') || cleanText.contains('diet') || cleanText.contains('feed') || cleanText.contains('food')) {
      responseText = 'Proper diet depends on age and weight. Puppies/Kittens need calorie-dense growth formulas. Avoid onions, garlic, chocolate, grapes, and raisins, as they are toxic to pets.';
    } else if (cleanText.contains('vaccin') || cleanText.contains('shot')) {
      responseText = 'Dogs require core DHPP (Distemper, Hepatitis, Parvovirus, Parainfluenza) and Rabies vaccines. Cats need FVRCP and Rabies. Always consult a vet for a proper schedule.';
    } else if (cleanText.contains('train') || cleanText.contains('bark') || cleanText.contains('bite') || cleanText.contains('potty')) {
      responseText = 'Behavioral issues are best solved using positive reinforcement training. Reward good behavior with small treats immediately, ignore minor unwanted behaviors, and never use physical discipline.';
    } else if (cleanText.contains('emergency') || cleanText.contains('poison') || cleanText.contains('chok')) {
      responseText = '🚨 EMERGENCY WARNING: Contact Apollo Pet Emergency Hospital at +919876543210 immediately. Keep calm, keep your pet warm, and do not administer human medications.';
    }

    // Delay response slightly for realistic UI feel
    await Future.delayed(const Duration(milliseconds: 600));

    final aiMsg = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      text: responseText,
      isUser: false,
      timestamp: DateTime.now(),
    );
    _memory.add(aiMsg);

    return aiMsg;
  }

  static void clearHistory() {
    _memory.clear();
  }
}

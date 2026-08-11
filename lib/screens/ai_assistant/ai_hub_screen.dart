import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chat_message_model.dart';
import '../../providers/pet_provider.dart';
import '../../services/ai_chat_service.dart';
import '../../services/ai_expert_system.dart';
import '../../services/ai_nutrition_engine.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class AiHubScreen extends StatefulWidget {
  const AiHubScreen({super.key});

  @override
  State<AiHubScreen> createState() => _AiHubScreenState();
}

class _AiHubScreenState extends State<AiHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Chat tab controllers
  final List<ChatMessage> _messages = [];
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isChatLoading = false;

  // Symptom solver controllers
  final _symptomController = TextEditingController();
  SymptomsDiagnosis? _diagnosis;

  // Nutrition controllers
  String _selectedActivity = 'moderate';
  NutritionReport? _nutritionReport;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Initial greeting in chat
    _messages.add(ChatMessage(
      id: 'greeting',
      text: 'Hello! I am your PawCare AI Assistant. How can I help you care for your pet today? 🐾',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _symptomController.dispose();
    super.dispose();
  }

  // --- NUTRITION METHOD ---
  void _calculateNutrition(dynamic activePet) {
    if (activePet == null) return;
    setState(() {
      _nutritionReport = AiNutritionEngine.calculateReport(
        species: activePet.species,
        ageYears: activePet.age,
        weightKg: activePet.weightKg,
        activityLevel: _selectedActivity,
        medicalConditions: activePet.medicalHistory,
      );
    });
  }

  // --- SYMPTOM SOLVER METHOD ---
  void _runSymptomSolver(dynamic activePet) {
    if (_symptomController.text.trim().isEmpty) return;
    setState(() {
      _diagnosis = AiExpertSystem.analyzeSymptoms(
        _symptomController.text.trim(),
        activePet?.species ?? 'dog',
      );
    });
  }

  // --- CHATBOT METHOD ---
  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isChatLoading) return;

    _messageController.clear();
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isChatLoading = true;
    });

    _scrollToBottom();

    final response = await AiChatService.sendMessage(text);
    setState(() {
      _messages.add(response);
      _isChatLoading = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final activePet = petProvider.activePet;

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      appBar: AppBar(
        title: const Text('AI Health Center 🧠'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.clayPrimary,
          unselectedLabelColor: AppColors.softTaupe,
          indicatorColor: AppColors.clayPrimary,
          tabs: const [
            Tab(text: 'SYMPTOM SOLVER'),
            Tab(text: 'NUTRITION CALC'),
            Tab(text: 'AI CHATBOT'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSymptomTab(activePet),
          _buildNutritionTab(activePet),
          _buildChatTab(),
        ],
      ),
    );
  }

  Widget _buildSymptomTab(dynamic activePet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Advanced Symptom Solver', style: AppTypography.displaySmall),
          const SizedBox(height: 6),
          Text(
            'Describe symptoms below (e.g. "My dog is vomiting" or "cat is itching"):',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _symptomController,
            decoration: const InputDecoration(
              hintText: 'Describe physical signs...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _runSymptomSolver(activePet),
              child: const Text('Run Diagnostic Scan'),
            ),
          ),

          if (_diagnosis != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('AI DIAGNOSTIC SCAN', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _diagnosis!.severity == 'HIGH' ? AppColors.alertLight : AppColors.mossLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _diagnosis!.severity,
                          style: AppTypography.labelMedium.copyWith(
                            color: _diagnosis!.severity == 'HIGH' ? AppColors.alertCoral : AppColors.mossAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('Possible Conditions:', style: AppTypography.labelLarge),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _diagnosis!.possibleDiseases.map((d) {
                      return Chip(
                        label: Text(d),
                        backgroundColor: AppColors.creamSurface,
                        labelStyle: AppTypography.bodySmall.copyWith(color: AppColors.inkText),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Text('Expert Recommendations:', style: AppTypography.labelLarge),
                  const SizedBox(height: 4),
                  Text(_diagnosis!.recommendation, style: AppTypography.bodyMedium),
                  const SizedBox(height: 14),
                  Text('Home Care & First Aid:', style: AppTypography.labelLarge),
                  const SizedBox(height: 4),
                  Text(_diagnosis!.homeCare, style: AppTypography.bodyMedium),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNutritionTab(dynamic activePet) {
    if (activePet == null) {
      return const Center(child: Text('No active pet selected.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Caloric & Nutrition Planner', style: AppTypography.displaySmall),
          const SizedBox(height: 6),
          Text(
            'Calculate exact daily food portions for ${activePet.name} based on active lifestyle rules:',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _selectedActivity,
            decoration: const InputDecoration(labelText: 'Agility / Activity Level'),
            items: const [
              DropdownMenuItem(value: 'low', child: Text('Low Activity / Sedentary')),
              DropdownMenuItem(value: 'moderate', child: Text('Moderate / Daily walks')),
              DropdownMenuItem(value: 'high', child: Text('High Activity / Sport training')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedActivity = val);
            },
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _calculateNutrition(activePet),
              child: const Text('Calculate Nutrition Plan'),
            ),
          ),

          if (_nutritionReport != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI NUTRITIONAL LOGS', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNutritionStat('CALORIES', '${_nutritionReport!.dailyCalories} kcal'),
                      _buildNutritionStat('PORTION', '${_nutritionReport!.mealQuantityGrams} g'),
                      _buildNutritionStat('FREQUENCY', '${_nutritionReport!.mealFrequency} / day'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('Recommended Foods:', style: AppTypography.labelLarge),
                  const SizedBox(height: 4),
                  Text(_nutritionReport!.recommendedFoods.join(', '), style: AppTypography.bodyMedium),
                  const SizedBox(height: 14),
                  Text('Foods to Avoid:', style: AppTypography.labelLarge.copyWith(color: AppColors.alertCoral)),
                  const SizedBox(height: 4),
                  Text(_nutritionReport!.foodsToAvoid.join(', '), style: AppTypography.bodyMedium.copyWith(color: AppColors.alertCoral)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isMe = msg.isUser;
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  constraints: const BoxConstraints(maxWidth: 280),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.clayPrimary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
                      bottomRight: isMe ? Radius.zero : const Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isMe ? Colors.white : AppColors.inkText,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isChatLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: AppColors.clayPrimary, strokeWidth: 2),
            ),
          ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type query (e.g. food advice)...',
                    border: InputBorder.none,
                    filled: false,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send_rounded, color: AppColors.clayPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionStat(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMedium.copyWith(fontSize: 10)),
        const SizedBox(height: 2),
        Text(val, style: AppTypography.numericData.copyWith(fontSize: 16)),
      ],
    );
  }
}

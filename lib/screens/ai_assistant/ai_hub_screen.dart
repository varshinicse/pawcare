import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chat_message_model.dart';
import '../../providers/pet_provider.dart';
import '../../services/ai_chat_service.dart';
import '../../services/ai_expert_system.dart';
import '../../services/ai_nutrition_engine.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/pet_switcher_pill.dart';

class AiHubScreen extends StatefulWidget {
  const AiHubScreen({super.key});

  @override
  State<AiHubScreen> createState() => _AiHubScreenState();
}

class _AiHubScreenState extends State<AiHubScreen> {
  final List<ChatMessage> _messages = [];
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isChatLoading = false;

  // Triage & Nutrition Modals
  final _symptomController = TextEditingController();
  SymptomsDiagnosis? _diagnosis;
  NutritionReport? _nutritionReport;
  final String _selectedActivity = 'moderate';

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      id: 'greeting',
      text: "Hi! I am PawCare AI — ready to help with your pet's symptoms, nutrition, and daily wellness. What are you noticing today? 🐾",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _symptomController.dispose();
    super.dispose();
  }

  void _sendMessage([String? quickQuery]) async {
    final text = (quickQuery ?? _messageController.text).trim();
    if (text.isEmpty || _isChatLoading) return;

    if (quickQuery == null) {
      _messageController.clear();
    }
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

    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final activePet = petProvider.activePet;

    try {
      final replyMsg = await AiChatService.sendMessage(text);

      if (mounted) {
        setState(() {
          _messages.add(replyMsg);
          _isChatLoading = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: "Based on ${activePet?.name ?? 'your pet'}'s profile, keep them hydrated, monitor energy levels, and consult a vet if symptoms persist.",
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isChatLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showTriageSheet(dynamic activePet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.dividerColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Symptom Triage Solver 🩺', style: AppTypography.displaySmall),
                    const SizedBox(height: 6),
                    Text(
                      'Describe what symptoms ${activePet?.name ?? 'your pet'} is experiencing.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _symptomController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'e.g. lethargic, vomited breakfast, sensitive stomach...',
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTerracotta,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: () {
                          if (_symptomController.text.trim().isNotEmpty) {
                            final diag = AiExpertSystem.analyzeSymptoms(
                              _symptomController.text.trim(),
                              activePet?.species ?? 'dog',
                            );
                            setSheetState(() => _diagnosis = diag);
                          }
                        },
                        child: const Text('Analyze Urgency & First Aid'),
                      ),
                    ),
                    if (_diagnosis != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.creamSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.dividerColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Urgency Level:', style: AppTypography.labelLarge),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _diagnosis!.severity == 'HIGH' ? AppColors.alertCoral : AppColors.pistachioSecondary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _diagnosis!.severity.toUpperCase(),
                                    style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Recommendation: ${_diagnosis!.recommendation}', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Home Care: ${_diagnosis!.homeCare}', style: AppTypography.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showNutritionSheet(dynamic activePet) {
    if (activePet != null && _nutritionReport == null) {
      _nutritionReport = AiNutritionEngine.calculateReport(
        species: activePet.species,
        ageYears: activePet.age,
        weightKg: activePet.weightKg,
        activityLevel: _selectedActivity,
        medicalConditions: List<String>.from(activePet.medicalHistory),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.dividerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('AI Nutrition & Calorie Plan 🥗', style: AppTypography.displaySmall),
              const SizedBox(height: 6),
              Text(
                'Personalized daily calories & macro distribution for ${activePet?.name ?? 'your pet'}.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 16),
              if (_nutritionReport != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.buttercreamAccent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('DAILY CALORIES', style: AppTypography.labelSmall.copyWith(color: AppColors.buttercreamDark)),
                          const SizedBox(height: 2),
                          Text('${_nutritionReport!.dailyCalories} kcal', style: AppTypography.displaySmall.copyWith(fontSize: 18)),
                        ],
                      ),
                      Column(
                        children: [
                          Text('WATER INTAKE', style: AppTypography.labelSmall.copyWith(color: AppColors.buttercreamDark)),
                          const SizedBox(height: 2),
                          Text('${_nutritionReport!.waterIntakeMl} ml', style: AppTypography.displaySmall.copyWith(fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text('Diet Recommendation:', style: AppTypography.labelLarge),
                const SizedBox(height: 4),
                Text(_nutritionReport!.advice, style: AppTypography.bodySmall),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final activePet = petProvider.activePet;

    return Scaffold(
      backgroundColor: AppColors.creamBase,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Top AI Center Banner
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
              child: _buildAiHeroBanner(activePet),
            ),
            const SizedBox(height: 10),

            // Chat Messages Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.canopy.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Chat Status Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.dividerColor)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: AppColors.mossLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.eco_rounded, size: 16, color: AppColors.pistachioDark),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ask PawCare', style: AppTypography.labelLarge.copyWith(fontSize: 13)),
                              Row(
                                children: [
                                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.successGreen, shape: BoxShape.circle)),
                                  const SizedBox(width: 4),
                                  Text("Online • knows ${activePet?.name ?? 'pet'}'s profile", style: AppTypography.bodySmall.copyWith(fontSize: 10.5)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Messages List
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (ctx, index) {
                          final msg = _messages[index];
                          final isUser = msg.isUser;
                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isUser ? AppColors.primaryTerracotta : AppColors.creamSurface,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                                ),
                              ),
                              child: Text(
                                msg.text,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontSize: 13,
                                  color: isUser ? Colors.white : AppColors.inkText,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    if (_isChatLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryTerracotta)),
                            const SizedBox(width: 8),
                            Text('PawCare AI is thinking...', style: AppTypography.bodySmall),
                          ],
                        ),
                      ),

                    // Input Bar
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: AppColors.dividerColor)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: AppTypography.bodyMedium.copyWith(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Ask about symptoms, meals, or care...',
                                hintStyle: AppTypography.bodySmall,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send_rounded, color: AppColors.primaryTerracotta, size: 20),
                            onPressed: () => _sendMessage(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.creamBase,
        border: Border(
          bottom: BorderSide(color: AppColors.dividerColor.withValues(alpha: 0.8), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.canopy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'AI Center',
                style: AppTypography.displaySmall.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const PetSwitcherPill(),
        ],
      ),
    );
  }

  Widget _buildAiHeroBanner(dynamic activePet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.canopy,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.canopy.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryTerracotta,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PAWCARE AI CENTER',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primaryGlow,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Your pocket care guide.',
                    style: AppTypography.displaySmall.copyWith(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickChip(
                  icon: Icons.healing_rounded,
                  label: 'Symptom triage',
                  onTap: () => _showTriageSheet(activePet),
                ),
                const SizedBox(width: 8),
                _buildQuickChip(
                  icon: Icons.restaurant_rounded,
                  label: 'Nutrition planner',
                  onTap: () => _showNutritionSheet(activePet),
                ),
                const SizedBox(width: 8),
                _buildQuickChip(
                  icon: Icons.lightbulb_outline_rounded,
                  label: 'Diet advice',
                  onTap: () => _sendMessage('What is the best daily diet for my ${activePet?.breed ?? 'pet'}?'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primaryGlow),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

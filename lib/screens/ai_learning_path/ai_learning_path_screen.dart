import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/ai_learning_path.dart';
import '../../models/ai_learning_profile.dart';
import '../../models/category.dart';
import '../../providers/ai_learning_path_provider.dart';
import '../../providers/ai_suggestions_provider.dart';
import '../../theme/app_theme.dart';

class AiLearningPathScreen extends StatefulWidget {
  const AiLearningPathScreen({super.key});

  @override
  State<AiLearningPathScreen> createState() => _AiLearningPathScreenState();
}

class _AiLearningPathScreenState extends State<AiLearningPathScreen> {
  final Set<int> _selectedCategoryIds = <int>{};
  final TextEditingController _customGoalController = TextEditingController();
  final TextEditingController _weeklyHoursController = TextEditingController(
    text: '5',
  );

  String _skillLevel = 'beginner';
  String _goal = 'skill_enhancement';
  String _preferredLanguage = 'fr';
  String _learningStyle = 'balanced';
  DateTime? _targetDate;

  bool _screenReady = false;
  bool _editingPreferences = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  @override
  void dispose() {
    _customGoalController.dispose();
    _weeklyHoursController.dispose();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    final AiLearningPathProvider provider = context
        .read<AiLearningPathProvider>();

    await provider.initialize();

    if (!mounted) {
      return;
    }

    _seedForm(provider.profile);

    setState(() {
      _screenReady = true;
    });
  }

  Future<void> _reload() async {
    final AiLearningPathProvider provider = context
        .read<AiLearningPathProvider>();

    await provider.initialize();

    if (!mounted) {
      return;
    }

    _seedForm(provider.profile);

    setState(() {
      _screenReady = true;
    });
  }

  void _seedForm(AiLearningProfile? profile) {
    final String deviceLanguage = Localizations.localeOf(context).languageCode;

    final String safeDeviceLanguage =
        <String>{'fr', 'nl', 'de', 'en'}.contains(deviceLanguage)
        ? deviceLanguage
        : 'en';

    _selectedCategoryIds
      ..clear()
      ..addAll(profile?.categoryIds ?? const <int>[]);

    _skillLevel = profile?.skillLevel ?? 'beginner';
    _goal = profile?.goal ?? 'skill_enhancement';
    _preferredLanguage = profile?.preferredLanguage ?? safeDeviceLanguage;
    _learningStyle = profile?.learningStyle ?? 'balanced';
    _targetDate = profile?.targetDate;

    _customGoalController.text = profile?.customGoal ?? '';
    _weeklyHoursController.text = (profile?.weeklyHours ?? 5).toString();
  }

  Future<void> _saveProfile(AiLearningPathProvider provider) async {
    if (_selectedCategoryIds.isEmpty) {
      _showMessage(context.l10n.aiPathSelectCategoryError);
      return;
    }

    final int? weeklyHours = int.tryParse(_weeklyHoursController.text.trim());

    if (weeklyHours == null || weeklyHours < 1 || weeklyHours > 80) {
      _showMessage(context.l10n.aiPathWeeklyHoursError);
      return;
    }

    if (_goal == 'custom' && _customGoalController.text.trim().isEmpty) {
      _showMessage(context.l10n.aiPathCustomGoalError);
      return;
    }

    final AiLearningProfile profile = AiLearningProfile(
      id: provider.profile?.id,
      categoryIds: _selectedCategoryIds.toList()..sort(),
      skillLevel: _skillLevel,
      goal: _goal,
      customGoal: _goal == 'custom' ? _customGoalController.text.trim() : null,
      weeklyHours: weeklyHours,
      targetDate: _targetDate,
      preferredLanguage: _preferredLanguage,
      learningStyle: _learningStyle,
    );

    final bool saved = await provider.saveProfile(profile);

    if (!mounted) {
      return;
    }

    if (!saved) {
      _showProviderError(provider);
      return;
    }

    setState(() {
      _editingPreferences = false;
    });
  }

  Future<void> _generatePath(AiLearningPathProvider provider) async {
    if (provider.readiness?.ready != true) {
      final bool ready = await provider.checkReadiness();

      if (!mounted) {
        return;
      }

      if (!ready) {
        _showProviderError(provider);
        return;
      }
    }

    final bool generated = await provider.generatePath(
      locale: _preferredLanguage,
    );

    if (!mounted) {
      return;
    }

    if (!generated) {
      _showProviderError(provider);
      return;
    }

    setState(() {
      _editingPreferences = false;
    });
  }

  Future<void> _archivePath(AiLearningPathProvider provider) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.aiPathArchiveTitle),
          content: Text(context.l10n.aiPathArchiveBody),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.aiPathCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.l10n.aiPathConfirmArchive),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final bool archived = await provider.archiveCurrentPath();

    if (!mounted) {
      return;
    }

    if (!archived) {
      _showProviderError(provider);
      return;
    }

    setState(() {
      _editingPreferences = true;
    });
  }

  Future<void> _chooseTargetDate() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate =
        _targetDate ?? now.add(const Duration(days: 30));

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );

    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      _targetDate = selected;
    });
  }

  void _showProviderError(AiLearningPathProvider provider) {
    final String message =
        provider.errorMessage ??
        _readinessMessage(provider.businessCode, provider.readiness) ??
        context.l10n.aiPathConnectionError;

    _showMessage(message);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.getTextColor(context),
          ),
        ),
        title: Text(
          context.l10n.aiLearningPathGenerator,
          style: TextStyle(
            color: AppTheme.getTextColor(context),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Consumer2<AiLearningPathProvider, AiSuggestionsProvider>(
        builder:
            (
              BuildContext context,
              AiLearningPathProvider pathProvider,
              AiSuggestionsProvider categoryProvider,
              Widget? child,
            ) {
              if (!_screenReady || pathProvider.isLoading) {
                return _buildLoadingState();
              }

              final AiLearningPath? path = pathProvider.currentPath;

              if (path != null && !_editingPreferences) {
                return RefreshIndicator(
                  onRefresh: _reload,
                  child: _buildCurrentPath(pathProvider, path),
                );
              }

              return RefreshIndicator(
                onRefresh: _reload,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  children: <Widget>[
                    _buildIntroCard(),
                    const SizedBox(height: 18),
                    _buildProfileForm(pathProvider, categoryProvider),
                    if (pathProvider.profile?.exists == true) ...[
                      const SizedBox(height: 18),
                      _buildReadinessCard(pathProvider),
                    ],
                  ],
                ),
              );
            },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            context.l10n.aiPathLoading,
            style: TextStyle(
              color: AppTheme.getTextColor(context).withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.aiPathPersonalizeTitle,
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.aiPathPersonalizeSubtitle,
            style: TextStyle(
              color: AppTheme.getTextColor(context).withValues(alpha: 0.68),
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(
    AiLearningPathProvider pathProvider,
    AiSuggestionsProvider categoryProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.getSoftGray150(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _sectionTitle(context.l10n.aiPathCategories),
          const SizedBox(height: 6),
          _sectionHint(context.l10n.aiPathCategoriesHint),
          const SizedBox(height: 14),
          _buildCategories(categoryProvider),
          const SizedBox(height: 24),
          _sectionTitle(context.l10n.aiPathSkillLevel),
          const SizedBox(height: 12),
          _choiceWrap(
            values: const <String>['beginner', 'intermediate', 'advanced'],
            selectedValue: _skillLevel,
            labelBuilder: _skillLabel,
            onSelected: (String value) {
              setState(() {
                _skillLevel = value;
              });
            },
          ),
          const SizedBox(height: 24),
          _sectionTitle(context.l10n.aiPathGoal),
          const SizedBox(height: 12),
          _choiceWrap(
            values: const <String>[
              'career_change',
              'skill_enhancement',
              'personal_interest',
              'certification',
              'freelancing',
              'custom',
            ],
            selectedValue: _goal,
            labelBuilder: _goalLabel,
            onSelected: (String value) {
              setState(() {
                _goal = value;
              });
            },
          ),
          if (_goal == 'custom') ...[
            const SizedBox(height: 14),
            TextField(
              controller: _customGoalController,
              minLines: 2,
              maxLines: 4,
              maxLength: 1000,
              decoration: _inputDecoration(context.l10n.aiPathCustomGoal),
            ),
          ],
          const SizedBox(height: 24),
          _sectionTitle(context.l10n.aiPathWeeklyHours),
          const SizedBox(height: 12),
          TextField(
            controller: _weeklyHoursController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(
              context.l10n.aiPathWeeklyHours,
              suffixText: context.l10n.aiPathHours,
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle(context.l10n.aiPathTargetDate),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _chooseTargetDate,
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: Text(
                    _targetDate == null
                        ? context.l10n.aiPathChooseDate
                        : _formatDate(_targetDate!),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              if (_targetDate != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: context.l10n.aiPathClearDate,
                  onPressed: () {
                    setState(() {
                      _targetDate = null;
                    });
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          _sectionTitle(context.l10n.aiPathLanguage),
          const SizedBox(height: 12),
          _choiceWrap(
            values: const <String>['fr', 'nl', 'de', 'en'],
            selectedValue: _preferredLanguage,
            labelBuilder: _languageLabel,
            onSelected: (String value) {
              setState(() {
                _preferredLanguage = value;
              });
            },
          ),
          const SizedBox(height: 24),
          _sectionTitle(context.l10n.aiPathLearningStyle),
          const SizedBox(height: 12),
          _choiceWrap(
            values: const <String>['fast', 'balanced', 'in_depth'],
            selectedValue: _learningStyle,
            labelBuilder: _learningStyleLabel,
            onSelected: (String value) {
              setState(() {
                _learningStyle = value;
              });
            },
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: pathProvider.isSavingProfile
                  ? null
                  : () => _saveProfile(pathProvider),
              icon: pathProvider.isSavingProfile
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.tune_rounded),
              label: Text(context.l10n.aiPathSaveAnalyze),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(AiSuggestionsProvider categoryProvider) {
    if (categoryProvider.isLoadingCategories) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (categoryProvider.categoryError != null) {
      return _inlineError(
        categoryProvider.categoryError!,
        onRetry: categoryProvider.fetchCategories,
      );
    }

    if (categoryProvider.interests.isEmpty) {
      return _inlineError(
        context.l10n.aiPathConnectionError,
        onRetry: categoryProvider.fetchCategories,
      );
    }

    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: categoryProvider.interests
          .map((Category category) {
            final bool selected = _selectedCategoryIds.contains(category.id);

            return FilterChip(
              selected: selected,
              label: Text(category.name),
              avatar: Icon(
                selected ? Icons.check_circle_rounded : Icons.category_outlined,
                size: 18,
              ),
              onSelected: (bool value) {
                setState(() {
                  if (value) {
                    _selectedCategoryIds.add(category.id);
                  } else {
                    _selectedCategoryIds.remove(category.id);
                  }
                });
              },
              selectedColor: AppTheme.primary.withValues(alpha: 0.14),
              checkmarkColor: AppTheme.primary,
              side: BorderSide(
                color: selected
                    ? AppTheme.primary
                    : AppTheme.getSoftGray150(context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            );
          })
          .toList(growable: false),
    );
  }

  Widget _buildReadinessCard(AiLearningPathProvider provider) {
    final String? code = provider.readiness?.code ?? provider.businessCode;

    final String message =
        _readinessMessage(code, provider.readiness) ??
        context.l10n.aiPathConnectionError;

    final bool ready = provider.readiness?.ready == true;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ready
            ? AppTheme.primary.withValues(alpha: 0.08)
            : AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: ready
              ? AppTheme.primary.withValues(alpha: 0.28)
              : AppTheme.getSoftGray150(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                ready ? Icons.auto_awesome_rounded : Icons.info_outline_rounded,
                color: ready
                    ? AppTheme.primary
                    : AppTheme.getTextColor(context).withValues(alpha: 0.65),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ready
                      ? context.l10n.aiPathReadyTitle
                      : context.l10n.aiLearningPathGenerator,
                  style: TextStyle(
                    color: AppTheme.getTextColor(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            ready ? context.l10n.aiPathReadyBody : message,
            style: TextStyle(
              color: AppTheme.getTextColor(context).withValues(alpha: 0.72),
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (provider.readiness != null) ...[
            const SizedBox(height: 12),
            Text(
              '${provider.readiness!.candidateCount}'
              ' / '
              '${provider.readiness!.minimumRequired}',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ready
                ? FilledButton.icon(
                    onPressed: provider.isGenerating
                        ? null
                        : () => _generatePath(provider),
                    icon: provider.isGenerating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome_rounded),
                    label: Text(
                      provider.isGenerating
                          ? context.l10n.aiPathGenerating
                          : context.l10n.aiPathGenerate,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: provider.isGenerating
                        ? null
                        : provider.checkReadiness,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(context.l10n.aiPathCheckAvailability),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPath(
    AiLearningPathProvider provider,
    AiLearningPath path,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.route_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      context.l10n.aiPathCurrentTitle,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                path.title,
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              if (path.summary.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  path.summary,
                  style: TextStyle(
                    color: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.72),
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _metaChip(
                    Icons.calendar_view_week_rounded,
                    '${path.estimatedWeeks} '
                    '${context.l10n.aiPathWeeks}',
                  ),
                  _metaChip(Icons.layers_rounded, '${path.steps.length}'),
                  _metaChip(
                    Icons.auto_awesome_rounded,
                    path.generationMode.toUpperCase(),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        ...path.steps.map((AiLearningPathStep step) => _buildPathStep(step)),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _editingPreferences = true;
            });
          },
          icon: const Icon(Icons.tune_rounded),
          label: Text(context.l10n.aiPathEditPreferences),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: provider.isArchiving ? null : () => _archivePath(provider),
          icon: provider.isArchiving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.archive_outlined),
          label: Text(context.l10n.aiPathArchive),
        ),
      ],
    );
  }

  Widget _buildPathStep(AiLearningPathStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              '${step.position}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.getSoftGray150(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (step.stage.isNotEmpty)
                    Text(
                      step.stage.toUpperCase(),
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  if (step.stage.isNotEmpty) const SizedBox(height: 7),
                  Text(
                    step.course.title,
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _detailBlock(context.l10n.aiPathObjective, step.objective),
                  const SizedBox(height: 10),
                  _detailBlock(context.l10n.aiPathWhy, step.reason),
                  const SizedBox(height: 12),
                  _metaChip(
                    Icons.schedule_rounded,
                    '${step.estimatedHours} '
                    '${context.l10n.aiPathHours}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailBlock(String label, String value) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: AppTheme.getTextColor(context).withValues(alpha: 0.55),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.getTextColor(context).withValues(alpha: 0.78),
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppTheme.getSoftGray150(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: AppTheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _choiceWrap({
    required List<String> values,
    required String selectedValue,
    required String Function(String value) labelBuilder,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: values
          .map((String value) {
            final bool selected = selectedValue == value;

            return ChoiceChip(
              selected: selected,
              label: Text(labelBuilder(value)),
              onSelected: (_) => onSelected(value),
              selectedColor: AppTheme.primary.withValues(alpha: 0.14),
              side: BorderSide(
                color: selected
                    ? AppTheme.primary
                    : AppTheme.getSoftGray150(context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            );
          })
          .toList(growable: false),
    );
  }

  Widget _sectionTitle(String value) {
    return Text(
      value,
      style: TextStyle(
        color: AppTheme.getTextColor(context),
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _sectionHint(String value) {
    return Text(
      value,
      style: TextStyle(
        color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
        height: 1.4,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _inlineError(
    String message, {
    required Future<void> Function() onRetry,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.72),
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(context.l10n.aiPathRetry)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {String? suffixText}) {
    return InputDecoration(
      labelText: label,
      suffixText: suffixText,
      filled: true,
      fillColor: AppTheme.getBackgroundColor(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppTheme.getSoftGray150(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppTheme.getSoftGray150(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
      ),
    );
  }

  String? _readinessMessage(String? code, dynamic readiness) {
    switch (code) {
      case 'READY':
        return context.l10n.aiPathReadyBody;
      case 'NO_MATCHING_COURSES':
        return context.l10n.aiPathNoMatching;
      case 'INSUFFICIENT_CATALOG':
        return context.l10n.aiPathInsufficient;
      case 'ALL_MATCHING_COURSES_COMPLETED':
        return context.l10n.aiPathAllCompleted;
      case 'LEARNING_PROFILE_REQUIRED':
        return context.l10n.aiPathProfileRequired;
      default:
        return null;
    }
  }

  String _skillLabel(String value) {
    switch (value) {
      case 'beginner':
        return context.l10n.aiPathBeginner;
      case 'intermediate':
        return context.l10n.aiPathIntermediate;
      case 'advanced':
        return context.l10n.aiPathAdvanced;
      default:
        return value;
    }
  }

  String _goalLabel(String value) {
    switch (value) {
      case 'career_change':
        return context.l10n.aiPathCareerChange;
      case 'skill_enhancement':
        return context.l10n.aiPathSkillEnhancement;
      case 'personal_interest':
        return context.l10n.aiPathPersonalInterest;
      case 'certification':
        return context.l10n.aiPathCertification;
      case 'freelancing':
        return context.l10n.aiPathFreelancing;
      case 'custom':
        return context.l10n.aiPathCustom;
      default:
        return value;
    }
  }

  String _learningStyleLabel(String value) {
    switch (value) {
      case 'fast':
        return context.l10n.aiPathFast;
      case 'balanced':
        return context.l10n.aiPathBalanced;
      case 'in_depth':
        return context.l10n.aiPathInDepth;
      default:
        return value;
    }
  }

  String _languageLabel(String value) {
    switch (value) {
      case 'fr':
        return 'FranÃ§ais';
      case 'nl':
        return 'Nederlands';
      case 'de':
        return 'Deutsch';
      case 'en':
        return 'English';
      default:
        return value.toUpperCase();
    }
  }

  String _formatDate(DateTime value) {
    final String day = value.day.toString().padLeft(2, '0');
    final String month = value.month.toString().padLeft(2, '0');

    return '$day/$month/${value.year}';
  }
}

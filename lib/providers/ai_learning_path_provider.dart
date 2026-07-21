import 'package:flutter/foundation.dart';

import '../models/ai_learning_path.dart';
import '../models/ai_learning_path_readiness.dart';
import '../models/ai_learning_profile.dart';
import '../services/ai_learning_path_service.dart';

class AiLearningPathProvider extends ChangeNotifier {
  AiLearningPathProvider({AiLearningPathService? service})
    : _service = service ?? AiLearningPathService();

  final AiLearningPathService _service;

  AiLearningProfile? _profile;
  AiLearningPath? _currentPath;
  AiLearningPathReadiness? _readiness;

  bool _isLoading = false;
  bool _isSavingProfile = false;
  bool _isGenerating = false;
  bool _isArchiving = false;

  String? _businessCode;
  String? _errorMessage;

  AiLearningProfile? get profile => _profile;
  AiLearningPath? get currentPath => _currentPath;
  AiLearningPathReadiness? get readiness => _readiness;

  bool get isLoading => _isLoading;
  bool get isSavingProfile => _isSavingProfile;
  bool get isGenerating => _isGenerating;
  bool get isArchiving => _isArchiving;

  String? get businessCode => _businessCode;
  String? get errorMessage => _errorMessage;

  bool get hasProfile => _profile?.exists ?? false;
  bool get hasCurrentPath => _currentPath != null;
  bool get canGenerate => _readiness?.ready ?? false;

  Future<void> initialize() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _clearFeedback();
    notifyListeners();

    try {
      final List<Object?> results = await Future.wait<Object?>([
        _service.fetchProfile(),
        _service.fetchCurrentPath(),
      ]);

      _profile = results[0] as AiLearningProfile;
      _currentPath = results[1] as AiLearningPath?;

      if (_profile?.exists == true && _currentPath == null) {
        await _loadReadinessWithoutNotification();
      }
    } on AiLearningPathApiException catch (exception) {
      _applyApiException(exception);
    } catch (exception) {
      _errorMessage = exception.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile(AiLearningProfile profile) async {
    if (_isSavingProfile) {
      return false;
    }

    _isSavingProfile = true;
    _clearFeedback();
    notifyListeners();

    try {
      _profile = await _service.updateProfile(profile);
      await _loadReadinessWithoutNotification();

      return true;
    } on AiLearningPathApiException catch (exception) {
      _applyApiException(exception);

      return false;
    } catch (exception) {
      _errorMessage = exception.toString();

      return false;
    } finally {
      _isSavingProfile = false;
      notifyListeners();
    }
  }

  Future<bool> checkReadiness() async {
    _clearFeedback();
    notifyListeners();

    try {
      await _loadReadinessWithoutNotification();

      return _readiness?.ready ?? false;
    } on AiLearningPathApiException catch (exception) {
      _applyApiException(exception);

      return false;
    } catch (exception) {
      _errorMessage = exception.toString();

      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> generatePath({required String locale}) async {
    if (_isGenerating) {
      return false;
    }

    _isGenerating = true;
    _clearFeedback();
    notifyListeners();

    try {
      _currentPath = await _service.generatePath(locale: locale);

      _businessCode = 'PATH_CREATED';

      return true;
    } on AiLearningPathApiException catch (exception) {
      _applyApiException(exception);

      final Map<String, dynamic>? data = exception.dataMap;

      if (data != null) {
        _readiness = AiLearningPathReadiness.fromJson(data);
      }

      return false;
    } catch (exception) {
      _errorMessage = exception.toString();

      return false;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<bool> archiveCurrentPath() async {
    final AiLearningPath? path = _currentPath;

    if (path == null || _isArchiving) {
      return false;
    }

    _isArchiving = true;
    _clearFeedback();
    notifyListeners();

    try {
      await _service.archivePath(path.id);

      _currentPath = null;
      _businessCode = 'PATH_ARCHIVED';

      if (_profile?.exists == true) {
        await _loadReadinessWithoutNotification();
      }

      return true;
    } on AiLearningPathApiException catch (exception) {
      _applyApiException(exception);

      return false;
    } catch (exception) {
      _errorMessage = exception.toString();

      return false;
    } finally {
      _isArchiving = false;
      notifyListeners();
    }
  }

  Future<void> reloadCurrentPath() async {
    _clearFeedback();

    try {
      _currentPath = await _service.fetchCurrentPath();
    } on AiLearningPathApiException catch (exception) {
      _applyApiException(exception);
    } catch (exception) {
      _errorMessage = exception.toString();
    } finally {
      notifyListeners();
    }
  }

  void clearFeedback() {
    _clearFeedback();
    notifyListeners();
  }

  Future<void> _loadReadinessWithoutNotification() async {
    _readiness = await _service.fetchReadiness();
    _businessCode = _readiness?.code;
  }

  void _applyApiException(AiLearningPathApiException exception) {
    _businessCode = exception.code;
    _errorMessage = exception.message;
  }

  void _clearFeedback() {
    _businessCode = null;
    _errorMessage = null;
  }
}

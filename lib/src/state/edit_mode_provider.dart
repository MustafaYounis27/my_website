import 'package:flutter/material.dart';

class EditModeProvider extends ChangeNotifier {
  bool _isEditMode = false;
  bool _isOwner = false;
  
  bool get isEditMode => _isEditMode && _isOwner;
  bool get isOwner => _isOwner;
  
  EditModeProvider() {
    _checkOwnership();
  }
  
  void _checkOwnership() {
    // Check if user is owner based on URL parameters or local storage
    final uri = Uri.base;
    final editParam = uri.queryParameters['edit'];
    
    // Enable edit mode only if:
    // 1. URL has edit=true parameter OR
    // 2. Running locally (localhost)
    _isOwner = editParam == 'true' || 
               uri.host == 'localhost' || 
               uri.host == '127.0.0.1';
    
    // Start with edit mode off even for owner
    _isEditMode = false;
  }
  
  void toggleEditMode() {
    if (_isOwner) {
      _isEditMode = !_isEditMode;
      notifyListeners();
    }
  }
  
  void enableEditMode() {
    if (_isOwner) {
      _isEditMode = true;
      notifyListeners();
    }
  }
  
  void disableEditMode() {
    _isEditMode = false;
    notifyListeners();
  }
}

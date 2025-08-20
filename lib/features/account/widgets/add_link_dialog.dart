// Separate dialog for adding/editing links
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../core/models/advanced_profile_models.dart';
import '../services/advanced_profile_service.dart';

class AddLinkDialog extends StatefulWidget {
  final AdvancedProfileType type;
  final AdvancedProfileLink? existingLink;
  final Function(AdvancedProfileLink) onLinkAdded;

  const AddLinkDialog({
    super.key,
    required this.type,
    this.existingLink,
    required this.onLinkAdded,
  });

  @override
  State<AddLinkDialog> createState() => _AddLinkDialogState();
}

class _AddLinkDialogState extends State<AddLinkDialog> {
  late TextEditingController _urlController;
  late TextEditingController _titleController;
  bool _isValidating = false;
  ValidationResult? _validationResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(
      text: widget.existingLink?.url ?? '',
    );
    _titleController = TextEditingController(
      text: widget.existingLink?.customTitle ?? '',
    );

    // Auto-validate if editing existing link
    if (widget.existingLink != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _validateUrl();
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existingLink != null
            ? 'Edit ${widget.type.displayName}'
            : 'Add ${widget.type.displayName}',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // URL input
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'URL',
                hintText: widget.type.placeholder,
                prefixIcon: Icon(widget.type.icon),
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
                suffixIcon:
                    _isValidating
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                        : _validationResult?.isValid == true
                        ? Icon(
                          _validationResult!.isReachable
                              ? Icons.check_circle
                              : Icons.warning,
                          color:
                              _validationResult!.isReachable
                                  ? Colors.green
                                  : Colors.orange,
                        )
                        : null,
              ),
              onChanged: (_) {
                setState(() {
                  _errorMessage = null;
                  _validationResult = null;
                });
              },
              onSubmitted: (_) => _validateUrl(),
            ),

            const SizedBox(height: 16),

            // Custom title for custom links
            if (widget.type == AdvancedProfileType.custom) ...[
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Custom Title',
                  hintText: 'e.g., My Portfolio, Company Website',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Validation status
            if (_validationResult != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      _validationResult!.isReachable
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        _validationResult!.isReachable
                            ? Colors.green
                            : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _validationResult!.isReachable
                          ? Icons.check_circle
                          : Icons.warning,
                      color:
                          _validationResult!.isReachable
                              ? Colors.green
                              : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _validationResult!.isReachable
                            ? 'URL is valid and reachable'
                            : _validationResult!.errorMessage ??
                                'URL format is valid but not reachable',
                        style: TextStyle(
                          color:
                              _validationResult!.isReachable
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Help text
            Text(
              'Example: ${widget.type.placeholder}',
              style: TextStyle(color: AppColors.textLight, fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canSave ? _saveLink : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primarySageGreen,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.existingLink != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  bool get _canSave {
    return _urlController.text.trim().isNotEmpty &&
        !_isValidating &&
        _validationResult?.isValid == true &&
        (widget.type != AdvancedProfileType.custom ||
            _titleController.text.trim().isNotEmpty);
  }

  Future<void> _validateUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _isValidating = true);

    try {
      final result = await AdvancedProfileService.validateUrl(url, widget.type);
      setState(() {
        _validationResult = result;
        _errorMessage = result.isValid ? null : result.errorMessage;
        _isValidating = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Validation failed. Please try again.';
        _isValidating = false;
      });
    }
  }

  Future<void> _saveLink() async {
    if (!_canSave) return;

    // Validate before saving
    await _validateUrl();
    if (_validationResult?.isValid != true) return;

    final link = AdvancedProfileLink(
      type: widget.type,
      url: _urlController.text.trim(),
      customTitle:
          widget.type == AdvancedProfileType.custom
              ? _titleController.text.trim()
              : null,
      addedAt: DateTime.now(),
      isVerified: _validationResult?.isReachable == true,
    );

    try {
      final success = await AdvancedProfileService.saveProfileLink(link);

      if (success) {
        // Update profile completion
        await AdvancedProfileService.updateProfileCompletion();

        Navigator.of(context).pop();
        widget.onLinkAdded(link);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.existingLink != null
                    ? 'Link updated successfully! ✅'
                    : 'Link added successfully! ✅',
              ),
              backgroundColor: AppColors.primarySageGreen,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save link. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving link. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

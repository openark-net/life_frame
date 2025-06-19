import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:talker/talker.dart';

class LocationSelectionModal extends StatefulWidget {
  final String? initialLocation;

  const LocationSelectionModal({super.key, this.initialLocation});

  @override
  State<LocationSelectionModal> createState() => _LocationSelectionModalState();
}

class _LocationSelectionModalState extends State<LocationSelectionModal> {
  late TextEditingController _locationController;
  late Talker _talker;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(
      text: widget.initialLocation ?? '',
    );
    _talker = Get.find<Talker>();
    _talker.info('Location selection modal opened', {
      'initialLocation': widget.initialLocation,
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _onCancel() {
    Navigator.of(context).pop(null);
  }

  void _onSave() {
    final location = _locationController.text.trim();
    Navigator.of(context).pop(location.isEmpty ? null : location);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Update Location'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _onCancel,
          child: const Text('Cancel'),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _onSave,
          child: const Text(
            'Save',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Location',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the location where this photo was taken.',
                style: TextStyle(
                  fontSize: 15,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _locationController,
                placeholder: 'Enter location...',
                style: const TextStyle(fontSize: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).scaffoldBackgroundColor,
                  border: Border.all(
                    color: CupertinoColors.separator.resolveFrom(context),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                maxLines: 3,
                minLines: 1,
                textCapitalization: TextCapitalization.words,
                autofocus: true,
              ),
              const SizedBox(height: 24),
              const Text(
                'Examples: "Vancouver Island", "Tofino", "Strathcona", Home',
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

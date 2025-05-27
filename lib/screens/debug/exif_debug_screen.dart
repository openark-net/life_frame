import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_exif/native_exif.dart';

class ExifViewerWidget extends StatefulWidget {
  const ExifViewerWidget({Key? key}) : super(key: key);

  @override
  State<ExifViewerWidget> createState() => _ExifViewerWidgetState();
}

class _ExifViewerWidgetState extends State<ExifViewerWidget> {
  String? _selectedImagePath;
  Map<String, dynamic> _exifData = {};
  Map<String, dynamic> _gpsDebugData = {};
  bool _isLoading = false;
  String? _error;

  final ImagePicker _picker = ImagePicker();

  // Comprehensive list of GPS-related EXIF tags
  final List<String> _gpsExifTags = [
    'GPSVersionID',
    'GPSLatitude',
    'GPSLatitudeRef',
    'GPSLongitude',
    'GPSLongitudeRef',
    'GPSAltitude',
    'GPSAltitudeRef',
    'GPSTimeStamp',
    'GPSDateStamp',
    'GPSMapDatum',
    'GPSProcessingMethod',
    'GPSAreaInformation',
    'GPSImgDirection',
    'GPSImgDirectionRef',
    'GPSDestBearing',
    'GPSDestBearingRef',
    'GPSDestDistance',
    'GPSDestDistanceRef',
    'GPSSpeed',
    'GPSSpeedRef',
    'GPSTrack',
    'GPSTrackRef',
    'GPSSatellites',
    'GPSStatus',
    'GPSMeasureMode',
    'GPSDOP',
    'GPSDestLatitude',
    'GPSDestLatitudeRef',
    'GPSDestLongitude',
    'GPSDestLongitudeRef',
    'GPSDifferential',
    'GPSHPositioningError',
  ];

  // List of common EXIF tags to check
  final List<String> _commonExifTags = [
    // Basic image info
    'Make',
    'Model',
    'Software',
    'DateTime',
    'DateTimeOriginal',
    'DateTimeDigitized',
    'ImageWidth',
    'ImageLength',
    'Orientation',
    'XResolution',
    'YResolution',
    'ResolutionUnit',

    // Camera settings
    'ExposureTime',
    'FNumber',
    'ISO',
    'ISOSpeedRatings',
    'ExposureProgram',
    'MeteringMode',
    'Flash',
    'FocalLength',
    'WhiteBalance',
    'ExposureMode',
    'SceneCaptureType',

    // Additional metadata
    'UserComment',
    'ColorSpace',
    'PixelXDimension',
    'PixelYDimension',
    'Compression',
    'PhotometricInterpretation',

    // Possible location-related tags
    'LocationInformation',
    'Location',
    'GPSInfo',
    'SubjectLocation',
  ];

  Future<void> _pickImage() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _exifData = {};
        _gpsDebugData = {};
      });

      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
        await _readExifData(image.path);
      }
    } catch (e) {
      setState(() {
        _error = 'Error picking image: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _readExifData(String imagePath) async {
    try {
      final exif = await Exif.fromPath(imagePath);
      Map<String, dynamic> exifData = {};
      Map<String, dynamic> gpsDebugData = {};

      try {
        // Try built-in GPS methods first
        try {
          final latLong = await exif.getLatLong();
          if (latLong != null) {
            gpsDebugData['[Built-in] getLatLong() SUCCESS'] =
                '${latLong.latitude}, ${latLong.longitude}';
            exifData['[Parsed] Latitude'] = latLong.latitude;
            exifData['[Parsed] Longitude'] = latLong.longitude;
          } else {
            gpsDebugData['[Built-in] getLatLong()'] =
                'NULL - No GPS data found by built-in method';
          }
        } catch (e) {
          gpsDebugData['[Built-in] getLatLong() ERROR'] = e.toString();
        }

        // Try to get original date
        try {
          final originalDate = await exif.getOriginalDate();
          if (originalDate != null) {
            exifData['[Parsed] Original Date'] = originalDate.toString();
          }
        } catch (e) {
          gpsDebugData['[Built-in] getOriginalDate() ERROR'] = e.toString();
        }

        // Extensively check GPS tags
        gpsDebugData['=== GPS TAG SCAN ==='] = 'Checking all known GPS tags...';
        int gpsTagsFound = 0;

        for (String tag in _gpsExifTags) {
          try {
            final value = await exif.getAttribute<dynamic>(tag);
            if (value != null) {
              exifData[tag] = value;
              gpsDebugData['GPS FOUND: $tag'] = value.toString();
              gpsTagsFound++;
            }
          } catch (e) {
            gpsDebugData['GPS ERROR: $tag'] = e.toString();
          }
        }

        gpsDebugData['=== GPS SUMMARY ==='] = '$gpsTagsFound GPS tags found';

        // Read all common EXIF tags
        for (String tag in _commonExifTags) {
          try {
            final value = await exif.getAttribute<dynamic>(tag);
            if (value != null) {
              exifData[tag] = value;
            }
          } catch (e) {
            // Tag doesn't exist or can't be read, skip it
          }
        }

        // Try different attribute reading methods
        try {
          gpsDebugData['=== ATTEMPTING getAttributes() ==='] =
              'Trying to get all attributes...';
          final allAttributes = await exif.getAttributes();
          if (allAttributes != null && allAttributes.isNotEmpty) {
            gpsDebugData['getAttributes() SUCCESS'] =
                'Found ${allAttributes.length} total attributes';

            // Look for GPS-related keys
            final gpsKeys = allAttributes.keys
                .where(
                  (key) =>
                      key.toLowerCase().contains('gps') ||
                      key.toLowerCase().contains('location') ||
                      key.toLowerCase().contains('lat') ||
                      key.toLowerCase().contains('lng') ||
                      key.toLowerCase().contains('lon'),
                )
                .toList();

            if (gpsKeys.isNotEmpty) {
              gpsDebugData['GPS-like keys found'] = gpsKeys.toString();
              for (String key in gpsKeys) {
                gpsDebugData['GPS-like: $key'] = allAttributes[key].toString();
              }
            }

            exifData.addAll(allAttributes);
          } else {
            gpsDebugData['getAttributes()'] = 'Returned null or empty';
          }
        } catch (e) {
          gpsDebugData['getAttributes() ERROR'] = e.toString();
        }

        // Try to read raw bytes for GPS IFD (advanced debugging)
        try {
          // Some EXIF data might be in different IFDs (Image File Directories)
          gpsDebugData['=== ADVANCED DEBUG ==='] = 'Checking for GPS IFD...';

          // Try alternative GPS tag names
          final altGpsTags = [
            'GPS IFD',
            'GPS',
            'GPSInfo',
            'GPS Info',
            'Exif.GPS.GPSLatitude',
            'Exif.GPS.GPSLongitude',
          ];

          for (String altTag in altGpsTags) {
            try {
              final value = await exif.getAttribute<dynamic>(altTag);
              if (value != null) {
                gpsDebugData['ALT GPS TAG: $altTag'] = value.toString();
              }
            } catch (e) {
              // Ignore
            }
          }
        } catch (e) {
          gpsDebugData['Advanced debug ERROR'] = e.toString();
        }
      } finally {
        await exif.close();
      }

      setState(() {
        _exifData = exifData;
        _gpsDebugData = gpsDebugData;
      });
    } catch (e) {
      setState(() {
        _error = 'Error reading EXIF data: $e';
        _gpsDebugData = {'CRITICAL ERROR': e.toString()};
      });
    }
  }

  Widget _buildGpsDebugDisplay() {
    if (_gpsDebugData.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GPS Debug Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.systemRed,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemRed.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CupertinoColors.systemRed.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: _gpsDebugData.entries.map((entry) {
              final isError = entry.key.contains('ERROR');
              final isSuccess =
                  entry.key.contains('SUCCESS') || entry.key.contains('FOUND');

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: isError
                              ? CupertinoColors.systemRed
                              : isSuccess
                              ? CupertinoColors.systemGreen
                              : CupertinoColors.label,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.value.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: isError
                              ? CupertinoColors.systemRed
                              : CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildExifDisplay() {
    if (_exifData.isEmpty) {
      return const Text(
        'No EXIF data found or image not selected',
        style: TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 16),
      );
    }

    // Separate GPS data from other EXIF data
    final gpsEntries = _exifData.entries
        .where(
          (entry) =>
              entry.key.toLowerCase().contains('gps') ||
              entry.key.toLowerCase().contains('location') ||
              entry.key.contains('[Parsed]'),
        )
        .toList();

    final otherEntries = _exifData.entries
        .where(
          (entry) =>
              !entry.key.toLowerCase().contains('gps') &&
              !entry.key.toLowerCase().contains('location') &&
              !entry.key.contains('[Parsed]'),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (gpsEntries.isNotEmpty) ...[
          Text(
            'GPS/Location Data (${gpsEntries.length} entries)',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemGreen,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CupertinoColors.systemGreen.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: gpsEntries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: CupertinoColors.systemGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.value.toString(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.label,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],

        Text(
          'Other EXIF Data (${otherEntries.length} entries)',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.secondarySystemBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CupertinoColors.separator, width: 0.5),
          ),
          child: Column(
            children: otherEntries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: CupertinoColors.label,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('EXIF Data Viewer'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CupertinoButton.filled(
                onPressed: _isLoading ? null : _pickImage,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(CupertinoIcons.photo_on_rectangle),
                    SizedBox(width: 8),
                    Text('Select Photo from Gallery'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_selectedImagePath != null) ...[
                Text(
                  'Selected: ${_selectedImagePath!.split('/').last}',
                  style: const TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CupertinoActivityIndicator(radius: 16),
                  ),
                ),

              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CupertinoColors.systemRed.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        color: CupertinoColors.systemRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: CupertinoColors.systemRed,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              Expanded(
                child: CupertinoScrollbar(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [_buildGpsDebugDisplay(), _buildExifDisplay()],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

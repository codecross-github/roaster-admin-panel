import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:math' as math;
import '../core/constants.dart';
import '../widgets/admin_layout.dart';
import '../widgets/player_photo_upload.dart';

class HitterReportFormScreen extends StatefulWidget {
  const HitterReportFormScreen({super.key});

  @override
  State<HitterReportFormScreen> createState() => _HitterReportFormScreenState();
}

class _HitterReportFormScreenState extends State<HitterReportFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // User Search
  final _userSearchController = TextEditingController();
  String? _selectedUserId;
  String? _selectedUserName;

  // Sample users for search
  final List<Map<String, String>> _users = [
    {'id': '1', 'name': 'John Smith', 'email': 'john@example.com'},
    {'id': '2', 'name': 'Jane Doe', 'email': 'jane@example.com'},
    {'id': '3', 'name': 'Bob Wilson', 'email': 'bob@example.com'},
    {'id': '4', 'name': 'Sarah Miller', 'email': 'sarah@example.com'},
    {'id': '5', 'name': 'Tom Davis', 'email': 'tom@example.com'},
  ];

  // Player Info
  final _playerNameController = TextEditingController();
  String _selectedPosition = 'CF';
  String _selectedBats = 'R';
  String _selectedThrows = 'R';

  // Hitter Stats
  final _airPullController = TextEditingController(text: '12.5');
  final _chaseController = TextEditingController(text: '28.3');
  final _ninetiethRVController = TextEditingController(text: '102.5');
  final _bbController = TextEditingController(text: '9.2');
  final _missController = TextEditingController(text: '22.1');
  final _kController = TextEditingController(text: '18.5');
  final _exitVeloController = TextEditingController(text: '92.3');
  final _battingAvgController = TextEditingController(text: '.285');

  // Summary
  final _scoutSummaryController = TextEditingController();

  // Player Image
  Uint8List? _playerImageBytes;
  String? _playerImageFileName;

  // Videos (2 videos)
  String? _videoFileName1;
  String? _videoFileName2;

  @override
  void dispose() {
    _userSearchController.dispose();
    _playerNameController.dispose();
    _airPullController.dispose();
    _chaseController.dispose();
    _ninetiethRVController.dispose();
    _bbController.dispose();
    _missController.dispose();
    _kController.dispose();
    _exitVeloController.dispose();
    _battingAvgController.dispose();
    _scoutSummaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentIndex: 4,
      title: 'New Hitter Report',
      actions: [
        OutlinedButton.icon(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close, size: 18),
          label: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _saveReport,
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Save Report'),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // User Search Card
                    _buildCard(
                      title: 'Assign to User',
                      subtitle: 'Search for the user who requested this report',
                      child: _buildUserSearch(),
                    ),

                    const SizedBox(height: 20),

                    // Player Info Card
                    _buildCard(
                      title: 'Player Information',
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              label: 'Player Name',
                              controller: _playerNameController,
                              hint: 'Enter player name',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Position',
                              value: _selectedPosition,
                              items: ['C', '1B', '2B', '3B', 'SS', 'LF', 'CF', 'RF', 'DH'],
                              onChanged: (v) => setState(() => _selectedPosition = v!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Bats',
                              value: _selectedBats,
                              items: AppConstants.batsOptions,
                              onChanged: (v) => setState(() => _selectedBats = v!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Throws',
                              value: _selectedThrows,
                              items: AppConstants.throwsOptions,
                              onChanged: (v) => setState(() => _selectedThrows = v!),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Hitting Stats
                    _buildCard(
                      title: 'Hitting Statistics',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildStatInput('Airpull%', _airPullController)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildStatInput('Chase%', _chaseController)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildStatInput('90th RV', _ninetiethRVController)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildStatInput('BB%', _bbController)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildStatInput('Miss%', _missController)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildStatInput('K%', _kController)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildStatInput('Exit Velo', _exitVeloController)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildStatInput('Batting Avg', _battingAvgController)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Game Footage - 2 Videos
                    _buildCard(
                      title: 'Game Footage',
                      subtitle: 'Upload 2 video clips',
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildVideoUpload(
                              label: 'Video 1',
                              fileName: _videoFileName1,
                              onPick: () => setState(() => _videoFileName1 = 'hitter_clip_1.mp4'),
                              onRemove: () => setState(() => _videoFileName1 = null),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildVideoUpload(
                              label: 'Video 2',
                              fileName: _videoFileName2,
                              onPick: () => setState(() => _videoFileName2 = 'hitter_clip_2.mp4'),
                              onRemove: () => setState(() => _videoFileName2 = null),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Right Column
              Expanded(
                child: Column(
                  children: [
                    // Player Photo
                    _buildCard(
                      title: 'Player Photo',
                      child: PlayerPhotoUpload(
                        imageBytes: _playerImageBytes,
                        imageFileName: _playerImageFileName,
                        onPick: _pickPlayerImage,
                        onRemove: _removePlayerImage,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Graphics Section - 2 Graphics (Spray Chart + Zone Heatmap)
                    _buildCard(
                      title: 'Spray Chart',
                      child: Column(
                        children: [
                          _buildSprayChartFan(),
                          const SizedBox(height: 12),
                          // Legend
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendItem(const Color(0xFF3B82F6), 'Low'),
                              const SizedBox(width: 16),
                              _buildLegendItem(const Color(0xFF22C55E), 'Medium'),
                              const SizedBox(width: 16),
                              _buildLegendItem(const Color(0xFFEF4444), 'High'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Zone Heatmap
                    _buildCard(
                      title: 'Zone Heatmap',
                      child: Column(
                        children: [
                          _buildZoneHeatmap(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendItem(const Color(0xFF3B82F6), 'Low'),
                              const SizedBox(width: 16),
                              _buildLegendItem(const Color(0xFF22C55E), 'Medium'),
                              const SizedBox(width: 16),
                              _buildLegendItem(const Color(0xFFEF4444), 'High'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Scout Summary
                    _buildCard(
                      title: 'Scout Summary',
                      child: TextFormField(
                        controller: _scoutSummaryController,
                        maxLines: 6,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(
                          hintText: 'Enter detailed scout analysis...',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Field
        Autocomplete<Map<String, String>>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Map<String, String>>.empty();
            }
            return _users.where((user) =>
                user['name']!.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                user['email']!.toLowerCase().contains(textEditingValue.text.toLowerCase()));
          },
          displayStringForOption: (user) => user['name']!,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'Search by user name...',
                prefixIcon: const Icon(Icons.search, color: AppColors.gray),
                suffixIcon: _selectedUserId != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.gray),
                        onPressed: () {
                          controller.clear();
                          setState(() {
                            _selectedUserId = null;
                            _selectedUserName = null;
                          });
                        },
                      )
                    : null,
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: AppColors.card,
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200, maxWidth: 400),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final user = options.elementAt(index);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          child: Text(
                            user['name']![0],
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ),
                        title: Text(user['name']!, style: const TextStyle(color: AppColors.white)),
                        subtitle: Text(user['email']!, style: const TextStyle(color: AppColors.gray, fontSize: 12)),
                        onTap: () {
                          onSelected(user);
                          setState(() {
                            _selectedUserId = user['id'];
                            _selectedUserName = user['name'];
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
          onSelected: (user) {
            setState(() {
              _selectedUserId = user['id'];
              _selectedUserName = user['name'];
            });
          },
        ),

        // Selected User Display
        if (_selectedUserId != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Assigned to: $_selectedUserName',
                  style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCard({
    required String title,
    String? subtitle,
    Widget? action,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.gray, fontSize: 12),
                    ),
                ],
              ),
              if (action != null) action,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.gray, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(hintText: hint),
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.gray, fontSize: 13)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          dropdownColor: AppColors.card,
          style: const TextStyle(color: AppColors.white),
        ),
      ],
    );
  }

  Widget _buildStatInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.gray, fontSize: 12)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: AppColors.sidebarBg,
          ),
        ),
      ],
    );
  }

  // Spray Chart Fan - same as main app
  Widget _buildSprayChartFan() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CustomPaint(
          size: const Size(double.infinity, 180),
          painter: SprayChartPainter(),
        ),
      ),
    );
  }

  // Zone Heatmap - same as main app
  Widget _buildZoneHeatmap() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CustomPaint(
          size: const Size(double.infinity, 160),
          painter: ZoneHeatmapPainter(),
        ),
      ),
    );
  }

  Widget _buildVideoUpload({
    required String label,
    String? fileName,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.gray, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.sidebarBg,
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: fileName == null
              ? InkWell(
                  onTap: onPick,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 28, color: AppColors.gray),
                        const SizedBox(height: 4),
                        const Text('Upload', style: TextStyle(color: AppColors.gray, fontSize: 12)),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.videocam_outlined, size: 28, color: AppColors.success),
                          const SizedBox(height: 4),
                          Text(
                            fileName,
                            style: const TextStyle(color: AppColors.white, fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        onPressed: onRemove,
                        icon: const Icon(Icons.close, size: 16),
                        color: AppColors.error,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _pickPlayerImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;

      if (file.size > 5 * 1024 * 1024) {
        Get.snackbar(
          'Error',
          'Image must be under 5MB',
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
        );
        return;
      }

      setState(() {
        _playerImageBytes = file.bytes;
        _playerImageFileName = file.name;
      });
    }
  }

  void _removePlayerImage() {
    setState(() {
      _playerImageBytes = null;
      _playerImageFileName = null;
    });
  }

  void _saveReport() {
    if (_formKey.currentState!.validate()) {
      if (_selectedUserId == null) {
        Get.snackbar(
          'Error',
          'Please select a user to assign this report to',
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
        );
        return;
      }
      Get.snackbar(
        'Success',
        'Hitter report saved successfully',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
      Get.offAllNamed('/reports');
    }
  }
}

// Custom painter for the spray chart fan shape - same as main app
class SprayChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height + 20);
    final radius = size.height + 10;

    // Define the colors for the fan sections (from left to right)
    final colors = [
      const Color(0xFF1E40AF), // Dark blue
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF22C55E), // Green
      const Color(0xFFEAB308), // Yellow
      const Color(0xFFF97316), // Orange
      const Color(0xFFEF4444), // Red
      const Color(0xFFDC2626), // Dark red
    ];

    // Draw fan sections
    const startAngle = -math.pi; // -180 degrees (left)
    final sweepAngle = math.pi / colors.length; // Divide 180 degrees by number of colors

    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + (i * sweepAngle),
        sweepAngle,
        true,
        paint,
      );
    }

    // Draw inner rings with varying opacity
    for (int ring = 1; ring <= 4; ring++) {
      final ringRadius = radius * (1 - ring * 0.2);
      final ringPaint = Paint()
        ..color = Colors.black.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: ringRadius),
        startAngle,
        math.pi,
        false,
        ringPaint,
      );
    }

    // Draw radial lines
    for (int i = 1; i < colors.length; i++) {
      final angle = startAngle + (i * sweepAngle);
      final linePaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..strokeWidth = 1;

      final endPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      canvas.drawLine(center, endPoint, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for zone heatmap - same as main app
class ZoneHeatmapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height + 10);
    final radius = size.height;

    // Define the colors for the heatmap sections
    final colors = [
      const Color(0xFF1E40AF), // Dark blue
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF22C55E), // Green
      const Color(0xFFEAB308), // Yellow
      const Color(0xFFF97316), // Orange
      const Color(0xFFEF4444), // Red
    ];

    // Draw fan sections
    const startAngle = -math.pi;
    final sweepAngle = math.pi / colors.length;

    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + (i * sweepAngle),
        sweepAngle,
        true,
        paint,
      );
    }

    // Draw grid overlay
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Horizontal lines
    for (int i = 1; i <= 3; i++) {
      final y = size.height - (i * size.height / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Vertical lines
    for (int i = 1; i <= 3; i++) {
      final x = i * size.width / 4;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

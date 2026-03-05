import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:math' as math;
import '../core/constants.dart';
import '../widgets/admin_layout.dart';
import '../widgets/player_photo_upload.dart';
import '../models/report_model.dart';
import '../models/report_request_model.dart';
import '../services/report_service.dart';

class HitterReportFormScreen extends StatefulWidget {
  const HitterReportFormScreen({super.key});

  @override
  State<HitterReportFormScreen> createState() =>
      _HitterReportFormScreenState();
}

class _HitterReportFormScreenState extends State<HitterReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reportService = ReportService();
  bool _isSaving = false;

  // Request data (if navigated from a report request)
  ReportRequestModel? _fromRequest;

  // User info — supports multiple user IDs
  final List<String> _selectedUserIds = [];
  // Users list fetched from Firestore
  List<Map<String, dynamic>> _allUsers = [];
  bool _isLoadingUsers = true;

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
  Uint8List? _videoBytes1;
  String? _videoFileName2;
  Uint8List? _videoBytes2;

  // Zone Heatmap data (3x3 grids, values 0.0-1.0)
  final List<List<double>> _zoneVsLHP = [
    [0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0],
  ];
  final List<List<double>> _zoneVsRHP = [
    [0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0],
  ];

  // Spray chart points
  final List<SprayChartPoint> _sprayChartPoints = [];

  static const _validHitterPositions = [
    'C', '1B', '2B', '3B', 'SS', 'LF', 'CF', 'RF', 'DH'
  ];

  /// Normalize a position string to one the hitter dropdown accepts.
  /// Handles abbreviations like "OF", "IF", "Outfielder", etc.
  String _normalizeHitterPosition(String pos) {
    const mappings = {
      'OF': 'CF', 'OUTFIELD': 'CF', 'OUTFIELDER': 'CF',
      'LF': 'LF', 'RF': 'RF', 'CF': 'CF',
      'IF': '2B', 'INFIELD': '2B', 'INFIELDER': '2B',
      '1B': '1B', '2B': '2B', '3B': '3B', 'SS': 'SS',
      'C': 'C', 'CATCHER': 'C',
      'DH': 'DH', 'DESIGNATED HITTER': 'DH',
    };
    final normalized = mappings[pos.toUpperCase()];
    if (normalized != null) return normalized;
    // If it already matches a valid position, keep it
    if (_validHitterPositions.contains(pos)) return pos;
    // Default fallback
    return 'CF';
  }

  @override
  void initState() {
    super.initState();
    // Check if navigated from a report request
    final args = Get.arguments;
    if (args is ReportRequestModel) {
      _fromRequest = args;
      _playerNameController.text = args.playerName;
      _selectedPosition = _normalizeHitterPosition(args.playerPosition);
      _selectedUserIds.add(args.userId);
    }

    // Fetch users from Firestore
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _reportService.fetchAllUsers();
      if (mounted) {
        setState(() {
          _allUsers = users;
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading users: $e');
      if (mounted) setState(() => _isLoadingUsers = false);
    }
  }

  /// Get user display text (email) from user ID.
  String _getUserDisplay(String userId) {
    final user = _allUsers.firstWhereOrNull((u) => u['id'] == userId);
    if (user != null) {
      final email = user['email'] ?? '';
      final name = user['name'] ?? '';
      if (email.isNotEmpty && name.isNotEmpty) return '$name ($email)';
      if (email.isNotEmpty) return email;
      if (name.isNotEmpty) return name;
    }
    return userId;
  }

  @override
  void dispose() {
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
      title: _fromRequest != null
          ? 'Report for ${_fromRequest!.playerName}'
          : 'New Hitter Report',
      actions: [
        OutlinedButton.icon(
          onPressed: _isSaving ? null : () => Get.back(),
          icon: const Icon(Icons.close, size: 18),
          label: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _saveReport,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.white),
                )
              : const Icon(Icons.save_outlined, size: 18),
          label: Text(_isSaving ? 'Saving...' : 'Save Report'),
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
                    // User Info Card — multi-user assignment
                    _buildCard(
                      title: 'Assign to Users',
                      subtitle: 'Search and select users to receive this report',
                      child: _buildMultiUserInput(),
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
                              items: [
                                'C', '1B', '2B', '3B', 'SS', 'LF', 'CF',
                                'RF', 'DH'
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedPosition = v!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Bats',
                              value: _selectedBats,
                              items: AppConstants.batsOptions,
                              onChanged: (v) =>
                                  setState(() => _selectedBats = v!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Throws',
                              value: _selectedThrows,
                              items: AppConstants.throwsOptions,
                              onChanged: (v) =>
                                  setState(() => _selectedThrows = v!),
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
                              Expanded(
                                  child: _buildStatInput(
                                      'Airpull%', _airPullController)),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _buildStatInput(
                                      'Chase%', _chaseController)),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _buildStatInput(
                                      '90th RV', _ninetiethRVController)),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _buildStatInput(
                                      'BB%', _bbController)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildStatInput(
                                      'Miss%', _missController)),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _buildStatInput(
                                      'K%', _kController)),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _buildStatInput(
                                      'Exit Velo', _exitVeloController)),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _buildStatInput(
                                      'Batting Avg',
                                      _battingAvgController)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Game Footage - 2 Videos
                    _buildCard(
                      title: 'Game Footage',
                      subtitle: 'Upload up to 2 video clips',
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildVideoUpload(
                              label: 'Video 1',
                              fileName: _videoFileName1,
                              onPick: () => _pickVideoFile(1),
                              onRemove: () => setState(() {
                                _videoFileName1 = null;
                                _videoBytes1 = null;
                              }),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildVideoUpload(
                              label: 'Video 2',
                              fileName: _videoFileName2,
                              onPick: () => _pickVideoFile(2),
                              onRemove: () => setState(() {
                                _videoFileName2 = null;
                                _videoBytes2 = null;
                              }),
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

                    // Spray Chart
                    _buildCard(
                      title: 'Spray Chart',
                      subtitle: 'Click on chart to add hit data points (${_sprayChartPoints.length} points)',
                      action: _sprayChartPoints.isNotEmpty
                          ? TextButton.icon(
                              onPressed: () => setState(() => _sprayChartPoints.clear()),
                              icon: const Icon(Icons.clear_all, size: 16),
                              label: const Text('Clear'),
                            )
                          : null,
                      child: Column(
                        children: [
                          _buildSprayChartFan(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendItem(
                                  const Color(0xFF22C55E), 'Single'),
                              const SizedBox(width: 8),
                              _buildLegendItem(
                                  const Color(0xFFEAB308), 'Double'),
                              const SizedBox(width: 8),
                              _buildLegendItem(
                                  const Color(0xFFF97316), 'Triple'),
                              const SizedBox(width: 8),
                              _buildLegendItem(
                                  const Color(0xFFEF4444), 'HR'),
                              const SizedBox(width: 8),
                              _buildLegendItem(
                                  const Color(0xFF6B7280), 'Out'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Zone Heatmap
                    _buildCard(
                      title: 'Zone Heatmap',
                      subtitle: 'Click cells to set probability values (0.0 – 1.0)',
                      child: Column(
                        children: [
                          _buildZoneHeatmap(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendItem(
                                  const Color(0xFF1E40AF), 'Cold'),
                              const SizedBox(width: 16),
                              _buildLegendItem(
                                  const Color(0xFF22C55E), 'Warm'),
                              const SizedBox(width: 16),
                              _buildLegendItem(
                                  const Color(0xFFEF4444), 'Hot'),
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

  Widget _buildMultiUserInput() {
    final searchController = TextEditingController();
    return StatefulBuilder(
      builder: (context, setLocalState) {
        // Filter users not already selected, matching search
        final query = searchController.text.toLowerCase();
        final availableUsers = _allUsers.where((u) {
          if (_selectedUserIds.contains(u['id'])) return false;
          if (query.isEmpty) return true;
          final name = (u['name'] ?? '').toString().toLowerCase();
          final email = (u['email'] ?? '').toString().toLowerCase();
          return name.contains(query) || email.contains(query);
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // From request info
            if (_fromRequest != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Requested by: ${_fromRequest!.userName}',
                          style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          _fromRequest!.userEmail,
                          style: const TextStyle(
                              color: AppColors.gray, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Search field
            TextField(
              controller: searchController,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                hintText: 'Search users by name or email...',
                prefixIcon: Icon(Icons.person_search, color: AppColors.gray),
              ),
              onChanged: (_) => setLocalState(() {}),
            ),

            const SizedBox(height: 8),

            // Users list
            if (_isLoadingUsers)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                ),
              )
            else if (availableUsers.isEmpty && query.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No users found matching search',
                  style: TextStyle(color: AppColors.gray, fontSize: 12),
                ),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  color: AppColors.sidebarBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableUsers.length,
                  itemBuilder: (ctx, index) {
                    final user = availableUsers[index];
                    final name = user['name'] ?? '';
                    final email = user['email'] ?? '';
                    final isPremium = user['isPremium'] == true;
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: isPremium
                            ? AppColors.premium.withOpacity(0.2)
                            : AppColors.gray.withOpacity(0.2),
                        child: Icon(
                          Icons.person,
                          size: 14,
                          color: isPremium ? AppColors.premium : AppColors.gray,
                        ),
                      ),
                      title: Text(
                        name.isNotEmpty ? name : 'No Name',
                        style: const TextStyle(
                            color: AppColors.white, fontSize: 13),
                      ),
                      subtitle: Text(
                        email,
                        style: const TextStyle(
                            color: AppColors.gray, fontSize: 11),
                      ),
                      trailing: isPremium
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.premium.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Premium',
                                  style: TextStyle(
                                      color: AppColors.premium, fontSize: 9)),
                            )
                          : null,
                      onTap: () {
                        setState(() => _selectedUserIds.add(user['id']));
                        setLocalState(() {});
                        searchController.clear();
                      },
                    );
                  },
                ),
              ),

            // Selected user chips (show email)
            if (_selectedUserIds.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Assigned Users:',
                  style: TextStyle(color: AppColors.gray, fontSize: 11)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedUserIds.map((id) {
                  return Chip(
                    avatar: const CircleAvatar(
                      radius: 10,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, size: 12, color: Colors.white),
                    ),
                    label: Text(
                      _getUserDisplay(id),
                      style: const TextStyle(
                          color: AppColors.white, fontSize: 12),
                    ),
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    deleteIconColor: AppColors.error,
                    onDeleted: () {
                      setState(() => _selectedUserIds.remove(id));
                      setLocalState(() {});
                    },
                    side:
                        BorderSide(color: AppColors.primary.withOpacity(0.4)),
                  );
                }).toList(),
              ),
            ],
          ],
        );
      },
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
                      style: const TextStyle(
                          color: AppColors.gray, fontSize: 12),
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
        Text(label,
            style: const TextStyle(color: AppColors.gray, fontSize: 13)),
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
        Text(label,
            style: const TextStyle(color: AppColors.gray, fontSize: 13)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
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
        Text(label,
            style: const TextStyle(color: AppColors.gray, fontSize: 12)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: AppColors.white, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: AppColors.sidebarBg,
          ),
        ),
      ],
    );
  }

  // Spray Chart Fan — interactive: click to add data points
  Widget _buildSprayChartFan() {
    return GestureDetector(
      onTapDown: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPos = box.globalToLocal(details.globalPosition);
        // Normalize to -100..100 range
        final x = ((localPos.dx / box.size.width) * 200) - 100;
        final y = 100 - ((localPos.dy / box.size.height) * 200);
        _addSprayChartPoint(x, y);
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.sidebarBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CustomPaint(
            size: const Size(double.infinity, 180),
            painter: SprayChartPainter(points: _sprayChartPoints),
          ),
        ),
      ),
    );
  }

  void _addSprayChartPoint(double x, double y) {
    showDialog(
      context: context,
      builder: (ctx) {
        String selectedHitType = 'single';
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('Add Hit', style: TextStyle(color: AppColors.white)),
          content: StatefulBuilder(
            builder: (ctx, setDialogState) {
              return DropdownButton<String>(
                value: selectedHitType,
                dropdownColor: AppColors.card,
                style: const TextStyle(color: AppColors.white),
                isExpanded: true,
                items: ['single', 'double', 'triple', 'homerun', 'out']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedHitType = v!),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _sprayChartPoints.add(SprayChartPoint(
                    x: x, y: y, hitType: selectedHitType,
                  ));
                });
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Zone Heatmap — interactive: editable 3×3 grid
  Widget _buildZoneHeatmap() {
    return Column(
      children: [
        // vs LHP
        const Text('vs LHP', style: TextStyle(color: AppColors.gray, fontSize: 12)),
        const SizedBox(height: 4),
        _buildZoneGrid(_zoneVsLHP),
        const SizedBox(height: 12),
        // vs RHP
        const Text('vs RHP', style: TextStyle(color: AppColors.gray, fontSize: 12)),
        const SizedBox(height: 4),
        _buildZoneGrid(_zoneVsRHP),
      ],
    );
  }

  Widget _buildZoneGrid(List<List<double>> zones) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: List.generate(3, (row) {
          return Row(
            children: List.generate(3, (col) {
              final value = zones[row][col];
              final color = _getHeatColor(value);
              return Expanded(
                child: GestureDetector(
                  onTap: () => _editZoneValue(zones, row, col),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        value.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Color _getHeatColor(double value) {
    if (value < 0.33) {
      return Color.lerp(
        const Color(0xFF1E40AF), const Color(0xFF06B6D4), value / 0.33,
      )!;
    } else if (value < 0.66) {
      return Color.lerp(
        const Color(0xFF06B6D4), const Color(0xFF22C55E), (value - 0.33) / 0.33,
      )!;
    } else {
      return Color.lerp(
        const Color(0xFFEAB308), const Color(0xFFEF4444), (value - 0.66) / 0.34,
      )!;
    }
  }

  void _editZoneValue(List<List<double>> zones, int row, int col) {
    final controller = TextEditingController(
      text: zones[row][col].toStringAsFixed(2),
    );
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text(
            'Set Zone Value (0.0 – 1.0)',
            style: TextStyle(color: AppColors.white, fontSize: 14),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.white),
            decoration: const InputDecoration(hintText: '0.00 – 1.00'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = double.tryParse(controller.text) ?? 0.0;
                setState(() {
                  zones[row][col] = val.clamp(0.0, 1.0);
                });
                Navigator.pop(ctx);
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
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
        Text(label,
            style: const TextStyle(color: AppColors.gray, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.sidebarBg,
            borderRadius:
                BorderRadius.circular(AppConstants.radiusSmall),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: fileName == null
              ? InkWell(
                  onTap: onPick,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusSmall),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined,
                            size: 28, color: AppColors.gray),
                        const SizedBox(height: 4),
                        const Text('Upload',
                            style: TextStyle(
                                color: AppColors.gray, fontSize: 12)),
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
                          const Icon(Icons.videocam_outlined,
                              size: 28, color: AppColors.success),
                          const SizedBox(height: 4),
                          Text(
                            fileName,
                            style: const TextStyle(
                                color: AppColors.white, fontSize: 10),
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

  Future<void> _pickVideoFile(int videoNumber) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;

      if (file.size > 100 * 1024 * 1024) {
        Get.snackbar(
          'Error',
          'Video must be under 100MB',
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
        );
        return;
      }

      setState(() {
        if (videoNumber == 1) {
          _videoFileName1 = file.name;
          _videoBytes1 = file.bytes;
        } else {
          _videoFileName2 = file.name;
          _videoBytes2 = file.bytes;
        }
      });
    }
  }

  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedUserIds.isEmpty) {
      Get.snackbar(
        'Error',
        'Please assign this report to at least one user',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
      return;
    }

    if (_playerImageBytes == null) {
      Get.snackbar(
        'Error',
        'Player photo is required. Please upload a player image.',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. Upload player image (mandatory)
      final playerImageUrl = await _reportService.uploadImage(
          _playerImageBytes!, _playerImageFileName!);

      // 2. Upload video 1 if present
      String? videoUrl;
      if (_videoBytes1 != null && _videoFileName1 != null) {
        videoUrl = await _reportService.uploadVideo(
            _videoBytes1!, _videoFileName1!);
      }

      // 3. Upload video 2 if present
      String? videoUrl2;
      if (_videoBytes2 != null && _videoFileName2 != null) {
        videoUrl2 = await _reportService.uploadVideo(
            _videoBytes2!, _videoFileName2!);
      }

      // 4. Build hitter stats
      final hitterStats = HitterStats(
        airPullPct:
            double.tryParse(_airPullController.text) ?? 0.0,
        chasePct:
            double.tryParse(_chaseController.text) ?? 0.0,
        ninetiethRV:
            double.tryParse(_ninetiethRVController.text) ?? 0.0,
        bbPct: double.tryParse(_bbController.text) ?? 0.0,
        missPct: double.tryParse(_missController.text) ?? 0.0,
        kPct: double.tryParse(_kController.text) ?? 0.0,
        exitVelocity:
            double.tryParse(_exitVeloController.text) ?? 0.0,
        battingAverage:
            double.tryParse(_battingAvgController.text) ?? 0.0,
      );

      // 5. Create a report for each assigned user
      String? firstReportId;
      for (final userId in _selectedUserIds) {
        final report = ReportModel.hitter(
          id: '',
          playerId: _fromRequest?.playerId ?? '',
          playerName: _playerNameController.text.trim(),
          position: _selectedPosition,
          throwsHand: _selectedThrows,
          createdAt: DateTime.now().toIso8601String(),
          videoUrl: videoUrl,
          videoUrl2: videoUrl2,
          playerImageUrl: playerImageUrl,
          scoutSummary: _scoutSummaryController.text.trim(),
          requestId: _fromRequest?.id,
          userId: userId,
          hitterStats: hitterStats,
          sprayChartPoints: List<SprayChartPoint>.from(_sprayChartPoints),
          zoneVsLHP: ZoneHeatmap(zones: _zoneVsLHP.map((r) => List<double>.from(r)).toList()),
          zoneVsRHP: ZoneHeatmap(zones: _zoneVsRHP.map((r) => List<double>.from(r)).toList()),
        );

        final reportId = await _reportService.createReport(report);
        firstReportId ??= reportId;
      }

      // 6. If from request, link first report to request and mark completed
      if (_fromRequest != null && firstReportId != null) {
        await _reportService.linkReportToRequest(
          _fromRequest!.id,
          firstReportId,
        );
      }

      Get.snackbar(
        'Success',
        'Hitter report saved for ${_selectedUserIds.length} user(s)',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
      Get.offAllNamed('/reports');
    } catch (e) {
      debugPrint('Error saving hitter report: $e');
      Get.snackbar(
        'Error',
        'Failed to save report. Please try again.',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// Custom painter for the spray chart fan shape with data points
class SprayChartPainter extends CustomPainter {
  final List<SprayChartPoint> points;

  SprayChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height + 20);
    final radius = size.height + 10;

    // Draw field background (green gradient)
    final fieldPaint = Paint()
      ..color = const Color(0xFF1B4332)
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi,
      math.pi,
      true,
      fieldPaint,
    );

    // Draw inner rings
    for (int ring = 1; ring <= 4; ring++) {
      final ringRadius = radius * (1 - ring * 0.2);
      final ringPaint = Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: ringRadius),
        -math.pi,
        math.pi,
        false,
        ringPaint,
      );
    }

    // Draw radial lines
    for (int i = 1; i < 8; i++) {
      final angle = -math.pi + (i * math.pi / 8);
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..strokeWidth = 1;

      final endPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      canvas.drawLine(center, endPoint, linePaint);
    }

    // Draw data points
    final hitColors = {
      'single': const Color(0xFF22C55E),
      'double': const Color(0xFFEAB308),
      'triple': const Color(0xFFF97316),
      'homerun': const Color(0xFFEF4444),
      'out': const Color(0xFF6B7280),
    };

    for (final point in points) {
      final px = center.dx + (point.x / 100) * radius;
      final py = center.dy - (point.y / 100) * radius;

      final dotPaint = Paint()
        ..color = hitColors[point.hitType] ?? Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(px, py), 5, dotPaint);

      // White border
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(Offset(px, py), 5, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SprayChartPainter oldDelegate) =>
      oldDelegate.points.length != points.length;
}

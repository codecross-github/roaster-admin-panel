import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:file_picker/file_picker.dart';
import '../core/constants.dart';
import '../widgets/admin_layout.dart';
import '../widgets/player_photo_upload.dart';
import '../models/report_model.dart';
import '../models/report_request_model.dart';
import '../services/report_service.dart';

class PitcherReportFormScreen extends StatefulWidget {
  const PitcherReportFormScreen({super.key});

  @override
  State<PitcherReportFormScreen> createState() =>
      _PitcherReportFormScreenState();
}

class _PitcherReportFormScreenState extends State<PitcherReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reportService = ReportService();
  bool _isSaving = false;

  // Request data (if navigated from a report request)
  ReportRequestModel? _fromRequest;

  // User info
  String? _selectedUserId;

  // Player Info
  final _playerNameController = TextEditingController();
  String _selectedPosition = 'RHP';
  String _selectedThrows = 'R';

  // Pitch Data
  final List<PitchData> _pitchData = [
    PitchData(
        pitchType: 'Fastball',
        velocity: 95.0,
        ivb: 15.2,
        hb: -8.3,
        spinRate: 2350),
    PitchData(
        pitchType: 'Slider',
        velocity: 87.0,
        ivb: 2.1,
        hb: 3.5,
        spinRate: 2650),
    PitchData(
        pitchType: 'Curveball',
        velocity: 80.0,
        ivb: -8.5,
        hb: 6.2,
        spinRate: 2800),
    PitchData(
        pitchType: 'Changeup',
        velocity: 85.0,
        ivb: 8.3,
        hb: -12.1,
        spinRate: 1850),
  ];

  // Scatter points for pitch movement chart
  final List<ScatterPoint> _scatterPoints = [];

  // Summary
  final _scoutSummaryController = TextEditingController();

  // Player Image
  Uint8List? _playerImageBytes;
  String? _playerImageFileName;

  // Video
  String? _videoFileName;
  Uint8List? _videoBytes;

  @override
  void initState() {
    super.initState();
    // Check if navigated from a report request
    final args = Get.arguments;
    if (args is ReportRequestModel) {
      _fromRequest = args;
      _playerNameController.text = args.playerName;
      _selectedPosition = _normalizePitcherPosition(args.playerPosition);
      _selectedUserId = args.userId;
      // Infer throws from position
      if (_selectedPosition == 'LHP') {
        _selectedThrows = 'L';
      }
    }
  }

  static const _validPitcherPositions = ['RHP', 'LHP', 'RP', 'CP'];

  /// Normalize a position string to one the pitcher dropdown accepts.
  String _normalizePitcherPosition(String pos) {
    const mappings = {
      'SP': 'RHP', 'STARTER': 'RHP',
      'RHP': 'RHP', 'LHP': 'LHP',
      'RP': 'RP', 'RELIEVER': 'RP',
      'CP': 'CP', 'CLOSER': 'CP',
      'P': 'RHP', 'PITCHER': 'RHP',
    };
    final normalized = mappings[pos.toUpperCase()];
    if (normalized != null) return normalized;
    if (_validPitcherPositions.contains(pos)) return pos;
    return 'RHP';
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _scoutSummaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentIndex: 3,
      title: _fromRequest != null
          ? 'Report for ${_fromRequest!.playerName}'
          : 'New Pitcher Report',
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
                    // User Info Card (from request or manual)
                    if (_fromRequest != null)
                      _buildCard(
                        title: 'Assigned to User',
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.success.withOpacity(0.3)),
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
                                    'Assigned to: ${_fromRequest!.userName}',
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
                      )
                    else
                      _buildCard(
                        title: 'Assign to User',
                        subtitle:
                            'Enter the user ID for this report',
                        child: _buildUserIdInput(),
                      ),

                    const SizedBox(height: 20),

                    // Player Info Card
                    _buildCard(
                      title: 'Player Information',
                      child: Column(
                        children: [
                          Row(
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
                                  items: ['RHP', 'LHP', 'RP', 'CP'],
                                  onChanged: (v) =>
                                      setState(() => _selectedPosition = v!),
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Pitch Data Table
                    _buildCard(
                      title: 'Pitch Data',
                      action: TextButton.icon(
                        onPressed: _addPitch,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Pitch'),
                      ),
                      child: _buildPitchDataTable(),
                    ),

                    const SizedBox(height: 20),

                    // Scatter Chart
                    _buildCard(
                      title: 'Pitch Movement Profile',
                      subtitle: 'Click on the chart to add scatter points',
                      child: SizedBox(
                        height: 350,
                        child: _buildScatterChart(),
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

                    // Video Upload
                    _buildCard(
                      title: 'Video Upload',
                      child: _buildVideoUpload(),
                    ),

                    const SizedBox(height: 20),

                    // Scout Summary
                    _buildCard(
                      title: 'Scout Summary',
                      child: TextFormField(
                        controller: _scoutSummaryController,
                        maxLines: 8,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(
                          hintText: 'Enter detailed scout analysis...',
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Quick Stats
                    _buildCard(
                      title: 'Quick Stats',
                      child: Column(
                        children: [
                          _buildStatRow(
                              'Peak Velocity', '${_getMaxVelocity()} mph'),
                          const Divider(color: AppColors.inputBorder),
                          _buildStatRow(
                              'Avg Spin Rate', '${_getAvgSpinRate()} rpm'),
                          const Divider(color: AppColors.inputBorder),
                          _buildStatRow('Pitch Count', '${_pitchData.length}'),
                        ],
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

  Widget _buildUserIdInput() {
    final controller = TextEditingController(text: _selectedUserId ?? '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.white),
          decoration: const InputDecoration(
            hintText: 'Enter User ID...',
            prefixIcon: Icon(Icons.person_search, color: AppColors.gray),
          ),
          onChanged: (value) {
            _selectedUserId = value.trim().isEmpty ? null : value.trim();
          },
        ),
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
                const Icon(Icons.check_circle,
                    color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Text(
                  'User ID: $_selectedUserId',
                  style: const TextStyle(
                      color: AppColors.success, fontWeight: FontWeight.w500),
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
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.gray, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
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
          items:
              items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          dropdownColor: AppColors.card,
          style: const TextStyle(color: AppColors.white),
          decoration: const InputDecoration(),
        ),
      ],
    );
  }

  Widget _buildPitchDataTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
        5: FlexColumnWidth(0.5),
      },
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(
            color: AppColors.sidebarBg,
            borderRadius: BorderRadius.circular(4),
          ),
          children: [
            _buildTableHeader('Pitch Type'),
            _buildTableHeader('Velo (mph)'),
            _buildTableHeader('iVB'),
            _buildTableHeader('HB'),
            _buildTableHeader('Spin'),
            _buildTableHeader(''),
          ],
        ),
        // Data rows
        ..._pitchData.asMap().entries.map((entry) {
          final index = entry.key;
          final pitch = entry.value;
          return TableRow(
            children: [
              _buildTableCell(
                DropdownButton<String>(
                  value: pitch.pitchType,
                  items: AppConstants.pitchTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => _updatePitch(index, pitchType: v),
                  dropdownColor: AppColors.card,
                  style:
                      const TextStyle(color: AppColors.white, fontSize: 14),
                  underline: const SizedBox(),
                  isExpanded: true,
                ),
              ),
              _buildTableCellInput(pitch.velocity.toString(),
                  (v) => _updatePitch(index, velocity: double.tryParse(v))),
              _buildTableCellInput(pitch.ivb.toString(),
                  (v) => _updatePitch(index, ivb: double.tryParse(v))),
              _buildTableCellInput(pitch.hb.toString(),
                  (v) => _updatePitch(index, hb: double.tryParse(v))),
              _buildTableCellInput(pitch.spinRate.toString(),
                  (v) => _updatePitch(index, spinRate: int.tryParse(v))),
              _buildTableCell(
                IconButton(
                  onPressed: () => _removePitch(index),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: AppColors.error,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.gray,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTableCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: child,
    );
  }

  Widget _buildTableCellInput(String value, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: TextFormField(
        initialValue: value,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.white, fontSize: 14),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          isDense: true,
          filled: true,
          fillColor: AppColors.sidebarBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildScatterChart() {
    return GestureDetector(
      onTapDown: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        final x = (localPosition.dx / box.size.width * 40) - 20;
        final y = (1 - localPosition.dy / box.size.height) * 40 - 20;
        _addScatterPoint(x, y);
      },
      child: ScatterChart(
        ScatterChartData(
          minX: -20,
          maxX: 20,
          minY: -20,
          maxY: 20,
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: true,
            horizontalInterval: 5,
            verticalInterval: 5,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.inputBorder.withOpacity(0.5),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: AppColors.inputBorder.withOpacity(0.5),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: AppColors.inputBorder),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              axisNameWidget: const Text(
                'Induced Vertical Break (in)',
                style: TextStyle(color: AppColors.gray, fontSize: 11),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style:
                      const TextStyle(color: AppColors.gray, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: const Text(
                'Horizontal Break (in)',
                style: TextStyle(color: AppColors.gray, fontSize: 11),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style:
                      const TextStyle(color: AppColors.gray, fontSize: 10),
                ),
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          scatterSpots: [
            ..._pitchData.map((pitch) {
              return ScatterSpot(
                pitch.hb,
                pitch.ivb,
                dotPainter: FlDotCirclePainter(
                  radius: 8,
                  color: _getPitchColor(pitch.pitchType),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              );
            }),
            ..._scatterPoints.map((point) {
              return ScatterSpot(
                point.x,
                point.y,
                dotPainter: FlDotCirclePainter(
                  radius: 6,
                  color:
                      _getPitchColor(point.pitchType).withOpacity(0.7),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getPitchColor(String pitchType) {
    switch (pitchType.toLowerCase()) {
      case 'fastball':
        return AppColors.error;
      case 'slider':
        return AppColors.warning;
      case 'curveball':
        return AppColors.info;
      case 'changeup':
        return AppColors.accent;
      case 'cutter':
        return AppColors.primary;
      case 'sweeper':
        return AppColors.premium;
      default:
        return AppColors.gray;
    }
  }

  Widget _buildVideoUpload() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: _videoFileName == null
          ? InkWell(
              onTap: _pickVideo,
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusSmall),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined,
                        size: 40, color: AppColors.gray),
                    const SizedBox(height: 8),
                    const Text('Click to upload video',
                        style: TextStyle(color: AppColors.gray)),
                    const SizedBox(height: 4),
                    const Text('MP4, MOV up to 100MB',
                        style:
                            TextStyle(color: AppColors.gray, fontSize: 12)),
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
                          size: 40, color: AppColors.success),
                      const SizedBox(height: 8),
                      Text(
                        _videoFileName!,
                        style: const TextStyle(color: AppColors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => setState(() {
                      _videoFileName = null;
                      _videoBytes = null;
                    }),
                    icon: const Icon(Icons.close, size: 18),
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.gray)),
          Text(
            value,
            style: const TextStyle(
                color: AppColors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _addPitch() {
    setState(() {
      _pitchData.add(PitchData(
        pitchType: 'Fastball',
        velocity: 90.0,
        ivb: 0.0,
        hb: 0.0,
        spinRate: 2000,
      ));
    });
  }

  void _removePitch(int index) {
    if (_pitchData.length > 1) {
      setState(() {
        _pitchData.removeAt(index);
      });
    }
  }

  void _updatePitch(
    int index, {
    String? pitchType,
    double? velocity,
    double? ivb,
    double? hb,
    int? spinRate,
  }) {
    setState(() {
      final old = _pitchData[index];
      _pitchData[index] = PitchData(
        pitchType: pitchType ?? old.pitchType,
        velocity: velocity ?? old.velocity,
        ivb: ivb ?? old.ivb,
        hb: hb ?? old.hb,
        spinRate: spinRate ?? old.spinRate,
      );
    });
  }

  void _addScatterPoint(double x, double y) {
    setState(() {
      _scatterPoints.add(ScatterPoint(
        x: x,
        y: y,
        pitchType:
            _pitchData.isNotEmpty ? _pitchData.first.pitchType : 'Fastball',
      ));
    });
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

  Future<void> _pickVideo() async {
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
        _videoFileName = file.name;
        _videoBytes = file.bytes;
      });
    }
  }

  double _getMaxVelocity() {
    if (_pitchData.isEmpty) return 0;
    return _pitchData.map((p) => p.velocity).reduce((a, b) => a > b ? a : b);
  }

  int _getAvgSpinRate() {
    if (_pitchData.isEmpty) return 0;
    return (_pitchData.map((p) => p.spinRate).reduce((a, b) => a + b) /
            _pitchData.length)
        .round();
  }

  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedUserId == null || _selectedUserId!.isEmpty) {
      Get.snackbar(
        'Error',
        'Please assign this report to a user',
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

      // 2. Upload video if present
      String? videoUrl;
      if (_videoBytes != null && _videoFileName != null) {
        videoUrl = await _reportService.uploadVideo(
            _videoBytes!, _videoFileName!);
      }

      // 3. Build the report model
      final report = ReportModel.pitcher(
        id: '',
        playerId: _fromRequest?.playerId ?? '',
        playerName: _playerNameController.text.trim(),
        position: _selectedPosition,
        throwsHand: _selectedThrows,
        createdAt: DateTime.now().toIso8601String(),
        videoUrl: videoUrl,
        playerImageUrl: playerImageUrl,
        scoutSummary: _scoutSummaryController.text.trim(),
        requestId: _fromRequest?.id,
        userId: _selectedUserId,
        peakVelocity: _getMaxVelocity(),
        avgSpinRate: _getAvgSpinRate(),
        pitchData: List<PitchData>.from(_pitchData),
        scatterPoints: List<ScatterPoint>.from(_scatterPoints),
      );

      // 3. Save to Firestore
      final reportId = await _reportService.createReport(report);

      // 4. If from request, link report to request and mark completed
      if (_fromRequest != null) {
        await _reportService.linkReportToRequest(
          _fromRequest!.id,
          reportId,
        );
      }

      Get.snackbar(
        'Success',
        'Pitcher report saved successfully',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
      Get.offAllNamed('/reports');
    } catch (e) {
      debugPrint('Error saving pitcher report: $e');
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

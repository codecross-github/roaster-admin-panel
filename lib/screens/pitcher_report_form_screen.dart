import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/constants.dart';
import '../widgets/admin_layout.dart';
import '../models/report_model.dart';

class PitcherReportFormScreen extends StatefulWidget {
  const PitcherReportFormScreen({super.key});

  @override
  State<PitcherReportFormScreen> createState() => _PitcherReportFormScreenState();
}

class _PitcherReportFormScreenState extends State<PitcherReportFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Player Info
  final _playerNameController = TextEditingController();
  String _selectedPosition = 'RHP';
  String _selectedThrows = 'R';

  // Pitch Data
  final List<PitchData> _pitchData = [
    PitchData(pitchType: 'Fastball', velocity: 95.0, ivb: 15.2, hb: -8.3, spinRate: 2350),
    PitchData(pitchType: 'Slider', velocity: 87.0, ivb: 2.1, hb: 3.5, spinRate: 2650),
    PitchData(pitchType: 'Curveball', velocity: 80.0, ivb: -8.5, hb: 6.2, spinRate: 2800),
    PitchData(pitchType: 'Changeup', velocity: 85.0, ivb: 8.3, hb: -12.1, spinRate: 1850),
  ];

  // Scatter points for pitch movement chart
  final List<ScatterPoint> _scatterPoints = [];

  // Summary
  final _scoutSummaryController = TextEditingController();

  // Video
  String? _videoFileName;

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
      title: 'New Pitcher Report',
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
                                  onChanged: (v) => setState(() => _selectedPosition = v!),
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
                          _buildStatRow('Peak Velocity', '${_getMaxVelocity()} mph'),
                          const Divider(color: AppColors.inputBorder),
                          _buildStatRow('Avg Spin Rate', '${_getAvgSpinRate()} rpm'),
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
                        color: AppColors.gray,
                        fontSize: 12,
                      ),
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
        Text(
          label,
          style: const TextStyle(color: AppColors.gray, fontSize: 13),
        ),
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
        Text(
          label,
          style: const TextStyle(color: AppColors.gray, fontSize: 13),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                  underline: const SizedBox(),
                  isExpanded: true,
                ),
              ),
              _buildTableCellInput(pitch.velocity.toString(), (v) =>
                  _updatePitch(index, velocity: double.tryParse(v))),
              _buildTableCellInput(pitch.ivb.toString(), (v) =>
                  _updatePitch(index, ivb: double.tryParse(v))),
              _buildTableCellInput(pitch.hb.toString(), (v) =>
                  _updatePitch(index, hb: double.tryParse(v))),
              _buildTableCellInput(pitch.spinRate.toString(), (v) =>
                  _updatePitch(index, spinRate: int.tryParse(v))),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
        // Convert to chart coordinates
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
                  style: const TextStyle(color: AppColors.gray, fontSize: 10),
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
                  style: const TextStyle(color: AppColors.gray, fontSize: 10),
                ),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                  color: _getPitchColor(point.pitchType).withOpacity(0.7),
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
        border: Border.all(
          color: AppColors.inputBorder,
          style: BorderStyle.solid,
        ),
      ),
      child: _videoFileName == null
          ? InkWell(
              onTap: _pickVideo,
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 40,
                      color: AppColors.gray,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Click to upload video',
                      style: TextStyle(color: AppColors.gray),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'MP4, MOV up to 100MB',
                      style: TextStyle(color: AppColors.gray, fontSize: 12),
                    ),
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
                      const Icon(
                        Icons.videocam_outlined,
                        size: 40,
                        color: AppColors.success,
                      ),
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
                    onPressed: () => setState(() => _videoFileName = null),
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
          Text(
            label,
            style: const TextStyle(color: AppColors.gray),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
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

  void _updatePitch(int index, {
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
        pitchType: _pitchData.isNotEmpty ? _pitchData.first.pitchType : 'Fastball',
      ));
    });
  }

  void _pickVideo() async {
    // Simulating file picker
    setState(() {
      _videoFileName = 'pitcher_highlight.mp4';
    });
  }

  double _getMaxVelocity() {
    if (_pitchData.isEmpty) return 0;
    return _pitchData.map((p) => p.velocity).reduce((a, b) => a > b ? a : b);
  }

  int _getAvgSpinRate() {
    if (_pitchData.isEmpty) return 0;
    return (_pitchData.map((p) => p.spinRate).reduce((a, b) => a + b) / _pitchData.length).round();
  }

  void _saveReport() {
    if (_formKey.currentState!.validate()) {
      // Save report logic
      Get.snackbar(
        'Success',
        'Pitcher report saved successfully',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
      Get.offAllNamed('/reports');
    }
  }
}

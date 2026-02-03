import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants.dart';
import '../widgets/admin_layout.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  String _searchQuery = '';
  String _selectedType = 'All';
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _players = [
    {'id': '1', 'name': 'Mike Johnson', 'position': 'RHP', 'team': 'Durham Bulls', 'level': 'AAA', 'age': 24, 'type': 'Pitcher', 'throws': 'R', 'bats': 'R'},
    {'id': '2', 'name': 'Chris Williams', 'position': 'CF', 'team': 'Nashville Sounds', 'level': 'AAA', 'age': 26, 'type': 'Hitter', 'throws': 'R', 'bats': 'L'},
    {'id': '3', 'name': 'Alex Brown', 'position': 'LHP', 'team': 'Sugar Land', 'level': 'AAA', 'age': 23, 'type': 'Pitcher', 'throws': 'L', 'bats': 'L'},
    {'id': '4', 'name': 'David Lee', 'position': 'SS', 'team': 'Tacoma Rainiers', 'level': 'AAA', 'age': 25, 'type': 'Hitter', 'throws': 'R', 'bats': 'S'},
    {'id': '5', 'name': 'Ryan Garcia', 'position': 'RHP', 'team': 'Rochester', 'level': 'AAA', 'age': 27, 'type': 'Pitcher', 'throws': 'R', 'bats': 'R'},
    {'id': '6', 'name': 'James Wilson', 'position': '1B', 'team': 'Las Vegas', 'level': 'AAA', 'age': 28, 'type': 'Hitter', 'throws': 'L', 'bats': 'L'},
  ];

  List<Map<String, dynamic>> get _filteredPlayers {
    var players = _players;

    if (_selectedType != 'All') {
      players = players.where((p) => p['type'] == _selectedType).toList();
    }

    if (_searchQuery.isNotEmpty) {
      players = players.where((p) =>
          p['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p['team'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return players;
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentIndex: 5,
      title: 'Players Management',
      actions: [
        SizedBox(
          width: 250,
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Search players...',
              prefixIcon: const Icon(Icons.search, color: AppColors.gray, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _showPlayerDialog(),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Player'),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            // Filters
            Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Pitcher'),
                const SizedBox(width: 8),
                _buildFilterChip('Hitter'),
              ],
            ),

            const SizedBox(height: 24),

            // Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.sidebarBg,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppConstants.radiusMedium),
                          topRight: Radius.circular(AppConstants.radiusMedium),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildHeaderCell('Player', flex: 2),
                          _buildHeaderCell('Position'),
                          _buildHeaderCell('Team', flex: 2),
                          _buildHeaderCell('Level'),
                          _buildHeaderCell('Age'),
                          _buildHeaderCell('B/T'),
                          _buildHeaderCell('Actions'),
                        ],
                      ),
                    ),

                    // Body
                    Expanded(
                      child: ListView.separated(
                        itemCount: _filteredPlayers.length,
                        separatorBuilder: (_, __) => const Divider(color: AppColors.inputBorder, height: 1),
                        itemBuilder: (context, index) {
                          final player = _filteredPlayers[index];
                          return _buildPlayerRow(player);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedType == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedType = label),
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.gray,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      backgroundColor: AppColors.card,
      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.inputBorder),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(color: AppColors.gray, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  Widget _buildPlayerRow(Map<String, dynamic> player) {
    final isPitcher = player['type'] == 'Pitcher';
    final typeColor = isPitcher ? AppColors.pitcherBlue : AppColors.hitterGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Player Name
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      player['name'].toString().substring(0, 1),
                      style: TextStyle(color: typeColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(player['name'], style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w500)),
                    Text(player['type'], style: TextStyle(color: typeColor, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          // Position
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                player['position'],
                style: TextStyle(color: typeColor, fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Team
          Expanded(flex: 2, child: Text(player['team'], style: const TextStyle(color: AppColors.white))),

          // Level
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                player['level'],
                style: const TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Age
          Expanded(child: Text('${player['age']}', style: const TextStyle(color: AppColors.gray))),

          // B/T
          Expanded(
            child: Text(
              '${player['bats']}/${player['throws']}',
              style: const TextStyle(color: AppColors.gray),
            ),
          ),

          // Actions
          Expanded(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _showPlayerDialog(player: player),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: AppColors.primary,
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () => _deletePlayer(player),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: AppColors.error,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPlayerDialog({Map<String, dynamic>? player}) {
    final isEdit = player != null;
    final nameController = TextEditingController(text: player?['name'] ?? '');
    final teamController = TextEditingController(text: player?['team'] ?? '');
    final ageController = TextEditingController(text: player?['age']?.toString() ?? '');
    String position = player?['position'] ?? 'RHP';
    String level = player?['level'] ?? 'AAA';
    String type = player?['type'] ?? 'Pitcher';
    String bats = player?['bats'] ?? 'R';
    String throws_ = player?['throws'] ?? 'R';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(isEdit ? 'Edit Player' : 'Add Player', style: const TextStyle(color: AppColors.white)),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(labelText: 'Player Name'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: type,
                        items: ['Pitcher', 'Hitter'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setDialogState(() => type = v!),
                        decoration: const InputDecoration(labelText: 'Type'),
                        dropdownColor: AppColors.card,
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: position,
                        items: AppConstants.positions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setDialogState(() => position = v!),
                        decoration: const InputDecoration(labelText: 'Position'),
                        dropdownColor: AppColors.card,
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: teamController,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(labelText: 'Team'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: level,
                        items: AppConstants.levels.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setDialogState(() => level = v!),
                        decoration: const InputDecoration(labelText: 'Level'),
                        dropdownColor: AppColors.card,
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(labelText: 'Age'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: bats,
                        items: AppConstants.batsOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setDialogState(() => bats = v!),
                        decoration: const InputDecoration(labelText: 'Bats'),
                        dropdownColor: AppColors.card,
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: throws_,
                        items: AppConstants.throwsOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setDialogState(() => throws_ = v!),
                        decoration: const InputDecoration(labelText: 'Throws'),
                        dropdownColor: AppColors.card,
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  if (isEdit) {
                    final index = _players.indexWhere((p) => p['id'] == player['id']);
                    _players[index] = {
                      'id': player['id'],
                      'name': nameController.text,
                      'position': position,
                      'team': teamController.text,
                      'level': level,
                      'age': int.tryParse(ageController.text) ?? 0,
                      'type': type,
                      'throws': throws_,
                      'bats': bats,
                    };
                  } else {
                    _players.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'name': nameController.text,
                      'position': position,
                      'team': teamController.text,
                      'level': level,
                      'age': int.tryParse(ageController.text) ?? 0,
                      'type': type,
                      'throws': throws_,
                      'bats': bats,
                    });
                  }
                });
                Get.snackbar(
                  'Success',
                  isEdit ? 'Player updated' : 'Player added',
                  backgroundColor: AppColors.success,
                  colorText: AppColors.white,
                );
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _deletePlayer(Map<String, dynamic> player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Delete Player', style: TextStyle(color: AppColors.white)),
        content: Text('Delete ${player['name']}?', style: const TextStyle(color: AppColors.gray)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _players.removeWhere((p) => p['id'] == player['id']));
              Get.snackbar('Deleted', 'Player deleted', backgroundColor: AppColors.error, colorText: AppColors.white);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants.dart';
import '../models/player_model.dart';
import '../services/player_service.dart';
import '../widgets/admin_layout.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  final _playerService = PlayerService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _searchDebounce;

  // ── State ──
  List<PlayerModel> _players = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _searchQuery = '';
  String _selectedType = 'All';
  int _totalCount = 0;
  DocumentSnapshot? _lastDoc;

  static const int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════
  // DATA LOADING
  // ═══════════════════════════════════════════════════════

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _players = [];
      _lastDoc = null;
      _hasMore = true;
    });

    try {
      // Fetch total count (lightweight aggregation)
      final count = await _playerService.getTotalCount();

      // Fetch first page
      final page = await _playerService.fetchPlayers(pageSize: _pageSize);

      if (mounted) {
        setState(() {
          _totalCount = count;
          _players = page.players;
          _lastDoc = page.lastDoc;
          _hasMore = page.hasMore;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Get.snackbar('Error', 'Failed to load players: $e',
            backgroundColor: AppColors.error, colorText: AppColors.white);
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _lastDoc == null) return;

    setState(() => _isLoadingMore = true);

    try {
      final page = await _playerService.fetchPlayers(
        lastDoc: _lastDoc,
        pageSize: _pageSize,
      );

      if (mounted) {
        setState(() {
          _players.addAll(page.players);
          _lastDoc = page.lastDoc;
          _hasMore = page.hasMore;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _searchQuery = query);
    });
  }

  // ═══════════════════════════════════════════════════════
  // FILTERING (client-side on loaded data)
  // ═══════════════════════════════════════════════════════

  List<PlayerModel> get _filteredPlayers {
    var filtered = _players;

    if (_selectedType == 'Pitcher') {
      filtered = filtered.where((p) => p.isPitcher).toList();
    } else if (_selectedType == 'Hitter') {
      filtered = filtered.where((p) => !p.isPitcher).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) =>
              p.displayName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              p.team.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  // ═══════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPlayers;
    final loadedPitchers = _players.where((p) => p.isPitcher).length;
    final loadedHitters = _players.where((p) => !p.isPitcher).length;

    return AdminLayout(
      currentIndex: 5,
      title: 'Players Management',
      actions: [
        SizedBox(
          width: 250,
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Search players...',
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.gray, size: 20),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Column(
                children: [
                  // Stats Row
                  Row(
                    children: [
                      _buildStatCard(
                          'Total Players', _totalCount, AppColors.info),
                      const SizedBox(width: 16),
                      _buildStatCard(
                          'Pitchers', loadedPitchers, AppColors.pitcherBlue),
                      const SizedBox(width: 16),
                      _buildStatCard(
                          'Hitters', loadedHitters, AppColors.hitterGreen),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Filters + loaded info
                  Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pitcher'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Hitter'),
                      const Spacer(),
                      Text(
                        'Showing ${_players.length} of $_totalCount',
                        style: const TextStyle(
                            color: AppColors.gray, fontSize: 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Table
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sports_baseball_outlined,
                                    size: 64,
                                    color: AppColors.gray.withOpacity(0.5)),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'No players match "$_searchQuery"'
                                      : 'No players found',
                                  style: const TextStyle(
                                      color: AppColors.gray, fontSize: 16),
                                ),
                                if (_searchQuery.isNotEmpty && _hasMore)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: TextButton.icon(
                                      onPressed: _loadMore,
                                      icon: const Icon(Icons.download,
                                          size: 16),
                                      label:
                                          const Text('Load more to search'),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusMedium),
                              border:
                                  Border.all(color: AppColors.inputBorder),
                            ),
                            child: Column(
                              children: [
                                // Header
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                  decoration: const BoxDecoration(
                                    color: AppColors.sidebarBg,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(
                                          AppConstants.radiusMedium),
                                      topRight: Radius.circular(
                                          AppConstants.radiusMedium),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildHeaderCell('Player', flex: 2),
                                      _buildHeaderCell('Position'),
                                      _buildHeaderCell('Team', flex: 2),
                                      _buildHeaderCell('Level'),
                                      _buildHeaderCell('B/T'),
                                      _buildHeaderCell('Stats', flex: 2),
                                      _buildHeaderCell('Actions'),
                                    ],
                                  ),
                                ),

                                // Body
                                Expanded(
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    itemCount:
                                        filtered.length + (_hasMore ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == filtered.length) {
                                        // Load-more indicator at bottom
                                        return _buildLoadMoreIndicator();
                                      }
                                      if (index > 0) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Divider(
                                                color: AppColors.inputBorder,
                                                height: 1),
                                            _buildPlayerRow(
                                                filtered[index]),
                                          ],
                                        );
                                      }
                                      return _buildPlayerRow(
                                          filtered[index]);
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

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: _isLoadingMore
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                  SizedBox(width: 12),
                  Text('Loading more players...',
                      style: TextStyle(color: AppColors.gray, fontSize: 13)),
                ],
              )
            : TextButton.icon(
                onPressed: _loadMore,
                icon: const Icon(Icons.expand_more, size: 18),
                label: const Text('Load more'),
              ),
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                label == 'Pitchers'
                    ? Icons.sports_baseball
                    : label == 'Hitters'
                        ? Icons.sports_cricket
                        : Icons.people_outline,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(label, style: const TextStyle(color: AppColors.gray)),
              ],
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
      side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.inputBorder),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
            color: AppColors.gray,
            fontWeight: FontWeight.w600,
            fontSize: 13),
      ),
    );
  }

  Widget _buildPlayerRow(PlayerModel player) {
    final typeColor =
        player.isPitcher ? AppColors.pitcherBlue : AppColors.hitterGreen;
    final initial = player.displayName.isNotEmpty
        ? player.displayName[0].toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Player Name + Photo
          Expanded(
            flex: 2,
            child: Row(
              children: [
                player.profilePictureUrl.isNotEmpty
                    ? CircleAvatar(
                        radius: 18,
                        backgroundImage:
                            NetworkImage(player.profilePictureUrl),
                        backgroundColor: typeColor.withOpacity(0.15),
                      )
                    : Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: TextStyle(
                                color: typeColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(player.displayName,
                          style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                      if (player.transactionType.isNotEmpty)
                        Text(player.transactionType,
                            style: TextStyle(
                                color: _transactionColor(
                                    player.transactionType),
                                fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Position
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                player.position.isNotEmpty ? player.position : '—',
                style: TextStyle(
                    color: typeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Team
          Expanded(
              flex: 2,
              child: Text(player.team,
                  style: const TextStyle(color: AppColors.white),
                  overflow: TextOverflow.ellipsis)),

          // Level
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                player.highestLevel.isNotEmpty
                    ? player.highestLevel
                    : player.affiliateLevel.isNotEmpty
                        ? player.affiliateLevel
                        : '—',
                style: const TextStyle(
                    color: AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // B/T
          Expanded(
            child: Text(
              '${player.bats.isNotEmpty ? player.bats : '—'}/${player.throws_.isNotEmpty ? player.throws_ : '—'}',
              style: const TextStyle(color: AppColors.gray),
            ),
          ),

          // Stats
          Expanded(
            flex: 2,
            child: Text(
              player.statsDisplay,
              style: const TextStyle(color: AppColors.gray, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Actions
          Expanded(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _showPlayerDetails(player),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  color: AppColors.gray,
                  tooltip: 'View Details',
                ),
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

  Color _transactionColor(String type) {
    switch (type.toLowerCase()) {
      case 'released':
        return AppColors.error;
      case 'dfa':
        return AppColors.primary;
      case 'elected free agency':
        return AppColors.accent;
      default:
        return AppColors.gray;
    }
  }

  void _showPlayerDetails(PlayerModel player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Row(
          children: [
            player.profilePictureUrl.isNotEmpty
                ? CircleAvatar(
                    radius: 22,
                    backgroundImage:
                        NetworkImage(player.profilePictureUrl),
                  )
                : CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Text(
                      player.displayName.isNotEmpty
                          ? player.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(player.displayName,
                      style: const TextStyle(
                          color: AppColors.white, fontSize: 18)),
                  Text(
                    '${player.position} • ${player.team}',
                    style:
                        const TextStyle(color: AppColors.gray, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailSection('Bio', [
                  if (player.age.isNotEmpty)
                    _buildDetailRow('Age', player.age),
                  if (player.height.isNotEmpty)
                    _buildDetailRow('Height', player.height),
                  if (player.weight.isNotEmpty)
                    _buildDetailRow('Weight', player.weight),
                  _buildDetailRow(
                    'B/T',
                    '${player.bats.isNotEmpty ? player.bats : '—'}/${player.throws_.isNotEmpty ? player.throws_ : '—'}',
                  ),
                  if (player.birthdate.isNotEmpty)
                    _buildDetailRow('Birthdate', player.birthdate),
                  if (player.birthplace.isNotEmpty)
                    _buildDetailRow('Birthplace', player.birthplace),
                  if (player.status.isNotEmpty)
                    _buildDetailRow('Status', player.status),
                  _buildDetailRow(
                    'Level',
                    player.highestLevel.isNotEmpty
                        ? player.highestLevel
                        : player.affiliateLevel,
                  ),
                ]),
                if (player.transactionType.isNotEmpty ||
                    player.transaction.isNotEmpty)
                  _buildDetailSection('Transaction', [
                    if (player.transactionType.isNotEmpty)
                      _buildDetailRow('Type', player.transactionType),
                    if (player.transaction.isNotEmpty)
                      _buildDetailRow('Details', player.transaction),
                    if (player.date.isNotEmpty)
                      _buildDetailRow('Date', player.date),
                  ]),
                if (player.draftYear.isNotEmpty ||
                    player.college.isNotEmpty)
                  _buildDetailSection('Draft / Education', [
                    if (player.draftYear.isNotEmpty)
                      _buildDetailRow('Draft Year', player.draftYear),
                    if (player.draftTeam.isNotEmpty)
                      _buildDetailRow('Draft Team', player.draftTeam),
                    if (player.draftRound.isNotEmpty)
                      _buildDetailRow('Round', player.draftRound),
                    if (player.draftOverallPick.isNotEmpty)
                      _buildDetailRow(
                          'Overall Pick', player.draftOverallPick),
                    if (player.college.isNotEmpty)
                      _buildDetailRow('College', player.college),
                    if (player.mlbDebut.isNotEmpty)
                      _buildDetailRow('MLB Debut', player.mlbDebut),
                  ]),
                if (player.isPitcher)
                  _buildDetailSection('Pitching Stats (MiLB)', [
                    if (player.milbPEra.isNotEmpty)
                      _buildDetailRow('ERA', player.milbPEra),
                    if (player.milbPWhip.isNotEmpty)
                      _buildDetailRow('WHIP', player.milbPWhip),
                    if (player.milbPW.isNotEmpty ||
                        player.milbPL.isNotEmpty)
                      _buildDetailRow(
                          'W/L', '${player.milbPW}/${player.milbPL}'),
                    if (player.milbPSO.isNotEmpty)
                      _buildDetailRow('SO', player.milbPSO),
                    if (player.milbPIP.isNotEmpty)
                      _buildDetailRow('IP', player.milbPIP),
                    if (player.milbPG.isNotEmpty)
                      _buildDetailRow('G', player.milbPG),
                    if (player.milbPGS.isNotEmpty)
                      _buildDetailRow('GS', player.milbPGS),
                    if (player.milbPSV.isNotEmpty)
                      _buildDetailRow('SV', player.milbPSV),
                  ]),
                if (!player.isPitcher)
                  _buildDetailSection('Batting Stats (MiLB)', [
                    if (player.milbBAvg.isNotEmpty)
                      _buildDetailRow('AVG', player.milbBAvg),
                    if (player.milbBObp.isNotEmpty)
                      _buildDetailRow('OBP', player.milbBObp),
                    if (player.milbBOps.isNotEmpty)
                      _buildDetailRow('OPS', player.milbBOps),
                    if (player.milbBHR.isNotEmpty)
                      _buildDetailRow('HR', player.milbBHR),
                    if (player.milbBRBI.isNotEmpty)
                      _buildDetailRow('RBI', player.milbBRBI),
                    if (player.milbBH.isNotEmpty)
                      _buildDetailRow('H', player.milbBH),
                    if (player.milbBR.isNotEmpty)
                      _buildDetailRow('R', player.milbBR),
                    if (player.milbBSB.isNotEmpty)
                      _buildDetailRow('SB', player.milbBSB),
                    if (player.milbBAB.isNotEmpty)
                      _buildDetailRow('AB', player.milbBAB),
                  ]),
                if (player.isPitcher && player.mlbPEra.isNotEmpty)
                  _buildDetailSection('Pitching Stats (MLB)', [
                    _buildDetailRow('ERA', player.mlbPEra),
                    if (player.mlbPWhip.isNotEmpty)
                      _buildDetailRow('WHIP', player.mlbPWhip),
                    if (player.mlbPW.isNotEmpty ||
                        player.mlbPL.isNotEmpty)
                      _buildDetailRow(
                          'W/L', '${player.mlbPW}/${player.mlbPL}'),
                    if (player.mlbPSO.isNotEmpty)
                      _buildDetailRow('SO', player.mlbPSO),
                    if (player.mlbPIP.isNotEmpty)
                      _buildDetailRow('IP', player.mlbPIP),
                  ]),
                if (!player.isPitcher && player.mlbBAvg.isNotEmpty)
                  _buildDetailSection('Batting Stats (MLB)', [
                    _buildDetailRow('AVG', player.mlbBAvg),
                    if (player.mlbBObp.isNotEmpty)
                      _buildDetailRow('OBP', player.mlbBObp),
                    if (player.mlbBOps.isNotEmpty)
                      _buildDetailRow('OPS', player.mlbBOps),
                    if (player.mlbBHR.isNotEmpty)
                      _buildDetailRow('HR', player.mlbBHR),
                    if (player.mlbBRBI.isNotEmpty)
                      _buildDetailRow('RBI', player.mlbBRBI),
                  ]),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(title,
            style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        const Divider(color: AppColors.inputBorder),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.gray)),
          Flexible(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.white, fontWeight: FontWeight.w500),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  void _showPlayerDialog({PlayerModel? player}) {
    final isEdit = player != null;
    final nameController =
        TextEditingController(text: player?.fullName ?? '');
    final teamController =
        TextEditingController(text: player?.team ?? '');
    final ageController =
        TextEditingController(text: player?.age ?? '');
    final heightController =
        TextEditingController(text: player?.height ?? '');
    final weightController =
        TextEditingController(text: player?.weight ?? '');
    String position = player?.position ?? 'RHP';
    String level = player?.highestLevel ?? 'AAA';
    String bats = player?.bats.isNotEmpty == true ? player!.bats : 'R';
    String throws_ =
        player?.throws_.isNotEmpty == true ? player!.throws_ : 'R';
    String transactionType = player?.transactionType ?? '';
    final formKey = GlobalKey<FormState>();

    if (!AppConstants.positions.contains(position)) {
      position = AppConstants.positions.first;
    }
    if (!AppConstants.levels.contains(level)) {
      level = AppConstants.levels.first;
    }
    if (!AppConstants.batsOptions.contains(bats)) {
      bats = AppConstants.batsOptions.first;
    }
    if (!AppConstants.throwsOptions.contains(throws_)) {
      throws_ = AppConstants.throwsOptions.first;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(isEdit ? 'Edit Player' : 'Add Player',
              style: const TextStyle(color: AppColors.white)),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(
                          labelText: 'Full Name'),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: position,
                            items: AppConstants.positions
                                .map((e) => DropdownMenuItem(
                                    value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) =>
                                setDialogState(() => position = v!),
                            decoration: const InputDecoration(
                                labelText: 'Position'),
                            dropdownColor: AppColors.card,
                            style:
                                const TextStyle(color: AppColors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: level,
                            items: AppConstants.levels
                                .map((e) => DropdownMenuItem(
                                    value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) =>
                                setDialogState(() => level = v!),
                            decoration: const InputDecoration(
                                labelText: 'Level'),
                            dropdownColor: AppColors.card,
                            style:
                                const TextStyle(color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: teamController,
                      style: const TextStyle(color: AppColors.white),
                      decoration:
                          const InputDecoration(labelText: 'Team'),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Team is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: ageController,
                            style:
                                const TextStyle(color: AppColors.white),
                            decoration: const InputDecoration(
                                labelText: 'Age'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: heightController,
                            style:
                                const TextStyle(color: AppColors.white),
                            decoration: const InputDecoration(
                                labelText: 'Height (e.g. 6\'2")'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: weightController,
                            style:
                                const TextStyle(color: AppColors.white),
                            decoration: const InputDecoration(
                                labelText: 'Weight (lbs)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: bats,
                            items: AppConstants.batsOptions
                                .map((e) => DropdownMenuItem(
                                    value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) =>
                                setDialogState(() => bats = v!),
                            decoration: const InputDecoration(
                                labelText: 'Bats'),
                            dropdownColor: AppColors.card,
                            style:
                                const TextStyle(color: AppColors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: throws_,
                            items: AppConstants.throwsOptions
                                .map((e) => DropdownMenuItem(
                                    value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) =>
                                setDialogState(() => throws_ = v!),
                            decoration: const InputDecoration(
                                labelText: 'Throws'),
                            dropdownColor: AppColors.card,
                            style:
                                const TextStyle(color: AppColors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: transactionType,
                            style:
                                const TextStyle(color: AppColors.white),
                            decoration: const InputDecoration(
                                labelText: 'Transaction Type'),
                            onChanged: (v) => transactionType = v,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                Navigator.pop(context);

                try {
                  final data = <String, dynamic>{
                    'Full_Name': nameController.text.trim(),
                    'Position': position,
                    'Team': teamController.text.trim(),
                    'Highest_Level': level,
                    'Age': ageController.text.trim(),
                    'Height': heightController.text.trim(),
                    'Weight': weightController.text.trim(),
                    'Bats': bats,
                    'Throws': throws_,
                    'Transaction_Type': transactionType.trim(),
                  };

                  if (isEdit) {
                    await _playerService.updatePlayer(player.id, data);
                    // Update locally
                    final idx =
                        _players.indexWhere((p) => p.id == player.id);
                    if (idx != -1) {
                      _loadInitial(); // refresh the list
                    }
                  } else {
                    final newPlayer = PlayerModel(
                      id: '',
                      fullName: data['Full_Name'],
                      position: data['Position'],
                      team: data['Team'],
                      highestLevel: data['Highest_Level'],
                      age: data['Age'],
                      height: data['Height'],
                      weight: data['Weight'],
                      bats: data['Bats'],
                      throws_: data['Throws'],
                      transactionType: data['Transaction_Type'],
                    );
                    await _playerService.createPlayer(newPlayer);
                    _loadInitial(); // refresh
                  }

                  Get.snackbar(
                    'Success',
                    isEdit ? 'Player updated' : 'Player added',
                    backgroundColor: AppColors.success,
                    colorText: AppColors.white,
                  );
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    isEdit
                        ? 'Failed to update player'
                        : 'Failed to add player',
                    backgroundColor: AppColors.error,
                    colorText: AppColors.white,
                  );
                }
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _deletePlayer(PlayerModel player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Delete Player',
            style: TextStyle(color: AppColors.white)),
        content: Text('Delete ${player.displayName}?',
            style: const TextStyle(color: AppColors.gray)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _playerService.deletePlayer(player.id);
                setState(() {
                  _players.removeWhere((p) => p.id == player.id);
                  _totalCount = (_totalCount - 1).clamp(0, _totalCount);
                });
                Get.snackbar(
                    'Deleted', '${player.displayName} has been deleted',
                    backgroundColor: AppColors.error,
                    colorText: AppColors.white);
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete player',
                  backgroundColor: AppColors.error,
                  colorText: AppColors.white,
                );
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

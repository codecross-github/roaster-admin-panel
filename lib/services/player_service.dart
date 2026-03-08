import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player_model.dart';

class PlayerService {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference get _playersRef =>
      _firestore.collection('milb_transactions');

  /// Fetch a page of players with cursor-based pagination.
  /// Returns the list of players for the page.
  /// [lastDoc] is the last document from the previous page (null for first page).
  /// [pageSize] controls how many documents to fetch.
  Future<PlayerPage> fetchPlayers({
    DocumentSnapshot? lastDoc,
    int pageSize = 50,
  }) async {
    Query query = _playersRef
        .orderBy('_createdAt', descending: true)
        .limit(pageSize);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();
    final players =
        snapshot.docs.map((doc) => PlayerModel.fromFirestore(doc)).toList();
    final hasMore = snapshot.docs.length >= pageSize;
    final newLastDoc =
        snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

    return PlayerPage(
      players: players,
      lastDoc: newLastDoc,
      hasMore: hasMore,
    );
  }

  /// Get total player count using aggregation (lightweight).
  Future<int> getTotalCount() async {
    final snap = await _playersRef.count().get();
    return snap.count ?? 0;
  }

  /// Create a new player.
  Future<void> createPlayer(PlayerModel player) async {
    final data = player.toFirestore();
    data['_createdAt'] = FieldValue.serverTimestamp();
    await _playersRef.add(data);
  }

  /// Update an existing player.
  Future<void> updatePlayer(
      String playerId, Map<String, dynamic> data) async {
    await _playersRef.doc(playerId).update(data);
  }

  /// Delete a player.
  Future<void> deletePlayer(String playerId) async {
    await _playersRef.doc(playerId).delete();
  }
}

/// Holds one page of player results.
class PlayerPage {
  final List<PlayerModel> players;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;

  PlayerPage({
    required this.players,
    this.lastDoc,
    required this.hasMore,
  });
}

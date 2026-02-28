import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/prayer_item.dart';
import '../models/tag.dart';
import 'prayer_repository.dart';

class FirebasePrayerRepository implements PrayerRepository {
  FirebasePrayerRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _itemsCollection =>
      _firestore.collection('prayerItems');

  CollectionReference<Map<String, dynamic>> get _tagsCollection =>
      _firestore.collection('tags');

  @override
  Stream<List<PrayerItem>> watchActiveItems() {
    return _itemsCollection
        .where('isPaused', isEqualTo: false)
        .orderBy('sortOrder')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PrayerItem.fromJson(doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<PrayerItem>> watchPausedItems() {
    return _itemsCollection
        .where('isPaused', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PrayerItem.fromJson(doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<Tag>> watchTags() {
    return _tagsCollection.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => Tag.fromJson(doc.data())).toList(),
    );
  }

  @override
  Future<void> addItem(PrayerItem item) async {
    await _itemsCollection.doc(item.id).set(item.toJson());
  }

  @override
  Future<void> updateItem(PrayerItem item) async {
    await _itemsCollection.doc(item.id).update(item.toJson());
  }

  @override
  Future<void> deleteItem(String id) async {
    await _itemsCollection.doc(id).delete();
  }

  @override
  Future<void> pauseItem(String id) async {
    await _itemsCollection.doc(id).update({'isPaused': true});
  }

  @override
  Future<void> resumeItem(String id) async {
    await _itemsCollection.doc(id).update({'isPaused': false});
  }

  @override
  Future<void> resetAllCompletions() async {
    final batch = _firestore.batch();
    final snapshot = await _itemsCollection
        .where('isCompleted', isEqualTo: true)
        .get();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isCompleted': false});
    }
    await batch.commit();
  }

  @override
  Future<void> addTag(Tag tag) async {
    await _tagsCollection.doc(tag.id).set(tag.toJson());
  }

  @override
  Future<void> updateTag(Tag tag) async {
    await _tagsCollection.doc(tag.id).update(tag.toJson());
  }

  @override
  Future<void> deleteTag(String id) async {
    await _tagsCollection.doc(id).delete();
  }
}

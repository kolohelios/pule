import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/prayer_item.dart';
import '../models/tag.dart';
import 'prayer_repository.dart';

class ICloudPrayerRepository implements PrayerRepository {
  ICloudPrayerRepository({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('com.jedwards.pule/icloud') {
    _channel.setMethodCallHandler(_handleMethodCall);
    _loadInitialData();
  }

  final MethodChannel _channel;

  final _itemsController =
      StreamController<List<PrayerItem>>.broadcast();
  final _pausedItemsController =
      StreamController<List<PrayerItem>>.broadcast();
  final _tagsController = StreamController<List<Tag>>.broadcast();

  List<PrayerItem> _items = [];
  List<Tag> _tags = [];

  Future<void> _loadInitialData() async {
    try {
      final itemsJson = await _channel.invokeMethod<String>('getItems');
      final tagsJson = await _channel.invokeMethod<String>('getTags');

      if (itemsJson != null) {
        _items = _parseItems(itemsJson);
        _emitItems();
      }
      if (tagsJson != null) {
        _tags = _parseTags(tagsJson);
        _tagsController.add(_tags);
      }
    } on PlatformException {
      // iCloud not available; emit empty lists
      _emitItems();
      _tagsController.add(_tags);
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onItemsChanged':
        final json = call.arguments as String;
        _items = _parseItems(json);
        _emitItems();
      case 'onTagsChanged':
        final json = call.arguments as String;
        _tags = _parseTags(json);
        _tagsController.add(_tags);
    }
  }

  List<PrayerItem> _parseItems(String json) {
    final list = jsonDecode(json) as List;
    return list
        .map((e) => PrayerItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<Tag> _parseTags(String json) {
    final list = jsonDecode(json) as List;
    return list.map((e) => Tag.fromJson(e as Map<String, dynamic>)).toList();
  }

  void _emitItems() {
    _itemsController.add(
        _items.where((item) => !item.isPaused).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)));
    _pausedItemsController.add(
        _items.where((item) => item.isPaused).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)));
  }

  Future<void> _saveItems() async {
    final json = jsonEncode(_items.map((e) => e.toJson()).toList());
    await _channel.invokeMethod('setItems', json);
  }

  Future<void> _saveTags() async {
    final json = jsonEncode(_tags.map((e) => e.toJson()).toList());
    await _channel.invokeMethod('setTags', json);
  }

  @override
  Stream<List<PrayerItem>> watchActiveItems() => _itemsController.stream;

  @override
  Stream<List<PrayerItem>> watchPausedItems() => _pausedItemsController.stream;

  @override
  Stream<List<Tag>> watchTags() => _tagsController.stream;

  @override
  Future<void> addItem(PrayerItem item) async {
    _items.add(item);
    _emitItems();
    await _saveItems();
  }

  @override
  Future<void> updateItem(PrayerItem item) async {
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _items[index] = item;
      _emitItems();
      await _saveItems();
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    _items.removeWhere((e) => e.id == id);
    _emitItems();
    await _saveItems();
  }

  @override
  Future<void> pauseItem(String id) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(isPaused: true);
      _emitItems();
      await _saveItems();
    }
  }

  @override
  Future<void> resumeItem(String id) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(isPaused: false);
      _emitItems();
      await _saveItems();
    }
  }

  @override
  Future<void> resetAllCompletions() async {
    _items = _items
        .map((item) => item.isCompleted
            ? item.copyWith(isCompleted: false)
            : item)
        .toList();
    _emitItems();
    await _saveItems();
  }

  @override
  Future<void> addTag(Tag tag) async {
    _tags.add(tag);
    _tagsController.add(_tags);
    await _saveTags();
  }

  @override
  Future<void> updateTag(Tag tag) async {
    final index = _tags.indexWhere((e) => e.id == tag.id);
    if (index != -1) {
      _tags[index] = tag;
      _tagsController.add(_tags);
      await _saveTags();
    }
  }

  @override
  Future<void> deleteTag(String id) async {
    _tags.removeWhere((e) => e.id == id);
    _tagsController.add(_tags);
    await _saveTags();
  }
}

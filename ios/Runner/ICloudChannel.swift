import Flutter
import Foundation

class ICloudChannel {
    private let channel: FlutterMethodChannel
    private let store = NSUbiquitousKeyValueStore.default

    private static let itemsKey = "prayerItems"
    private static let tagsKey = "tags"

    init(messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "com.jedwards.pule/icloud",
            binaryMessenger: messenger
        )

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storeDidChange(_:)),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: store
        )

        store.synchronize()
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getItems":
            result(store.string(forKey: ICloudChannel.itemsKey))
        case "getTags":
            result(store.string(forKey: ICloudChannel.tagsKey))
        case "setItems":
            if let json = call.arguments as? String {
                store.set(json, forKey: ICloudChannel.itemsKey)
                store.synchronize()
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARG", message: "Expected String", details: nil))
            }
        case "setTags":
            if let json = call.arguments as? String {
                store.set(json, forKey: ICloudChannel.tagsKey)
                store.synchronize()
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARG", message: "Expected String", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    @objc private func storeDidChange(_ notification: Notification) {
        if let itemsJson = store.string(forKey: ICloudChannel.itemsKey) {
            channel.invokeMethod("onItemsChanged", arguments: itemsJson)
        }
        if let tagsJson = store.string(forKey: ICloudChannel.tagsKey) {
            channel.invokeMethod("onTagsChanged", arguments: tagsJson)
        }
    }
}

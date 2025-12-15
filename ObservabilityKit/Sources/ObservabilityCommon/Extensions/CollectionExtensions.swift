//
//  CollectionExtensions.swift
//  ObservabilityCommon
//
//  📦 The Collection Alchemist - Where Data Structures Transform ✨
//

import Foundation

@available(macOS 14, iOS 17, *)
public extension Collection {
    /// 🌟 Safe subscript that returns nil for out-of-bounds access
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

@available(macOS 14, iOS 17, *)
public extension Sequence where Element: Numeric {
    /// 🎯 Sum of all elements
    func sum() -> Element {
        reduce(0, +)
    }

    /// 📊 Average of all elements
    func average() -> Double where Element == Double {
        let totalCount = self.reduce(0) { _, _ in 0 + 1 }
        guard totalCount > 0 else { return 0 }
        return sum() / Double(totalCount)
    }

    /// ✨ Average of all elements
    func average() -> Double where Element == Int {
        let totalCount = self.reduce(0) { _, _ in 0 + 1 }
        guard totalCount > 0 else { return 0 }
        return Double(sum()) / Double(totalCount)
    }
}

@available(macOS 14, iOS 17, *)
public extension Sequence {
    /// 🎭 Group elements by a key
    func group<K: Hashable>(by keyPath: KeyPath<Element, K>) -> [K: [Element]] {
        Dictionary(grouping: self) { $0[keyPath: keyPath] }
    }

    /// 🚀 Count elements matching predicate
    func count(where predicate: (Element) throws -> Bool) rethrows -> Int {
        try filter(predicate).count
    }

    /// 💎 Check if all elements are unique by key
    func areUnique<K: Hashable>(by keyPath: KeyPath<Element, K>) -> Bool {
        let keys = map { $0[keyPath: keyPath] }
        return Set(keys).count == keys.count
    }
}

@available(macOS 14, iOS 17, *)
public extension Array {
    /// 🌟 Split array into chunks of specified size
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }

    /// 📦 Remove duplicates while preserving order
    func unique<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }

    /// ✨ Safe removal by index
    @discardableResult
    mutating func remove(atSafe index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return remove(at: index)
    }

    /// 🎭 Remove first element matching predicate
    @discardableResult
    mutating func removeFirst(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        guard let index = try firstIndex(where: predicate) else { return nil }
        return remove(at: index)
    }
}

@available(macOS 14, iOS 17, *)
public extension Dictionary {
    /// 🌟 Merge two dictionaries, preferring self's values
    mutating func merge(with other: [Key: Value]) {
        merge(other) { current, _ in current }
    }

    /// 📊 Get value or default
    func value(for key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
        return self[key] ?? defaultValue()
    }

    /// ✨ Map values to new type
    func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> [Key: T] {
        try .init(uniqueKeysWithValues: map { ($0.key, try transform($0.value)) })
    }

    /// 🎯 Compact map values
    func compactMapValues<T>(_ transform: (Value) throws -> T?) rethrows -> [Key: T] {
        try .init(uniqueKeysWithValues: compactMap { key, value in
            guard let newValue = try transform(value) else { return nil }
            return (key, newValue)
        })
    }
}

//
//  CollectionExtensionsTests.swift
//  ObservabilityCommonTests
//
//  📦 The Collection Validator - Where Data Structures Face Their Ordeal ✨
//

import XCTest
import ObservabilityCommon

final class CollectionExtensionsTests: XCTestCase {

    // MARK: - Safe Subscript Tests

    func testArraySafeSubscript() {
        let array = [1, 2, 3, 4, 5]

        XCTAssertEqual(array[safe: 0], 1)
        XCTAssertEqual(array[safe: 4], 5)
        XCTAssertEqual(array[safe: 5], nil) // Out of bounds
        XCTAssertEqual(array[safe: -1], nil) // Negative index
    }

    func testArraySafeSubscriptEmpty() {
        let array: [Int] = []

        XCTAssertEqual(array[safe: 0], nil)
    }

    // MARK: - Sum Tests

    func testIntArraySum() {
        let numbers = [1, 2, 3, 4, 5]
        XCTAssertEqual(numbers.sum(), 15)
    }

    func testDoubleArraySum() {
        let numbers = [1.5, 2.5, 3.5]
        XCTAssertEqual(numbers.sum(), 7.5)
    }

    func testEmptyArraySum() {
        let numbers: [Int] = []
        XCTAssertEqual(numbers.sum(), 0)
    }

    // MARK: - Average Tests

    func testDoubleArrayAverage() {
        let numbers = [10.0, 20.0, 30.0, 40.0]
        XCTAssertEqual(numbers.average(), 25.0)
    }

    func testIntArrayAverage() {
        let numbers = [10, 20, 30, 40]
        XCTAssertEqual(numbers.average(), 25.0)
    }

    func testEmptyArrayAverage() {
        let numbers: [Int] = []
        XCTAssertEqual(numbers.average(), 0)
    }

    func testSingleElementAverage() {
        let numbers = [42.0]
        XCTAssertEqual(numbers.average(), 42.0)
    }

    // MARK: - Group By Tests

    func testArrayGroupByKeyPath() {
        struct Person {
            let name: String
            let age: Int
        }

        let people = [
            Person(name: "Alice", age: 25),
            Person(name: "Bob", age: 30),
            Person(name: "Charlie", age: 25)
        ]

        let grouped = people.group(by: \.age)

        XCTAssertEqual(grouped[25]?.count, 2)
        XCTAssertEqual(grouped[30]?.count, 1)
        XCTAssertEqual(grouped[25]?.map(\.name), ["Alice", "Charlie"])
    }

    // MARK: - Count Where Tests

    func testArrayCountWhere() {
        let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let evenCount = numbers.count { $0 % 2 == 0 }
        let greaterThanFive = numbers.count { $0 > 5 }

        XCTAssertEqual(evenCount, 5)
        XCTAssertEqual(greaterThanFive, 5)
    }

    func testArrayCountWhereEmpty() {
        let numbers: [Int] = []
        let count = numbers.count { $0 > 5 }

        XCTAssertEqual(count, 0)
    }

    // MARK: - Unique By Tests

    func testArrayAreUniqueBy() {
        struct Item {
            let id: Int
            let name: String
        }

        let items1 = [
            Item(id: 1, name: "A"),
            Item(id: 2, name: "B"),
            Item(id: 3, name: "C")
        ]

        let items2 = [
            Item(id: 1, name: "A"),
            Item(id: 1, name: "B"), // Duplicate ID
            Item(id: 2, name: "C")
        ]

        XCTAssertTrue(items1.areUnique(by: \.id))
        XCTAssertFalse(items2.areUnique(by: \.id))
    }

    // MARK: - Chunked Tests

    func testArrayChunked() {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let chunked = array.chunked(into: 3)

        XCTAssertEqual(chunked.count, 4) // 3 + 3 + 3 + 1
        XCTAssertEqual(chunked[0], [1, 2, 3])
        XCTAssertEqual(chunked[1], [4, 5, 6])
        XCTAssertEqual(chunked[2], [7, 8, 9])
        XCTAssertEqual(chunked[3], [10])
    }

    func testArrayChunkedExact() {
        let array = [1, 2, 3, 4, 5, 6]
        let chunked = array.chunked(into: 3)

        XCTAssertEqual(chunked.count, 2)
        XCTAssertEqual(chunked[0], [1, 2, 3])
        XCTAssertEqual(chunked[1], [4, 5, 6])
    }

    func testArrayChunkedSizeOne() {
        let array = [1, 2, 3]
        let chunked = array.chunked(into: 1)

        XCTAssertEqual(chunked.count, 3)
        XCTAssertEqual(chunked[0], [1])
        XCTAssertEqual(chunked[1], [2])
        XCTAssertEqual(chunked[2], [3])
    }

    func testArrayChunkedSizeZero() {
        let array = [1, 2, 3]
        let chunked = array.chunked(into: 0)

        XCTAssertEqual(chunked.count, 0)
    }

    func testArrayChunkedEmpty() {
        let array: [Int] = []
        let chunked = array.chunked(into: 3)

        XCTAssertTrue(chunked.isEmpty)
    }

    // MARK: - Unique Tests

    func testArrayUnique() {
        struct Person {
            let id: Int
            let name: String
        }

        let people = [
            Person(id: 1, name: "Alice"),
            Person(id: 2, name: "Bob"),
            Person(id: 1, name: "Alice"), // Duplicate
            Person(id: 3, name: "Charlie"),
            Person(id: 2, name: "Robert") // Same ID, different name
        ]

        let unique = people.unique(by: \.id)

        XCTAssertEqual(unique.count, 3)
        XCTAssertEqual(unique.map(\.id), [1, 2, 3])
    }

    func testArrayUniqueNoDuplicates() {
        let numbers = [1, 2, 3, 4, 5]
        let unique = numbers.unique(by: { $0 })

        XCTAssertEqual(unique, numbers)
    }

    // MARK: - Safe Removal Tests

    func testArrayRemoveAtSafe() {
        var array = [1, 2, 3, 4, 5]
        let removed = array.remove(atSafe: 2)

        XCTAssertEqual(removed, 3)
        XCTAssertEqual(array, [1, 2, 4, 5])
    }

    func testArrayRemoveAtSafeOutOfBounds() {
        var array = [1, 2, 3]
        let removed = array.remove(atSafe: 10)

        XCTAssertNil(removed)
        XCTAssertEqual(array, [1, 2, 3]) // Unchanged
    }

    func testArrayRemoveAtSafeNegativeIndex() {
        var array = [1, 2, 3]
        let removed = array.remove(atSafe: -1)

        XCTAssertNil(removed)
        XCTAssertEqual(array, [1, 2, 3])
    }

    func testArrayRemoveFirstWhere() {
        var numbers = [1, 2, 3, 4, 5, 6]
        let removed = numbers.removeFirst { $0 % 2 == 0 }

        XCTAssertEqual(removed, 2)
        XCTAssertEqual(numbers, [1, 3, 4, 5, 6])
    }

    func testArrayRemoveFirstWhereNotFound() {
        var numbers = [1, 3, 5, 7]
        let removed = numbers.removeFirst { $0 % 2 == 0 }

        XCTAssertNil(removed)
        XCTAssertEqual(numbers, [1, 3, 5, 7])
    }
}

// MARK: - Dictionary Extensions Tests

final class DictionaryExtensionsTests: XCTestCase {

    func testDictionaryMerge() {
        var dict1 = ["a": 1, "b": 2, "c": 3]
        let dict2 = ["b": 20, "d": 4]

        dict1.merge(with: dict2)

        XCTAssertEqual(dict1["a"], 1)
        XCTAssertEqual(dict1["b"], 2) // Should keep original value
        XCTAssertEqual(dict1["c"], 3)
        XCTAssertEqual(dict1["d"], 4)
    }

    func testDictionaryValueOrDefault() {
        let dict = ["a": 1, "b": 2]

        XCTAssertEqual(dict.value(for: "a", default: 0), 1)
        XCTAssertEqual(dict.value(for: "b", default: 0), 2)
        XCTAssertEqual(dict.value(for: "c", default: 99), 99) // Default
    }

    func testDictionaryMapValues() {
        let dict = ["a": 1, "b": 2, "c": 3]
        let doubled = dict.mapValues { $0 * 2 }

        XCTAssertEqual(doubled["a"], 2)
        XCTAssertEqual(doubled["b"], 4)
        XCTAssertEqual(doubled["c"], 6)
    }

    func testDictionaryMapValuesTransformation() {
        let dict = ["a": 1, "b": 2, "c": 3]
        let stringValues = dict.mapValues { "\($0)" }

        XCTAssertEqual(stringValues["a"], "1")
        XCTAssertEqual(stringValues["b"], "2")
        XCTAssertEqual(stringValues["c"], "3")
    }

    func testDictionaryCompactMapValues() {
        let dict: [String: Int?] = ["a": 1, "b": nil, "c": 3, "d": nil]
        let filtered = dict.compactMapValues { $0 }

        XCTAssertEqual(filtered["a"], 1)
        XCTAssertNil(filtered["b"])
        XCTAssertEqual(filtered["c"], 3)
        XCTAssertNil(filtered["d"])
    }

    func testDictionaryCompactMapValuesWithCondition() {
        let dict = ["a": 1, "b": 2, "c": 3, "d": 4]
        let evens = dict.compactMapValues { $0 % 2 == 0 ? $0 : nil }

        XCTAssertNil(evens["a"])
        XCTAssertEqual(evens["b"], 2)
        XCTAssertNil(evens["c"])
        XCTAssertEqual(evens["d"], 4)
    }

    func testDictionaryCompactMapValuesEmpty() {
        let dict: [String: Int?] = [:]
        let filtered = dict.compactMapValues { $0 }

        XCTAssertTrue(filtered.isEmpty)
    }
}

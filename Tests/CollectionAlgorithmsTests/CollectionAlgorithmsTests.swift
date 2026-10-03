import XCTest
@testable import CollectionAlgorithms

final class CollectionAlgorithmsTests: XCTestCase {
    func testSafeSubscript() {
        let array = ["Apple", "Banana", "Cherry"]
        XCTAssertEqual(array[safe: 0], "Apple")
        XCTAssertEqual(array[safe: 2], "Cherry")
        XCTAssertNil(array[safe: 3])
        XCTAssertNil(array[safe: -1])
    }

    func testChunked() {
        let numbers = [1, 2, 3, 4, 5, 6, 7]
        let chunks = numbers.chunked(into: 3)
        XCTAssertEqual(chunks, [[1, 2, 3], [4, 5, 6], [7]])

        let empty: [Int] = []
        XCTAssertEqual(empty.chunked(into: 2), [])
    }

    func testWindows() {
        let items = [1, 2, 3, 4]
        let windows = items.windows(ofSize: 2)
        XCTAssertEqual(windows, [[1, 2], [2, 3], [3, 4]])

        let tooLarge = items.windows(ofSize: 5)
        XCTAssertEqual(tooLarge, [])
    }

    func testUniqued() {
        let duplicates = [3, 1, 2, 3, 4, 1, 5, 2]
        let unique = duplicates.uniqued()
        XCTAssertEqual(unique, [3, 1, 2, 4, 5])

        struct User: Equatable {
            let id: Int
            let name: String
        }

        let users = [
            User(id: 1, name: "Alice"),
            User(id: 2, name: "Bob"),
            User(id: 1, name: "Alice Duplicate")
        ]

        let uniqueUsers = users.uniqued(by: \.id)
        XCTAssertEqual(uniqueUsers.count, 2)
        XCTAssertEqual(uniqueUsers.map(\.name), ["Alice", "Bob"])
    }

    func testBinarySearchAndInsertion() {
        let sorted = [10, 20, 30, 40, 50]
        XCTAssertEqual(sorted.binarySearch(for: 30), 2)
        XCTAssertEqual(sorted.binarySearch(for: 10), 0)
        XCTAssertEqual(sorted.binarySearch(for: 50), 4)
        XCTAssertNil(sorted.binarySearch(for: 25))

        XCTAssertEqual(sorted.insertionIndex(for: 25), 2)
        XCTAssertEqual(sorted.insertionIndex(for: 5), 0)
        XCTAssertEqual(sorted.insertionIndex(for: 55), 5)
    }

    func testLRUCacheOperations() async {
        let cache = LRUCache<String, Int>(capacity: 2)

        await cache.set(100, forKey: "A")
        await cache.set(200, forKey: "B")

        let count = await cache.count
        XCTAssertEqual(count, 2)

        // Access "A" to make it most recently used
        let valA = await cache.get("A")
        XCTAssertEqual(valA, 100)

        // Insert "C" -> should evict "B" (least recently used)
        await cache.set(300, forKey: "C")

        let cachedB = await cache.get("B")
        XCTAssertNil(cachedB, "B should have been evicted")

        let cachedC = await cache.get("C")
        XCTAssertEqual(cachedC, 300)

        let cachedA2 = await cache.get("A")
        XCTAssertEqual(cachedA2, 100)

        // Remove
        await cache.removeValue(forKey: "A")
        let finalCount = await cache.count
        XCTAssertEqual(finalCount, 1)
    }
}

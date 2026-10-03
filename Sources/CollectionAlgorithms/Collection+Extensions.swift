import Foundation

public extension Collection {
    /// Safely accesses the element at the specified index without triggering an out-of-bounds fatal error.
    ///
    /// ```swift
    /// let items = ["A", "B", "C"]
    /// items[safe: 1]  // "B"
    /// items[safe: 10] // nil
    /// ```
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    /// Partitions the collection into discrete chunks of a specified maximum size.
    ///
    /// ```swift
    /// [1, 2, 3, 4, 5].chunked(into: 2) // [[1, 2], [3, 4], [5]]
    /// ```
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        var result: [[Element]] = []
        var currentChunk: [Element] = []
        currentChunk.reserveCapacity(size)

        for element in self {
            currentChunk.append(element)
            if currentChunk.count == size {
                result.append(currentChunk)
                currentChunk = []
                currentChunk.reserveCapacity(size)
            }
        }

        if !currentChunk.isEmpty {
            result.append(currentChunk)
        }

        return result
    }

    /// Produces a sliding window of sequential slices of the specified size.
    ///
    /// ```swift
    /// [1, 2, 3, 4].windows(ofSize: 2) // [[1, 2], [2, 3], [3, 4]]
    /// ```
    func windows(ofSize size: Int) -> [[Element]] {
        guard size > 0, count >= size else { return [] }
        let elements = Array(self)
        var result: [[Element]] = []
        result.reserveCapacity(elements.count - size + 1)

        for i in 0...(elements.count - size) {
            let window = Array(elements[i..<(i + size)])
            result.append(window)
        }

        return result
    }
}

public extension Sequence {
    /// Returns an array containing the unique elements of the sequence, preserving their original order in O(N) time.
    ///
    /// ```swift
    /// [1, 2, 2, 3, 1, 4].uniqued() // [1, 2, 3, 4]
    /// ```
    func uniqued() -> [Element] where Element: Hashable {
        var seen = Set<Element>()
        var result: [Element] = []

        for element in self {
            if seen.insert(element).inserted {
                result.append(element)
            }
        }

        return result
    }

    /// Returns an array containing the elements of the sequence with unique values for the given key path, preserving order.
    func uniqued<Property: Hashable>(by keyPath: KeyPath<Element, Property>) -> [Element] {
        var seen = Set<Property>()
        var result: [Element] = []

        for element in self {
            let key = element[keyPath: keyPath]
            if seen.insert(key).inserted {
                result.append(element)
            }
        }

        return result
    }
}

public extension RandomAccessCollection where Element: Comparable {
    /// Performs binary search on a sorted collection in O(log N) time.
    /// Returns the index of the element if found, or nil otherwise.
    func binarySearch(for element: Element) -> Index? {
        guard !isEmpty else { return nil }
        var low = startIndex
        var high = index(before: endIndex)

        while low <= high {
            let midDistance = distance(from: low, to: high) / 2
            let mid = index(low, offsetBy: midDistance)

            if self[mid] == element {
                return mid
            } else if self[mid] < element {
                guard mid < high else { break }
                low = index(after: mid)
            } else {
                guard mid > low else { break }
                high = index(before: mid)
            }
        }

        return nil
    }

    /// Computes the insertion index for an element in a sorted collection to maintain sort order in O(log N) time.
    func insertionIndex(for element: Element) -> Index {
        var low = startIndex
        var high = endIndex

        while low < high {
            let midDistance = distance(from: low, to: high) / 2
            let mid = index(low, offsetBy: midDistance)

            if self[mid] < element {
                low = index(after: mid)
            } else {
                high = mid
            }
        }

        return low
    }
}

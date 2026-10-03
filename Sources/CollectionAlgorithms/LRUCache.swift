import Foundation

private final class CacheNode<Key: Hashable, Value> {
    let key: Key
    var value: Value
    var prev: CacheNode?
    var next: CacheNode?

    init(key: Key, value: Value) {
        self.key = key
        self.value = value
    }
}

/// A thread-safe, high-performance Least Recently Used (LRU) cache backed by a Swift 6 actor.
///
/// Features amortized O(1) lookups, insertions, and evictions using a combined hash table
/// and doubly-linked list.
public actor LRUCache<Key: Hashable & Sendable, Value: Sendable> {
    public let capacity: Int
    private var countInternal: Int = 0
    private var nodeMap: [Key: CacheNode<Key, Value>] = [:]

    private var head: CacheNode<Key, Value>?
    private var tail: CacheNode<Key, Value>?

    public init(capacity: Int) {
        precondition(capacity > 0, "Capacity must be greater than zero.")
        self.capacity = capacity
    }

    /// Retrieves an element from the cache and marks it as most recently used.
    public func get(_ key: Key) -> Value? {
        guard let node = nodeMap[key] else { return nil }
        moveToHead(node)
        return node.value
    }

    /// Inserts or updates an element in the cache, evicting the least recently used element if capacity is exceeded.
    public func set(_ value: Value, forKey key: Key) {
        if let existing = nodeMap[key] {
            existing.value = value
            moveToHead(existing)
            return
        }

        let newNode = CacheNode(key: key, value: value)
        nodeMap[key] = newNode
        addToHead(newNode)
        countInternal += 1

        if countInternal > capacity {
            evictLRU()
        }
    }

    /// Removes an element from the cache.
    @discardableResult
    public func removeValue(forKey key: Key) -> Value? {
        guard let node = nodeMap.removeValue(forKey: key) else { return nil }
        removeNode(node)
        countInternal -= 1
        return node.value
    }

    /// Clears all elements from the cache.
    public func removeAll() {
        nodeMap.removeAll()
        head = nil
        tail = nil
        countInternal = 0
    }

    /// Current number of elements in the cache.
    public var count: Int {
        countInternal
    }

    // MARK: - Doubly-Linked List Helpers

    private func addToHead(_ node: CacheNode<Key, Value>) {
        node.next = head
        node.prev = nil
        head?.prev = node
        head = node
        if tail == nil {
            tail = node
        }
    }

    private func removeNode(_ node: CacheNode<Key, Value>) {
        if let prev = node.prev {
            prev.next = node.next
        } else {
            head = node.next
        }

        if let next = node.next {
            next.prev = node.prev
        } else {
            tail = node.prev
        }

        node.prev = nil
        node.next = nil
    }

    private func moveToHead(_ node: CacheNode<Key, Value>) {
        guard head !== node else { return }
        removeNode(node)
        addToHead(node)
    }

    private func evictLRU() {
        guard let lru = tail else { return }
        nodeMap.removeValue(forKey: lru.key)
        removeNode(lru)
        countInternal -= 1
    }
}

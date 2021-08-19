//
//  solution.swift
//  treepatrol
//
//  Created by shunnamiki on 2021/08/17.
//

import Foundation

// copy-paste all your classes/structs used in the program.
/// The Queue class represents a first-in-first-out (FIFO) queue of generic items.
/// It supports the usual *eunque* and *dequeue* operations, along with methods for peeking at the first item, testing if the queue is empty, and iterating through the items in FIFO order.
/// This implementation uses a singly linked list with an inner class for linked list nodes.
public final class Queue<E> : Sequence {
    /// beginning of queue
    private var first: Node<E>? = nil
    /// end of queue
    private var last: Node<E>? = nil
    /// size of the queue
    private(set) var count: Int = 0
    
    /// helper linked list node class
    fileprivate class Node<E> {
        fileprivate var item: E
        fileprivate var next: Node<E>?
        fileprivate init(item: E, next: Node<E>? = nil) {
            self.item = item
            self.next = next
        }
    }
    
    /// Initializes an empty queue.
    public init() {}
    
    /// Returns true if this queue is empty.
    public func isEmpty() -> Bool {
        return first == nil
    }
    
    /// Returns the item least recently added to this queue.
    public func peek() -> E? {
        return first?.item
    }
    
    /// Adds the item to this queue
    /// - Parameter item: the item to add
    public func enqueue(item: E) {
        let oldLast = last
        last = Node<E>(item: item)
        if isEmpty() { first = last }
        else { oldLast?.next = last }
        count += 1
    }
    
    /// Removes and returns the item on this queue that was least recently added.
    public func dequeue() -> E? {
        if let item = first?.item {
            first = first?.next
            count -= 1
            // to avoid loitering
            if isEmpty() { last = nil }
            return item
        }
        return nil
    }
    
    /// QueueIterator that iterates over the items in FIFO order.
    public struct QueueIterator<E> : IteratorProtocol {
        private var current: Node<E>?
        
        fileprivate init(_ first: Node<E>?) {
            self.current = first
        }
        
        public mutating func next() -> E? {
            if let item = current?.item {
                current = current?.next
                return item
            }
            return nil
        }
        
        public typealias Element = E
    }
    
    /// Returns an iterator that iterates over the items in this Queue in FIFO order.
    public __consuming func makeIterator() -> QueueIterator<E> {
        return QueueIterator<E>(first)
    }
}

extension Queue: CustomStringConvertible {
    public var description: String {
        return self.reduce(into: "") { $0 += "\($1) " }
    }
}

// ...

func solution() {
    // read firstline
    let firstLine = readLine()!.split(separator: " ").map { Int($0)! }
    let N = firstLine[0]
    let M = firstLine[1]
    
    // read second line
    let sushiList: [Int] = readLine()!.split(separator: " ").map { Int($0)! }
    
    // read thrid line
    var adj = [[Int]](repeating: [], count: N)
    for _ in 0..<N-1 {
        let line = readLine()!.split(separator: " ").map { Int($0)! }
        let a = line[0]
        let b = line[1]
        adj[a].append(b)
        adj[b].append(a)
    }
    
    // your main logic (input processing, algorithm, etc.)

    // 1. pruning
    prune(adj: &adj, sushiList: sushiList)
    
    // 2. get diameter
    let diameter = getDiameter(adj: adj)
    
    // 3. Calulate result
    let path = calcRoute(adj: adj, diameter: diameter)
    
    // print the result (make sure you follow the output specification)
    print(path)
}

// you can include as many helper functions as you want.

func prune(adj: inout [[Int]], sushiList: [Int]) {
    let q = Queue<Int>()
    for i in 0..<adj.count {
        let shouldPrune = adj[i].count == 1 && !sushiList.contains(i)
        if !shouldPrune { continue }
        q.enqueue(item: i)
    }

    while !q.isEmpty() {
        let current = q.dequeue()!
        let shouldPrune = adj[current].count == 1 && !sushiList.contains(current)
        if !shouldPrune { continue }
        
        // prune
        let opposite = adj[current].popLast()!
        adj[opposite].removeAll(where: { $0 == current })
        
        q.enqueue(item: opposite)
    }
}

func getDiameter(adj: [[Int]]) -> Int {
    // ready for first dfs
    let firstFrom = adj.firstIndex(where: { $0.count != 0 })
    if firstFrom == nil { return 0 }

    // first dfs
    var visited1 = [Bool](repeating: false, count: adj.count)
    var distances1 = [Int](repeating: 0, count: adj.count)
    dfs(from: firstFrom!, adj: adj, visited: &visited1, distances: &distances1)
    
    // ready for second dfs
    var secondFrom = -1
    var diameter = -1
    for i in 0..<distances1.count {
        if distances1[i] > diameter {
            diameter = distances1[i]
            secondFrom = i
        }
    }
    
    // second dfs
    var visited2 = [Bool](repeating: false, count: adj.count)
    var distances2 = [Int](repeating: 0, count: adj.count)
    dfs(from: secondFrom, adj: adj, visited: &visited2, distances: &distances2)
    
    return distances2.max()!
}

func dfs(from: Int, adj: [[Int]], visited: inout [Bool], distances: inout [Int]) {
    let q = Queue<Int>()
    visited[from] = true
    q.enqueue(item: from)
    
    while !q.isEmpty() {
        let current = q.dequeue()!
        for next in adj[current] {
            if visited[next] { continue }
            distances[next] = distances[current] + 1
            visited[next] = true
            q.enqueue(item: next)
        }
    }
}

func calcRoute(adj: [[Int]], diameter: Int) -> Int {
    let validAdj = adj.filter({ $0.count != 0})
    let edge = validAdj.count - 1
    let twoWay = edge * 2
    return twoWay - diameter
}

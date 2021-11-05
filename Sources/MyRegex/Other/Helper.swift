//
//  File.swift
//  
//
//  Created by Ilya Buldin on 15.10.2021.
//

import Foundation

public struct MyPair<X: Hashable, Y: Hashable>: Hashable {
    let x: X
    let y: Y
    
    init(x: X, y: Y) {
        self.x = x
        self.y = y
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x.hashValue << 32 & (y.hashValue | 0xffffffff))
    }
}

public func == <X: Hashable, Y: Hashable> (lhs: MyPair<X, Y>, rhs: MyPair<X, Y>) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}


public struct Table<X: Hashable, Y: Hashable, V> {
    var stored: [Int: V] = [:]
    var storedKeys: Set<MyPair<X, Y>> = []
    
    public var keys: [(x: X, y:Y)] {
        var tmp: [(x: X, y:Y)] = []
        for pair in storedKeys {
            tmp.append((x: pair.x, y: pair.y))
        }
        return tmp
    }
    
    public subscript (x: X, y: Y) -> V? {
        get {
            return stored[MyPair(x: x, y: y).hashValue]
        }
        set {
            storedKeys.insert(MyPair(x: x, y: y))
            stored[MyPair(x: x, y: y).hashValue] = newValue
        }
    }
}


public class TreeNode<T> {
    public var value: T

    public weak var parent: TreeNode?
    public var children = [TreeNode<T>]()

    public init(value: T) {
        self.value = value
    }

    public func addChild(_ node: TreeNode<T>) {
        children.append(node)
        node.parent = self
    }
}

extension TreeNode: CustomStringConvertible {
    public var description: String {
        var s = "\(value)"
        if !children.isEmpty {
            s += " {" + children.map { $0.description }.joined(separator: ", ") + "}"
        }
        return s
    }
}

extension TreeNode where T: Equatable {
    public func search(_ value: T) -> TreeNode? {
        if value == self.value {
            return self
        }
        for child in children {
            if let found = child.search(value) {
                return found
            }
        }
        return nil
    }
}


extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

//
//  LinkedList.swift
//
//  Copyright (c) 2019 Evolv Technology Solutions
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public final class LinkedList<T> {
    
    public class LinkedListNode<T> {
        var value: T
        var next: LinkedListNode?
        weak var previous: LinkedListNode?
        
        public init(value: T) {
            self.value = value
        }
    }
    
    public typealias Node = LinkedListNode<T>
    
    fileprivate var head: Node?
    
    public init() {}
    
    public var isEmpty: Bool {
        return head == nil
    }
    
    public var first: Node? {
        return head
    }
    
    public var last: Node? {
        if var node = head {
            while let next = node.next {
                node = next
            }
            
            return node
        } else {
            return nil
        }
    }
    
    public var count: Int {
        if var node = head {
            var counter = 1
            
            while let next = node.next {
                node = next
                counter += 1
            }
            
            return counter
        } else {
            return 0
        }
    }
    
    public func node(atIndex index: Int) -> Node? {
        if index >= 0 {
            var node = head
            var currentIndex = index
            
            while node != nil {
                if currentIndex == 0 { return node }
                currentIndex -= 1
                node = node!.next
            }
        }
        
        return nil
    }
    
    public subscript(index: Int) -> T {
        let node = self.node(atIndex: index)
        assert(node != nil)
        return node!.value
    }
    
    public func append(_ value: T) {
        let newNode = Node(value: value)
        self.append(newNode)
    }
    
    public func append(_ node: Node) {
        let newNode = LinkedListNode(value: node.value)
        
        if let lastNode = last {
            newNode.previous = lastNode
            lastNode.next = newNode
        } else {
            head = newNode
        }
    }
    
    public func append(_ list: LinkedList) {
        var nodeToCopy = list.head
        
        while let node = nodeToCopy {
            self.append(node.value)
            nodeToCopy = node.next
        }
    }
    
    private func nodesBeforeAndAfter(index: Int) -> (Node?, Node?) {
        assert(index >= 0)
        
        var currentIndex = index
        var next = head
        var prev: Node?
        
        while next != nil && currentIndex > 0 {
            currentIndex -= 1
            prev = next
            next = next!.next
        }
        
        // if > 0, then specified index was too large
        assert(currentIndex == 0)
        return (prev, next)
    }
    
    public func insert(_ value: T, atIndex index: Int) {
        let newNode = Node(value: value)
        self.insert(newNode, atIndex: index)
    }
    
    public func insert(_ node: Node, atIndex index: Int) {
        let (prev, next) = nodesBeforeAndAfter(index: index)
        let newNode = LinkedListNode(value: node.value)
        newNode.previous = prev
        newNode.next = next
        prev?.next = newNode
        next?.previous = newNode
        
        if prev == nil {
            head = newNode
        }
    }
    
    public func insert(_ list: LinkedList, atIndex index: Int) {
        if list.isEmpty { return }
        var (prev, next) = nodesBeforeAndAfter(index: index)
        var nodeToCopy = list.head
        var newNode: Node?
        
        while let node = nodeToCopy {
            newNode = Node(value: node.value)
            newNode?.previous = prev
            
            if let previous = prev {
                previous.next = newNode
            } else {
                self.head = newNode
            }
            
            nodeToCopy = nodeToCopy?.next
            prev = newNode
        }
        
        prev?.next = next
        next?.previous = prev
    }
    
    public func removeAll() {
        head = nil
    }
    
    @discardableResult public func remove(node: Node) -> T {
        let prev = node.previous
        let next = node.next
        
        if let prev = prev {
            prev.next = next
        } else {
            head = next
        }
        
        next?.previous = prev
        
        node.previous = nil
        node.next = nil
        return node.value
    }
    
    @discardableResult public func removeLast() -> T {
        assert(!isEmpty)
        return remove(node: last!)
    }
    
    @discardableResult public func remove(atIndex index: Int) -> T {
        let node = self.node(atIndex: index)
        assert(node != nil)
        return remove(node: node!)
    }
    
}

extension LinkedList: CustomStringConvertible {
    
    public var description: String {
        var str = "["
        var node = head
        
        while node != nil {
            str += "\(node!.value)"
            node = node!.next
            if node != nil { str += ", " }
        }
        
        return str + "]"
    }
    
}

extension LinkedList {
    
    public func reverse() {
        var node = head
        
        while let currentNode = node {
            node = currentNode.next
            swap(&currentNode.next, &currentNode.previous)
            head = currentNode
        }
    }
    
}

extension LinkedList {
    
    public func map<U>(transform: (T) -> U) -> LinkedList<U> {
        let result = LinkedList<U>()
        var node = head
        
        while node != nil {
            result.append(transform(node!.value))
            node = node!.next
        }
        
        return result
    }
    
    public func filter(predicate: (T) -> Bool) -> LinkedList<T> {
        let result = LinkedList<T>()
        var node = head
        
        while node != nil {
            if predicate(node!.value) {
                result.append(node!.value)
            }
            
            node = node!.next
        }
        
        return result
    }
    
}

extension LinkedList {
    
    convenience init(array: [T]) {
        self.init()
        
        for element in array {
            self.append(element)
        }
    }
    
}

extension LinkedList: ExpressibleByArrayLiteral {
    
    public convenience init(arrayLiteral elements: T...) {
        self.init()
        
        for element in elements {
            self.append(element)
        }
    }
    
}

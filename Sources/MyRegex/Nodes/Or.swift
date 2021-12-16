//
//  File.swift
//  
//
//  Created by Ilya Buldin on 04.11.2021.
//

import Foundation


final class Or: BinaryNode {
    
    init(left: Node, right: Node) {
        super.init(workingToken: Token(tag: Tag.getOrTag()), left: left, right: right)
    }
    
    
    override func clone() -> Node {
        let newNode = Or(left: leftNode.clone(), right: rightNode.clone())
        return newNode
    }
    
    override func printNode(tabsNum: Int) {
        let tabs = String(repeating: "-", count: tabsNum)
        
        var s = ""
        if token.tag < 256 {
            s = String(UnicodeScalar(UInt8(token.tag)))
        } else {
            s = String(token.tag)
        }
        
        print("\(tabs)🍒 Or Node with tag \"\(s)\":\n")
        leftNode.printNode(tabsNum: tabsNum+1)
        rightNode.printNode(tabsNum: tabsNum+1)
    }
    
    override func inverse() {
        leftNode.inverse()
        rightNode.inverse()
        let tmp: Node = leftNode
        leftNode = rightNode
        rightNode = tmp
    }
}

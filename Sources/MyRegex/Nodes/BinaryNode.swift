//
//  File.swift
//  
//
//  Created by Ilya Buldin on 04.11.2021.
//

import Foundation

protocol BinaryNodeProtocol {
    var leftNode: Node { get }
    var rightNode: Node { get }
}

class BinaryNode: Node, BinaryNodeProtocol {
    let leftNode: Node
    let rightNode: Node
    
    init(workingToken: Token, left: Node, right: Node) {
        self.leftNode = left
        self.rightNode = right
        super.init(token: workingToken)
    }
    
    
    override func printNode(tabsNum: Int) {
        let tabs = String(repeating: "-", count: tabsNum)
        
        var s = ""
        if token.tag < 256 {
            s = String(UnicodeScalar(UInt8(token.tag)))
        } else {
            s = String(token.tag)
        }
        
        print("\(tabs)👨‍❤️‍👨 Binary Node with tag \"\(s)\":\n")
        leftNode.printNode(tabsNum: tabsNum+1)
        rightNode.printNode(tabsNum: tabsNum+1)
    }
    

}



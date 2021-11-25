//
//  File.swift
//  
//
//  Created by Ilya Buldin on 04.11.2021.
//

import Foundation


final class PositiveClosure: Node {
    
    let targetNode: Node
    
    init(targetNode: Node) {
        self.targetNode = targetNode
        super.init(token: Token(tag: Tag.getPositiveClosureTag()))
    }
    
    override func clone() -> Node {
        let newNode = PositiveClosure(targetNode: targetNode.clone())
        return newNode
    }
    
    
    override func printNode(tabsNum: Int) {
        var res = ""
        let tabs = String(repeating: "-", count: tabsNum)
        if token.tag < 256 {
            let s = String(UnicodeScalar(UInt8(token.tag)))
            res += "✅ Positive Node with token tag \"\(s)\""
        } else {
            res +=  "✅ Positive Node with token tag \"\(token.tag)\""
        }
        
        print("\(tabs)\(res)\n")
        targetNode.printNode(tabsNum: tabsNum+1)
    }
}

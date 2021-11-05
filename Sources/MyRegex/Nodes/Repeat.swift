//
//  File.swift
//  
//
//  Created by Ilya Buldin on 04.11.2021.
//

import Foundation


final class RepeatExpression: Node {
    
    private let targetNode: Node
    
    init(targetNode: Node, token: Token) {
        self.targetNode = targetNode
        super.init(token: token)
    }
    
    override func clone() -> Node {
        let newNode = RepeatExpression(targetNode: targetNode.clone(), token: token)
        return newNode
    }
    
    override func printNode(tabsNum: Int) {
        var res = ""
        let tabs = String(repeating: "-", count: tabsNum)
        
        res +=  "♻️ Repeat Node with token tag \"\(token.tag)\""
        
        
        print("\(tabs)\(res)\n")
        targetNode.printNode(tabsNum: tabsNum+1)
    }
}

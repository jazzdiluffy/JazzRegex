//
//  File.swift
//  
//
//  Created by Ilya Buldin on 05.11.2021.
//

import Foundation


final class CaptureNode: Node {
    let child: Node
    
    init(child: Node, token: Token) {
        self.child = child
        super.init(token: token)
    }
    
    func getChild() -> Node {
        return child
    }
    
    override func printNode(tabsNum: Int) {
        var res = ""
        let tabs = String(repeating: "-", count: tabsNum)
        
        res +=  "🔐 Capture Group Node with token tag \"\(token.tag)\""
        
        
        print("\(tabs)\(res)\n")
        child.printNode(tabsNum: tabsNum+1)
    }
}

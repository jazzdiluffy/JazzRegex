//
//  File.swift
//  
//
//  Created by Ilya Buldin on 04.11.2021.
//

import Foundation

final class Literal: Node {
    
    override init(token: Token) {
        super.init(token: token)
    }
    
    override func clone() -> Node {
        let newNode = Literal(token: token)
        return newNode
    }
    
    override func printNode(tabsNum: Int) {
        var res = ""
        let tabs = String(repeating: "-", count: tabsNum)
        if token.tag < 256 {
            let s = String(UnicodeScalar(UInt8(token.tag)))
            res += "🅰️ Literal Node with token tag \"\(s)\""
            
        } else {
            res +=  "🅰️ Literal Node with token tag \"\(token.tag)\""
        }
        
        print("\(tabs)\(res)")
    }
}

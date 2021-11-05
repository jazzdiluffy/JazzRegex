//
//  File.swift
//  
//
//  Created by Ilya Buldin on 04.11.2021.
//

import Foundation

protocol NodeProtocol {
    var token: Token { get }
}


class Node {
    let token: Token
    
    init(token: Token) {
        self.token = token
    }
    
    func clone() -> Node {
        let newNode = Node(token: token)
        return newNode
    }
    
    func printNode(tabsNum: Int) {
        var res = ""
        let tabs = String(repeating: "-", count: tabsNum)
        if token.tag < 256 {
            let s = String(UnicodeScalar(UInt8(token.tag)))
            res += "🔥 Node with token tag \"\(s)\""
            
        } else {
            res +=  "🔥 Node with token tag \"\(token.tag)\""
        }
        
        print("\(tabs)\(res)")
    }
    
}



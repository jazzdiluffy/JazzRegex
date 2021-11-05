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
    
}

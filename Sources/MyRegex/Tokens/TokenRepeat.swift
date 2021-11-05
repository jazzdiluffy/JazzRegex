//
//  File.swift
//  
//
//  Created by Ilya Buldin on 05.11.2021.
//

import Foundation


protocol TokenRepeatProtocol {
    var start: Int { get }
    var end: Int { get }
}


final class TokenRepeat: Token, TokenRepeatProtocol {
    let start: Int
    let end: Int
    
    init(start: Int, end: Int) {
        self.start = start
        self.end = end
        super.init(tag: Tag.getRepeatExpressionTag())
    }
    
    
}

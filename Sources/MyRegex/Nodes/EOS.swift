//
//  File.swift
//  
//
//  Created by Ilya Buldin on 04.11.2021.
//

import Foundation


final class EOS: Node {
    
    init() {
        super.init(token: Token(tag: Tag.getEOSTag()))
    }
    
}

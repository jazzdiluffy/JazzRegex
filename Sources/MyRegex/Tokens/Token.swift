//
//  File.swift
//  
//
//  Created by Ilya Buldin on 03.11.2021.
//

import Foundation

protocol TokenProtocol {
    var tag: Int { get }
}

class Token: TokenProtocol {
    let tag: Int
    
    init(tag: Int) {
        self.tag = tag
    }
}

//
//  File.swift
//  
//
//  Created by Ilya Buldin on 04.11.2021.
//

import Foundation


final class CaptureGroup: Token {
    
    var num: Int
    
    func getNum() -> Int {
        return num
    }
    
    init(num: Int) {
        self.num = num
        super.init(tag: Tag.getCaptureGroupTag())
    }
}

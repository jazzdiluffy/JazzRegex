//
//  File.swift
//  
//
//  Created by Ilya Buldin on 04.11.2021.
//

import Foundation


final class Group: Token {
    private let number: Int
    
    func getNumber() -> Int {
        return number
    }
        
    init(number: Int) {
        self.number = number
        super.init(tag: Tag.getGroupTag())
    }
}

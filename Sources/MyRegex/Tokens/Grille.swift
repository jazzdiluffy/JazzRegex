//
//  File.swift
//  
//
//  Created by Ilya Buldin on 04.11.2021.
//

import Foundation

final class Grille: Token {
    let literal: Int
    
    func getLiteral() -> Int {
        return literal
    }
    
    init(literal: String) {
        let stringArray = Array(literal)
        guard let uint8value = stringArray[0].asciiValue else {
            fatalError("Cant unwrap UIInt8? value of \(literal)")
        }
        self.literal = Int(uint8value)
        super.init(tag: Tag.getGrilleTag())
    }
}

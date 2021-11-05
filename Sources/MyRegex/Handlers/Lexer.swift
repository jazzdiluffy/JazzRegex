//
//  File.swift
//  
//
//  Created by Ilya Buldin on 03.11.2021.
//

import Foundation


final class Lexer {
    
    var isEOS: Bool = false
    var position: Int = 0
    var pattern: String
    
    init(withPattern pattern: String) {
        self.pattern = pattern
    }
    
    private func pullOut(at i: Int) -> String {
        return pattern[i]
    }
    
    func analyze() -> Token {
        if position >= pattern.length {
            isEOS = true
        } else {
            print(pullOut(at: position))
            if pullOut(at: position) == "{" {
                
                var tmp = position + 1
                while Int(pullOut(at: tmp)) != nil {
                    tmp += 1
                }
                if pullOut(at: tmp) != "," || tmp == position + 1 {
                    fatalError()
                }
                guard let start = Int(pattern[position+1 ..< tmp]) else {
                    fatalError()
                }
                position = tmp + 1
                var end: Int = -100
                if pullOut(at: position) == "}" {
                    end = -1
                } else {
                    tmp += 1
                    if Int(pullOut(at: tmp)) == nil {
                        fatalError()
                    }
                    while Int(pullOut(at: tmp)) != nil {
                        tmp += 1
                    }
                    guard let unwrappedEnd = Int(pattern[position ..< tmp]) else {
                        fatalError()
                    }
                    end = unwrappedEnd
                    position = tmp
                }
                if pullOut(at: position) != "}" {
                    fatalError()
                }
                position += 1
                return TokenRepeat(start: start, end: end)
            } else if pullOut(at: position) == "(" {
                
                var tmp = position + 1
                while Int(pullOut(at: tmp)) != nil {
                    tmp += 1
                }
                if pullOut(at: tmp) == ":" && tmp != position + 1 {
                    
                    guard let captureGroupNumber = Int(pattern[position+1 ..< tmp]) else {
                        fatalError("Cant convert \"\(pattern[position+1 ..< tmp])\" to Int in capture group")
                    }
                    position = tmp + 1
                    return CaptureGroup(num: captureGroupNumber)
                } else {
                    let literalToken = Token(tag: Tag.getTagOfOpenBrace())
                    position += 1
                    return literalToken
                }
                
            } else if pullOut(at: position) == "#" {
                
                position += 1
                let grilleToken = Grille(literal: pullOut(at: position))
                position += 1
                return grilleToken
                
            } else if pullOut(at: position) == "\\" {
                
                var tmp = position + 1
                guard let _ = Int(pullOut(at: tmp)) else {
                    fatalError("Bad syntax of regex pattern: it should be number of capturing group after \"\\\"")
                }
                while Int(pullOut(at: tmp)) != nil {
                    tmp += 1
                }
                guard let groupNumber = Int(pattern[position+1 ..< tmp]) else {
                    fatalError("Cant convert \"\(pattern[position+1 ..< tmp])\" to Int in capture group")
                }
                position = tmp
                return Group(number: groupNumber)
                
            } else {
                
                if pullOut(at: position) >= " " {
                    guard let tag = Character(pullOut(at: position)).asciiValue else {
                        fatalError()
                    }
                    let token = Token(tag: Int(tag))
                    position += 1
                    return token
                } else {
                    fatalError()
                }
            }
        }
        
        return Token(tag: 0)
    }
}

import Foundation

final class Tag {
    
    private static let grille: UInt8? = Character("#").asciiValue
    private static let empty: UInt8? = Character("^").asciiValue
    private static let or: UInt8? = Character("|").asciiValue
    private static let concatenation: UInt8? = Character(".").asciiValue
    private static let positiveClosure: UInt8? = Character("+").asciiValue
    private static let repeatExpression: Int = 257
    private static let captureGroup: Int = 258
    private static let group: [UInt8?] = "\\".compactMap { $0.asciiValue }
    private static let EOS: Int = 259
    
    static func getGrilleTag() -> Int {
        guard let uint8Value = grille else {
            fatalError("Cant unwrap UInt8? value of grille")
        }
        
        return Int(uint8Value)
    }
    
    static func getEmptyTag() -> Int {
        guard let uint8Value = empty else {
            fatalError("Cant unwrap UInt8? value of empty")
        }
        
        return Int(uint8Value)
    }
    
    static func getOrTag() -> Int {
        guard let uint8Value = or else {
            fatalError("Cant unwrap UInt8? value of or")
        }
        
        return Int(uint8Value)
    }
    
    static func getConcatenationTag() -> Int {
        guard let uint8Value = concatenation else {
            fatalError("Cant unwrap UInt8? value of concatenation")
        }
        
        return Int(uint8Value)
    }
    
    static func getPositiveClosureTag() -> Int {
        guard let uint8Value = positiveClosure else {
            fatalError("Cant unwrap UInt8? value of positiveClosure")
        }
        
        return Int(uint8Value)
    }
    
    static func getRepeatExpressionTag() -> Int {
        return repeatExpression
    }
    
    static func getCaptureGroupTag() -> Int {
        return captureGroup
    }
    
    static func getGroupTag() -> Int {
        var str: String = ""
        for val in group {
            guard let uint8Value = val else {
                fatalError("Cant unwrap UInt8? value of group")
            }
            str += String(uint8Value)
        }

        guard let intValue = Int(str) else {
            fatalError("Cant convert String to Int for group tag")
        }

        return intValue
    }

    
    static func getEOSTag() -> Int {
        return EOS
    }
    
}


extension Tag {
    static func getTagOfCloseBrace() -> Int {
        guard let uint8Value = Character(")").asciiValue else {
            fatalError("Cant unwrap UInt8? value of or")
        }
        
        return Int(uint8Value)
    }
    
    
    static func getTagOfOpenBrace() -> Int {
        guard let uint8Value = Character("(").asciiValue else {
            fatalError("Cant unwrap UInt8? value of or")
        }
        
        return Int(uint8Value)
    }
    
}


//
//  File.swift
//  
//
//  Created by Ilya Buldin on 03.11.2021.
//

import Foundation


protocol ParserProtocol {
    var lexer: Lexer { get }
    var look: Token { get }
    var table: [Int : Node] { get }
    var root: BinaryNode? { get }
}


final class Parser: ParserProtocol {
    
    var lexer: Lexer
    var look: Token
    var table: [Int : Node]
    var root: BinaryNode?
    
    init(lexer: Lexer) {
        self.lexer = lexer
        self.look = lexer.analyze()
        self.table = [:]
        self.root = nil
    }
    
    
    func move() {
        look = lexer.analyze()
    }
    
    
    func match(tag: Int) {
        if look.tag == tag {
            move()
        } else {
            fatalError("Bad match")
        }
    }
    
    
    func program() {
        root = Concatenation(left: node(), right: EOS())
    }
    
    
    private func node() -> Node {
        return or()
    }
    
    
    private func or() -> Node {
        var res = concatenation()
        
        while (!lexer.isEOS && look.tag == Tag.getOrTag() && look.tag != Tag.getTagOfCloseBrace()) {
            
            move()
            res = Or(left: res, right: concatenation())
        }
        
        return res
    }
    
    private func concatenation() -> Node {
        var res = literal()
        
        while (!lexer.isEOS && (look.tag == Tag.getConcatenationTag() || look.tag != Tag.getOrTag() && look.tag != Tag.getTagOfCloseBrace())) {
            
            if look.tag == Tag.getConcatenationTag() {
                move()
            }
            
            res = Concatenation(left: res, right: literal())
        }
        return res
    }
    
    func literal() -> Node {
        
        var res: Node? = nil
            
        if look.tag == Tag.getCaptureGroupTag() {
            
            guard let captureLook = look as? CaptureGroup else {
                fatalError("Cant convert token to CaptureGroup")
            }
            let num = captureLook.getNum()
            move()
            res = CaptureNode(child: or(), token: captureLook)
            match(tag: Tag.getTagOfCloseBrace())
            table[num] = res
        } else if look.tag == Tag.getGroupTag() {
            guard let groupLook = look as? Group else {
                fatalError("Cant convert token to CaptureGroup")
            }
            let num = groupLook.getNumber()
            guard let _ = table[num] else {
                fatalError("You have to define numeric capture group before using it")
            }
            res = GroupNode(token: look)
            move()
        } else if look.tag == Tag.getTagOfOpenBrace() {
            
            move()
            res = or()
            match(tag: Tag.getTagOfCloseBrace())
        } else {
            
            res = Literal(token: look)
            move()
        }
        if lexer.isEOS {
            
            guard let unwrappedRes = res else {
                fatalError("Cant unwrap node")
            }
            return unwrappedRes
        }
        if look.tag == Tag.getPositiveClosureTag() {
            
            guard let unwrappedRes = res else {
                fatalError("Cant unwrap node")
            }
            res = positiveClosure(of: unwrappedRes)
        }
        
        if look.tag == Tag.getRepeatExpressionTag() {
            
            guard let unwrappedRes = res else {
                fatalError("Cant unwrap node")
            }
            res = repeatExpresion(of: unwrappedRes)
        }
        
        guard let unwrappedRes = res else {
            fatalError()
        }
        return unwrappedRes
    }
    
    private func positiveClosure(of node: Node) -> Node {
        
        match(tag: Tag.getPositiveClosureTag())
        var tmp = PositiveClosure(targetNode: node)
        if lexer.isEOS {
            return tmp
        }
        if look.tag == Tag.getPositiveClosureTag() {
            tmp = repeatExpresion(of: tmp) as! PositiveClosure
        } else if look.tag == Tag.getRepeatExpressionTag() {
            tmp = repeatExpresion(of: tmp) as! PositiveClosure
        }
        
        
        return tmp
    }

    
    private func repeatExpresion(of node: Node) -> Node {
        
        guard let repeatLook = look as? TokenRepeat else {
            fatalError("Cant convert token to TokenRepeat")
        }
        move()
        var tmp = RepeatExpression(targetNode: node, token: repeatLook)
        
        if lexer.isEOS {
            return tmp
        }
        if look.tag == Tag.getPositiveClosureTag() {
            tmp = positiveClosure(of: tmp) as! RepeatExpression
        } else if look.tag == Tag.getRepeatExpressionTag() {
            tmp = repeatExpresion(of: tmp) as! RepeatExpression
        }
        
        return tmp
    }
    
}

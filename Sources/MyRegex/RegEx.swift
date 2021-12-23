//
//  File.swift
//  
//
//  Created by Ilya Buldin on 10.12.2021.
//

import Foundation


final class RegEx {
    
    private let regex: String
    private var nfa = NFA<String, String>(states: [], initState: "", acceptStates: [], ts: [], epsTs: [])
    var dfa = DFA<String, String>(alphabet: [], states: [], initState: "", acceptStates: [])
    private var isCompiled = false
    
    class CaptureGroupSearch {
        let captureGroups: [Int:Node]
        
        init(captureGroups: [Int:Node]) {
            self.captureGroups = captureGroups
        }
        
        
        public subscript (text: String, id: Int) -> String? {
            get {
                let formatter = STtoNFAFormatter()
                guard let value = captureGroups[id] else {
                    fatalError("There is no such id for capture group")
                }
                let captureNFA = formatter.makeNFA(rootOfSyntaxTree: value)
                let captureRegex = RegEx(nfa: captureNFA)
                return captureRegex.searchSubstring(inside: text)
            }
        }
    }
    
    var captureGroups: CaptureGroupSearch
    
    init(pattern regex: String) {
        self.regex = regex
        captureGroups = CaptureGroupSearch(captureGroups: [:])
    }
    
    private init(nfa: NFA<String, String>) {
        regex = ""
        self.nfa = nfa
        captureGroups = CaptureGroupSearch(captureGroups: nfa.captureGroups)
        let nfaToDfaFormatter = NFAtoDFAformatter(nfa: nfa)
        nfaToDfaFormatter.constructDFA()
        
        let minimizeFormatter = DFAtoMinDFAFormatter(dfa: nfaToDfaFormatter.dfa)
        dfa = minimizeFormatter.minimizeDFA()
        isCompiled = true
    }
    
    
    func compile() {
        let lexer = Lexer(withPattern: regex)
        let parser = Parser(lexer: lexer)
        parser.program()
        let stToNFAformatter = STtoNFAFormatter()
        nfa = stToNFAformatter.makeNFA(rootOfSyntaxTree: parser.root!)
//        print(parser.root!)
        captureGroups = CaptureGroupSearch(captureGroups: nfa.captureGroups)
        let nfaToDfaFormatter = NFAtoDFAformatter(nfa: nfa)
        nfaToDfaFormatter.constructDFA()
        
        let minimizeFormatter = DFAtoMinDFAFormatter(dfa: nfaToDfaFormatter.dfa)
        dfa = minimizeFormatter.minimizeDFA()
        
        isCompiled = true
    }
    
    func searchSubstring(inside text: String) -> String? {
        if !isCompiled {
            compile()
        }
        
        var result = ""
        
        
        for posStart in text.indices {
            let dfaCopy = dfa.copy()
            let attempText = text[posStart..<text.endIndex]
            for index in attempText.indices {
                result += String(attempText[index])
                var status: AutomataStatus? = .common
                status = dfaCopy.transit(with: String(attempText[index]))
                guard let status = status else {
                    break
                }
                let newCopy = dfaCopy.copy()
                if status == .acceptable {
                    let nextIndex = attempText.index(after: index)
                    if hasAcceptableStateFurther(inside: text, from: nextIndex, dfa: newCopy) {
                        continue
                    }
                    return result
                }
            }
            result = ""
        }
        
        return nil
    }
    
    func hasAcceptableStateFurther(inside text: String,
                                   from startIndex: String.Index,
                                   dfa: DFA<String, String>) -> Bool {
        
        for symbol in text[startIndex..<text.endIndex] {
            let status = dfa.transit(with: String(symbol))
            if status == .acceptable {
                return true
            }
        }
        return false
    }
    
    
    func inverseLang() -> RegEx {
        if !isCompiled {
            compile()
        }
        
        let lexer = Lexer(withPattern: regex)
        let parser = Parser(lexer: lexer)
        parser.program()
        let stToNfaFormatter = STtoNFAFormatter()
        parser.root!.inverse()
        let inversedNfa = stToNfaFormatter.makeNFA(rootOfSyntaxTree: parser.root!.rightNode)
        inversedNfa.printNFAinfo()
        let newRegEx = RegEx(nfa: inversedNfa)
        
        return newRegEx
    }
    
    
    func intersection(with otherRegEx: RegEx) -> RegEx {
        let resultDFA = DFA<String, String>(alphabet: [], states: [], initState: "", acceptStates: [])
        
        if !isCompiled {
            compile()
        }
        
        if !otherRegEx.isCompiled {
            otherRegEx.compile()
        }
        
        
        let startState = "[\(dfa.initState), %^^%\(otherRegEx.dfa.initState)%^^%]"
        resultDFA.initState = startState
        resultDFA.currentState = startState
        
        for state in dfa.states {
            for otherDfaState in otherRegEx.dfa.states {
                let newState = "[\(state), %^^%\(otherDfaState)%^^%]"
                resultDFA.states.insert(newState)
                
                for symbol in dfa.alphabet {
                    let destionation = dfa.nextState(from: state, by: symbol)
                    let otherDfaDestination = otherRegEx.dfa.nextState(from: otherDfaState, by: symbol)
                    let resultDestination = "[\(destionation), %^^%\(otherDfaDestination)%^^%]"
                    resultDFA.addDefaultTransition(from: newState, for: symbol, to: resultDestination)
                }
            }
        }
        
        
        for state in resultDFA.states {
            for acceptState in dfa.acceptStates {
                for otherDfaAcceptState in otherRegEx.dfa.acceptStates {
                    if state.contains(acceptState) && state.contains("%^^%\(otherDfaAcceptState)%^^%") {
                        resultDFA.acceptStates.insert(state)
                    }
                }
            }
        }
        
        let resultRegEx = RegEx(pattern: "")
        resultRegEx.dfa = resultDFA
        resultRegEx.isCompiled = true
        
        return resultRegEx
    }
    
    func restore() -> String {
        if !isCompiled {
            compile()
        }
        
        let formatter = DFAtoRegexFormatter(dfa: dfa)
        return formatter.restoreRegex()
    }
    
}

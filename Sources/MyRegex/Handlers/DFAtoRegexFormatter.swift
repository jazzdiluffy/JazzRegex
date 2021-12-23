//
//  DFAtoRegexFormatter.swift
//  
//
//  Created by Ilya Buldin on 08.12.2021.
//

import Foundation


final class DFAtoRegexFormatter {
    
    var dfa = DFA<String, String>(alphabet: [], states: [], initState: "", acceptStates: [])
    
    var arrayOfPair: [(start: String, accept: String)] = []
    
    init(dfa: DFA<String, String>) {
        self.dfa = dfa
        self.dfa.currentState = dfa.initState
    }
    
    
    func getStartAcceptablePair() -> [(start: String, accept: String)] {
        var result: [(start: String, accept: String)] = []
        
        for acceptState in dfa.acceptStates {
            result.append(
                (start: dfa.initState, accept: acceptState))
        }
        
        return result
    }
    
    // returns a set of states from which we can transit into observable state
    func findFromStates(state: String, inputDFA: DFA<String, String>) -> Set<String> {
        var resultSet: Set<String> = []
        
        for st in inputDFA.states {
            for symbol in inputDFA.alphabet {
                if inputDFA.transitions[st, symbol] == state {
                    resultSet.insert(st)
                }
            }
        }
        
        return resultSet
    }
    
    
    // returns a set of states to which we can transit from observable state
    func findToStates(state: String, inputDFA: DFA<String, String>) -> Set<String> {
        var resultSet: Set<String> = []
        
        for st in inputDFA.states {
            for symbol in inputDFA.alphabet {
                if inputDFA.transitions[state, symbol] == st {
                    resultSet.insert(st)
                }
            }
        }
        
        return resultSet
    }
    
    
    // it could be situation like: s->q by 0 and s->q by 1
    // so this method handle this situation and make new transition: s->q by 0|1
    func shrinkTransitionsToOne(stateQ: String,
                                stateP: String,
                                inputDFA: DFA<String, String>) -> (from: String, by: String, to: String)? {
        var shrinkCondition = ""
        var conditions: [String] = []
        
        for symbol in inputDFA.alphabet {
            if inputDFA.transitions[stateQ, symbol] == stateP {
                conditions.append(symbol)
            } else if inputDFA.defaultTransitions[stateQ, symbol] == stateP {
                conditions.append(symbol)
            }
        }
        
        for i in conditions.indices {
            shrinkCondition += conditions[i]
            if !(i == conditions.endIndex - 1) {
                shrinkCondition += "|"
            }
        }
        
        
        
        return conditions.isEmpty ? nil : (from: stateQ, by: shrinkCondition, to: stateP)
    }
    
    
    
    // Returns new dfa after elimination of one state
    // replaces transitions using rule: R|QS*P
    func eliminate(state: String, inputDFA: DFA<String, String>, lastAlphabet: [String]) -> (dfa: DFA<String, String>, alphabet: [String]) {
        let resultDFA = inputDFA.copy()
        var newTransitions: [(from: String, by: String, to: String)] = []
        var newAlphabet: [String] = lastAlphabet
        
        
        let qSet = findFromStates(state: state, inputDFA: inputDFA)
        let pSet = findToStates(state: state, inputDFA: inputDFA)
//        var tmpSymbols: [String] = []
//        for accept in inputDFA.acceptStates {
//            if let shrinked = shrinkTransitionsToOne(stateQ: inputDFA.initState, stateP: accept, inputDFA: inputDFA) {
//                for i in inputDFA.transitions.keys.indices {
//                    let pair = inputDFA.transitions.keys[i]
//                    if let findedState = inputDFA.transitions[pair.x, pair.y] {
//                        if findedState == accept {
//                            resultDFA.transitions.stored.removeValue(forKey: MyPair(x: pair.x, y: pair.y).hashValue)
//                            resultDFA.transitions.storedKeys.remove(MyPair(x: pair.x, y: pair.y))
//                        }
//                    }
//                }
//                tmpSymbols.append(shrinked.by)
////                newAlphabet.append(shrinked.by)
////                resultDFA.alphabet.insert(shrinked.by)
//                newTransitions.append(shrinked)
//            }
//        }
        
        for q in qSet {
            for p in pSet {
                let qsTransitionConfig = shrinkTransitionsToOne(stateQ: q, stateP: state, inputDFA: inputDFA)!
                let qsTransition = (q: qsTransitionConfig.from, symbol: qsTransitionConfig.by, s: qsTransitionConfig.to)
                
                let spTransitionConfig = shrinkTransitionsToOne(stateQ: state, stateP: p, inputDFA: inputDFA)!
                let spTransition = (s: spTransitionConfig.from, symbol: spTransitionConfig.by, p: spTransitionConfig.to)
                
                let qpTransitionConfig = shrinkTransitionsToOne(stateQ: q, stateP: p, inputDFA: inputDFA)
                let qpTransition = qpTransitionConfig != nil ? (q: qpTransitionConfig!.from, symbol: qpTransitionConfig!.by, p: qpTransitionConfig!.to) : nil
                
                let ssTransitionConfig = shrinkTransitionsToOne(stateQ: state, stateP: state, inputDFA: inputDFA)
                let ssTransition =  ssTransitionConfig != nil ? (s1: ssTransitionConfig!.from, symbol: ssTransitionConfig!.by, s2: ssTransitionConfig!.to) : nil
                
                let newTransition = formNewTransition(qsTransition: qsTransition,
                                                     spTransition: spTransition,
                                                     qpTransition: qpTransition,
                                                     ssTransition: ssTransition)
                newTransitions.append(newTransition)
                
                newAlphabet.append(newTransition.by)
                resultDFA.alphabet.insert(newTransition.by)
            }
        }
        
        for i in inputDFA.transitions.keys.indices {
            let pair = inputDFA.transitions.keys[i]
            if let findedState = inputDFA.transitions[pair.x, pair.y] {
                if findedState == state   {
                    resultDFA.transitions.stored.removeValue(forKey: MyPair(x: pair.x, y: pair.y).hashValue)
                    resultDFA.transitions.storedKeys.remove(MyPair(x: pair.x, y: pair.y))
                }
            }
            if let findedState = inputDFA.defaultTransitions[pair.x, pair.y] {
                if findedState == state   {
                    resultDFA.defaultTransitions.stored.removeValue(forKey: MyPair(x: pair.x, y: pair.y).hashValue)
                    resultDFA.defaultTransitions.storedKeys.remove(MyPair(x: pair.x, y: pair.y))
                }
            }
        }
        
        for newTransition in newTransitions {
            resultDFA.addTransition(from: newTransition.from, for: newTransition.by, to: newTransition.to)
        }
        
        resultDFA.states.remove(state)
        resultDFA.acceptStates.remove(state)
        
        
        return (dfa: resultDFA, alphabet: newAlphabet)
    }
    
    
    
    // returns one transition like: R|QS*P
    func formNewTransition(qsTransition: (q: String, symbol: String, s: String),
                           spTransition: (s: String, symbol: String, p: String),
                           qpTransition: (q: String, symbol: String, p: String)?,
                           ssTransition: (s1: String, symbol: String, s2: String)?) -> (from: String, by: String, to: String) {
        var newTransitionCondition = ""
        var secondPartOfCondition = ""
        secondPartOfCondition += qsTransition.symbol
        if let kleneeValue = ssTransition?.symbol {
            secondPartOfCondition += "(\(kleneeValue))*"
        }
        secondPartOfCondition += spTransition.symbol
        
        guard let qpTransition = qpTransition else {
            return (from: qsTransition.q, by: secondPartOfCondition, to: spTransition.p)
        }
        
        if qpTransition.symbol.contains("|") {
            newTransitionCondition += "(\(qpTransition.symbol))|\(secondPartOfCondition)"
        } else {
            newTransitionCondition += "\(qpTransition.symbol)|\(secondPartOfCondition)"
        }
        
        
        return (from: qsTransition.q, by: newTransitionCondition, to: spTransition.p)
    }
    
    
    // Returns regex like: (R|SU*T)*SU* or (R)*
    func getRegexAfterEliminationOfOtherStates(with pair: (start: String, accept: String)) -> String {
        var result = ""
        
        var statesToDelete = Array<String>(dfa.states.subtracting([pair.start, pair.accept]))
        statesToDelete.sort {
            !dfa.acceptStates.contains($0) && dfa.acceptStates.contains($1)
        }
        
        
        
        var tmpDFA = dfa.copy()
//        var lastAlphabet: [String] = Array<String>(dfa.alphabet)
        var lastAlphabet: [String] = []
        
        for state in statesToDelete {
            var a = 1
            (tmpDFA, lastAlphabet) = eliminate(state: state, inputDFA: tmpDFA, lastAlphabet: lastAlphabet)
            let b = 2
            a = b
        }
        

        
        if tmpDFA.states.count == 2 {
            var regexConfig: [String: String] = [:]
            
            // check R
            for rule in lastAlphabet {        
                if let finded = tmpDFA.transitions[pair.start, rule], finded == pair.start {
                    regexConfig["R"] = rule
                }
                
            }
            
            // check S
            for rule in lastAlphabet {
                if let finded = tmpDFA.transitions[pair.start, rule], finded == pair.accept {
                    regexConfig["S"] = rule
                }
            }
            
            // check U
            for rule in lastAlphabet {
                if let finded = tmpDFA.transitions[pair.accept, rule], finded == pair.accept {
                    regexConfig["U"] = rule
                }
            }
            
            // check T
            for rule in lastAlphabet {
                if let finded = tmpDFA.transitions[pair.accept, rule], finded == pair.start {
                    regexConfig["T"] = rule
                }
            }
            // (R|SU*T)*SR*
            if let rRule = regexConfig["R"], let sRule = regexConfig["S"], let uRule = regexConfig["U"],
               let tRule = regexConfig["T"] {
                var (r, s, u, t) = (rRule, sRule, uRule, tRule)
                if rRule.contains("|") {
                    r = "(\(rRule))"
                }
                if sRule.contains("|") {
                    s = "(\(sRule))"
                }
                if tRule.contains("|") {
                    t =  "(\(tRule))"
                }
                result = "(\(r)|\(s)(\(u))*\(t))*\(s)(\(u))*"
                // (R|SU*T)*SU*
            } else if !regexConfig.keys.contains("R"), let sRule = regexConfig["S"], let uRule = regexConfig["U"],
                      let tRule = regexConfig["T"] {
                var (s, u, t) = (sRule, uRule, tRule)
                if sRule.contains("|") {
                    s = "(\(sRule))"
                }
                if tRule.contains("|") {
                    t =  "(\(tRule))"
                }
                result = "(\(s)(\(u))*\(t))*\(s)"
            
            } else if let rRule = regexConfig["R"], !regexConfig.keys.contains("S"), let uRule = regexConfig["U"],
                      let tRule = regexConfig["T"] {
                var (r, u, t) = (rRule, uRule, tRule)
                if rRule.contains("|") {
                    r = "(\(rRule))"
                }
                if tRule.contains("|") {
                    t =  "(\(tRule))"
                }
                result = "(\(r)|(\(u))*\(t))*(\(u))*"
                result = "lol6"
            } else if let rRule = regexConfig["R"], let sRule = regexConfig["S"], !regexConfig.keys.contains("U") ,
                      let tRule = regexConfig["T"] {
                var (r, s, t) = (rRule, sRule, tRule)
                if rRule.contains("|") {
                    r = "(\(rRule))"
                }
                if sRule.contains("|") {
                    s = "(\(sRule))"
                }
                if tRule.contains("|") {
                    t =  "(\(tRule))"
                }
                result = "(\(r)|\(s)\(t))*\(s)"
            } else if let rRule = regexConfig["R"], let sRule = regexConfig["S"], let uRule = regexConfig["U"], !regexConfig.keys.contains("T") {
                var (r, s, u) = (rRule, sRule, uRule)
                if rRule.contains("|") {
                    r = "(\(rRule))"
                }
                if sRule.contains("|") {
                    s = "(\(sRule))"
                }
                result = "(\(r))*\(s)(\(u))*"
            } else if let rRule = regexConfig["R"], let sRule = regexConfig["S"], !regexConfig.keys.contains("U"), !regexConfig.keys.contains("T") {
                var r = rRule
                var s = sRule
                if rRule.contains("|") {
                    r = "(\(rRule))"
                }
                if sRule.contains("|") {
                    s = "(\(sRule))"
                }
                result = "(\(r))*\(s)"
            
            } else if let rRule = regexConfig["R"], !regexConfig.keys.contains("S"), let uRule = regexConfig["U"], !regexConfig.keys.contains("T") {
                var r = rRule
                let u = uRule
                if rRule.contains("|") {
                    r = "(\(rRule))"
                }
                result = "(\(r)|(\(u))*)*(\(u))*"
                result = "lol5"
            } else if let rRule = regexConfig["R"], !regexConfig.keys.contains("S"), !regexConfig.keys.contains("U"), let tRule = regexConfig["T"] {
                var r = rRule
                var t = tRule

                if rRule.contains("|") {
                    r = "(\(rRule))"
                }
                if tRule.contains("|") {
                    t = "(\(tRule))"
                }
                result = "(\(r)|\(t))*(\(r))*"
                result = "lol4"
            } else if !regexConfig.keys.contains("R"), let sRule = regexConfig["S"],  let uRule = regexConfig["U"], !regexConfig.keys.contains("T") {
                var s = sRule
                let u = uRule
                if sRule.contains("|") {
                    s = "(\(sRule))"
                }
                result = "\(s)(\(u))*"
            } else if !regexConfig.keys.contains("R"), let sRule = regexConfig["S"], !regexConfig.keys.contains("U"), let tRule = regexConfig["T"] {
                var s = sRule
                var t = tRule
                if sRule.contains("|") {
                    s = "(\(sRule))"
                }
                if tRule.contains("|") {
                    t = "(\(tRule))"
                }
                result = "\(s)"
            } else if !regexConfig.keys.contains("R"), !regexConfig.keys.contains("S"), let uRule = regexConfig["U"], let tRule = regexConfig["T"] {
                let u = uRule
                var t = tRule
                if tRule.contains("|") {
                    t = "(\(tRule))"
                }
                result = "((\(u))*\(t))*"
                result = "lol3"
            } else if let rRule = regexConfig["R"], !regexConfig.keys.contains("S"), !regexConfig.keys.contains("U"), !regexConfig.keys.contains("T") {
                let r = rRule
                result = "(\(r))*"
                result = "lol2"
            } else if !regexConfig.keys.contains("R"), let sRule = regexConfig["S"], !regexConfig.keys.contains("U"), !regexConfig.keys.contains("T") {
                let s = sRule
                result = "\(s)"
            } else if !regexConfig.keys.contains("R"), !regexConfig.keys.contains("S"), let uRule = regexConfig["U"], !regexConfig.keys.contains("T") {
                let u = uRule
 
                result = "(\(u))*"
            }
            else if !regexConfig.keys.contains("R"), !regexConfig.keys.contains("S"), !regexConfig.keys.contains("U"), let tRule = regexConfig["T"] {
                let t = tRule
                result = "(\(t))*"
                result = "lol1"
            }
        } else if tmpDFA.states.count == 1 {
            for rule in lastAlphabet {
                if let finded = tmpDFA.transitions[pair.start, rule], finded == pair.start {
                    result = "(\(rule))*"
                }
            }
        } else {
            fatalError("[DEBUG] Got something wrong, check algorithm")
        }
        
        return result
    }
    
    func restoreRegex() -> String {
        var result = ""
        var regexesFromEveryPair: [String] = []
        let pairs = getStartAcceptablePair()
        for pair in pairs {
            regexesFromEveryPair.append(getRegexAfterEliminationOfOtherStates(with: pair))
        }
        
        for regexIndex in regexesFromEveryPair.indices {
            let regexToAdd = regexesFromEveryPair[regexIndex]
            result += "(" + regexToAdd + ")"
            if regexIndex != regexesFromEveryPair.endIndex - 1 {
                result += "|"
            }
        }
        
        return result
    }
    
}

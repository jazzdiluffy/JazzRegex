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
    func eliminate(state: String, inputDFA: DFA<String, String>) -> (dfa: DFA<String, String>, alphabet: [String]) {
        let resultDFA = inputDFA.copy()
        var newTransitions: [(from: String, by: String, to: String)] = []
        var newAlphabet: [String] = []
        
        
        let qSet = findFromStates(state: state, inputDFA: inputDFA)
        let pSet = findToStates(state: state, inputDFA: inputDFA)
        
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
                if findedState == state || pSet.contains(findedState) {
                    resultDFA.transitions.stored.removeValue(forKey: MyPair(x: pair.x, y: pair.y).hashValue)
                    resultDFA.transitions.storedKeys.remove(MyPair(x: pair.x, y: pair.y))
                }
            }
            if let findedState = inputDFA.defaultTransitions[pair.x, pair.y] {
                if findedState == state || pSet.contains(findedState) {
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
        
        newTransitionCondition += "\(qpTransition.symbol)|\(secondPartOfCondition)"
        
        return (from: qsTransition.q, by: newTransitionCondition, to: spTransition.p)
    }
    
    
    // Returns regex like: (R|SU*T)
    func getRegexAfterEliminationOfOtherStates(with pair: (start: String, accept: String)) -> String {
        var result = ""
        
        let statesToDelete = dfa.states.subtracting([pair.start, pair.accept])
        var tmpDFA = dfa.copy()
        var lastAlphabet: [String] = []
        for state in statesToDelete {
            (tmpDFA, lastAlphabet) = eliminate(state: state, inputDFA: tmpDFA)
        }
        
        var firstPartResult = ""
        var secondPartResult = ""
        
        if tmpDFA.states.count == 2 {
            // check R
            for rule in lastAlphabet {
                if let finded = tmpDFA.transitions[pair.start, rule], finded == pair.start {
                    firstPartResult += "((\(rule))"
                }
            }
            
            // check S
            for rule in lastAlphabet {
                if let finded = tmpDFA.transitions[pair.start, rule], finded == pair.accept {
                    firstPartResult += "|(\(rule))"
                    secondPartResult += "(\(rule))"
                }
            }
            
            // check U
            for rule in lastAlphabet {
                if let finded = tmpDFA.transitions[pair.accept, rule], finded == pair.accept {
                    if firstPartResult.contains("|") {
                        firstPartResult += "(\(rule))*"
                    } else {
                        firstPartResult += "|(\(rule))*"
                    }
                    secondPartResult += "(\(rule))*"
                }
            }
            
            // check T
            for rule in lastAlphabet {
                if let finded = tmpDFA.transitions[pair.accept, rule], finded == pair.start {
                    if firstPartResult.contains("|") {
                        firstPartResult += "(\(rule)))*"
                    } else {
                        firstPartResult += "|(\(rule)))*"
                    }
                }
            }
            
            result = "\(firstPartResult)\(secondPartResult)"
        } else if tmpDFA.states.count == 1 {
            for rule in lastAlphabet {
                if let finded = tmpDFA.transitions[pair.start, rule], finded == pair.accept {
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
            result += regexToAdd
            if regexIndex != regexesFromEveryPair.endIndex - 1 {
                result += "|"
            }
        }
        
        return result
    }
    
}

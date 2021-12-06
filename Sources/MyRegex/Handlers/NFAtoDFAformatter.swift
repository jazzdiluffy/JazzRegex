//
//  File.swift
//  
//
//  Created by Ilya Buldin on 25.11.2021.
//

import Foundation


final class NFAtoDFAformatter {
    
    let nfa: NFA<String, String>
    
    var alphabet: Set<String> = []
    
    var statesRep: [String:Set<String>] = [:]
    
    var subsetOfHandledStates: Set<String> = []
    
    var states: Set<String> = []
    
    var stateIndex = 0
    
    let dfa = DFA<String, String>(alphabet: [], states: [], initState: "", acceptStates: [])
    
    init(nfa: NFA<String, String>) {
        self.nfa = nfa
    }
    
    func getStartState() {
        let startStateSet = nfa.epsClosureHandlerForState(state: nfa.initState)
        let dfaInitState = "S\(stateIndex)"
        statesRep[dfaInitState] = startStateSet
        states.insert(dfaInitState)
        dfa.initState = dfaInitState
        dfa.currentState = dfaInitState
        dfa.states.insert(dfaInitState)
    }
    
    func getAlphabetFromNFA() {
        nfa.transitions.keys.forEach { pair in
            alphabet.insert(pair.y)
        }
        
        dfa.alphabet = alphabet
    }
    
    func handleStates() {
        for state in states {
            guard !subsetOfHandledStates.contains(state), let stateRep = statesRep[state] else {
                continue
            }
            
            for symbol in alphabet {
                let statesReachableBySymbol = nfa.getStatesSet(from: stateRep, by: symbol)
                let epsClosure = nfa.epsClosureHandlerForStatesSet(states: statesReachableBySymbol)
                guard let findedState = checkIfStateIsAPartOfDFAStatesSet(checkStateSet: epsClosure) else {
                    stateIndex += 1
                    let newDFAState = "S\(stateIndex)"
                    states.insert(newDFAState)
                    statesRep[newDFAState] = epsClosure
                    dfa.states.insert(newDFAState)
                    dfa.addTransition(from: state, for: symbol, to: newDFAState)
                    continue
                }
                dfa.addTransition(from: state, for: symbol, to: findedState)
                
            }
            subsetOfHandledStates.insert(state)
            handleStates()
        }
    }
    
    func checkIfStateIsAPartOfDFAStatesSet(checkStateSet: Set<String>) -> String? {
        for state in states {
            guard let stateRep = statesRep[state] else {
                fatalError("[DEBUG]: States and statesRep have different members")
            }
            if checkStateSet == stateRep {
                return state
            }
        }
        return nil
    }
    
    func setAcceptStates() {
        for (key, value) in statesRep {
            if !value.isDisjoint(with: nfa.acceptStates) {
                dfa.acceptStates.insert(key)
            }
        }
    }
    
    func constructDFA() {
        getStartState()
        
        getAlphabetFromNFA()
        handleStates()
        setAcceptStates()
        
    }
}

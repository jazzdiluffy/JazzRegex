//
//  File.swift
//  
//
//  Created by Ilya Buldin on 06.12.2021.
//

import Foundation


final class DFAtoMinDFAFormatter {
    var dfa = DFA<String, String>(alphabet: [], states: [], initState: "", acceptStates: [])
    
    var minDFA = DFA<String, String>(alphabet: [], states: [], initState: "", acceptStates: [])
    
    
    init(dfa: DFA<String, String>) {
        self.dfa = dfa
    }
    

    func minimizeDFA() -> DFA<String, String> {
        var resultPiSplit: [Set<String>] = makeStartPiSplit()
        var tmpSplit = makeNewPiSplit(previous: resultPiSplit)
        while tmpSplit != resultPiSplit {
            resultPiSplit = tmpSplit
            tmpSplit = makeNewPiSplit(previous: resultPiSplit)
        }
         return constructDFA(from: resultPiSplit)
    }
    
    func findToWhichStateTransitionIsNedeed(from state: String, by symbol: String, statesReps: [String:Set<String>]) -> String? {
        for (key, value) in statesReps {
            if value.contains(dfa.nextState(from: state, by: symbol)) {
                return key
            }
        }
        
        return nil
    }
    
    func constructDFA(from finalPiSplit: [Set<String>]) -> DFA<String, String> {
        let resultDFA = DFA<String, String>(alphabet: [], states: [], initState: "", acceptStates: [])
        var stateIndex = -1
        
        resultDFA.alphabet = dfa.alphabet
        var newStatesWithReps: [String:Set<String>] = [:]
        
        for statesSet in finalPiSplit {
            stateIndex += 1
            let newStateName = "S\(stateIndex)"
            resultDFA.states.insert(newStateName)
            newStatesWithReps[newStateName] = statesSet
            if statesSet.contains(dfa.initState) {
                resultDFA.initState = newStateName
                resultDFA.currentState = newStateName
            } else if !statesSet.isDisjoint(with: dfa.acceptStates) {
                resultDFA.acceptStates.insert(newStateName)
            }
        }
        
        for state in newStatesWithReps.keys {
            for symbol in dfa.alphabet {
                guard let destination = self.findToWhichStateTransitionIsNedeed(from: state,
                                                                                by: symbol,
                                                                                statesReps: newStatesWithReps) else {
                    fatalError("Algorithm error")
                }
                resultDFA.addTransition(from: state, for: symbol, to: destination)
            }
        }
        
        return resultDFA
    }
    
    
    func makeStartPiSplit() -> [Set<String>] {
        let acceptable: Set<String> = dfa.acceptStates
        let notAcceptable: Set<String> = dfa.states.subtracting(dfa.acceptStates)
        
        return [acceptable, notAcceptable]
    }
    
    func makeNewPiSplit(previous piSplit: [Set<String>] ) -> [Set<String>] {
        var newPiSplit: [Set<String>] = [[]]
        
        for statesSet in piSplit {
            for state in statesSet {
                let tmpSet = statesSet.filter { _ in
                    for symbol in dfa.alphabet {
                        if (!belongToSameGroup(firstState: dfa.nextState(from: state, by: symbol), secondState: dfa.nextState(from: state, by: symbol), piSplit: piSplit)) {
                            return false
                        }
                    }
                    return true
                }
                if (!newPiSplit.contains(tmpSet)) {
                    newPiSplit.append(tmpSet)
                }
            }
        }
        
        return newPiSplit
    }
    
    func belongToSameGroup(firstState: String, secondState: String, piSplit: [Set<String>]) -> Bool {
        return findGroup(inputState: firstState, piSplit: piSplit) == findGroup(inputState: secondState, piSplit: piSplit)
    }
    
    func findGroup(inputState: String, piSplit: [Set<String>]) -> Set<String> {
        for statesSet in piSplit {
            if let _ = statesSet.first(where: { $0 == inputState }) {
                return statesSet
            }
        }
        return []
    }
    
    
}

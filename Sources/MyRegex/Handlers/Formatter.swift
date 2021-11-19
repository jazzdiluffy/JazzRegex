//
//  File.swift
//  
//
//  Created by Ilya Buldin on 13.11.2021.
//

import Foundation


final class STtoNFAFormatter {
    
    private var stateName = 0
    
    init() {
        
    }
    
    func handleLiteralNode(with node: Literal) -> NFA<String, String> {
        self.stateName += 1
        let initState = String(stateName)
        self.stateName += 1
        let acceptState = String(stateName)
        let acceptStateSet: Set<String> = [acceptState]
        let nfaStates: Set<String> = [initState, acceptState]
        let symbol = String(UnicodeScalar(UInt8(node.token.tag)))
        let transitions = [
            (initState, symbol, acceptState)
        ]
        
        let nfa = NFA<String, String>(states: nfaStates, initState: initState, acceptStates: acceptStateSet, ts: transitions, epsTs: [])
        
        return nfa
    }
    
    func handleEpsilonNode(with node: Literal) -> NFA<String, String> {
        guard node.token.tag == 94 else {
            fatalError("It is not epsilon type")
        }
        self.stateName += 1
        let initState = String(stateName)
        stateName += 1
        let acceptState = String(stateName)
        let acceptStateSet: Set<String> = [
            acceptState
        ]
        let states: Set<String> = [
            initState,
            acceptState
        ]
        let epsTransitions = [
            (initState, acceptState)
        ]
        
        let nfa = NFA<String, String>(states: states, initState: initState, acceptStates: acceptStateSet, ts: [], epsTs: epsTransitions)
        return nfa
    }
    
    func handleOrNode(firstNFA: NFA<String, String>, secondNFA: NFA<String, String>) -> NFA<String, String> {
        stateName += 1
        let initState = String(stateName)
        stateName += 1
        let acceptState = String(stateName)
        let acceptStateSet: Set<String> = [
            acceptState
        ]
        let firstNFAinitState = firstNFA.initState
        guard let firstNFAacceptState = firstNFA.acceptStates.first else {
            fatalError("no accept state in first NFA")
        }
        
        let secondNFAinitState = secondNFA.initState
        guard let secondNFAacceptState = secondNFA.acceptStates.first else {
            fatalError("no accept state in second NFA")
        }
        
        let newStates: Set<String> = [
            initState,
            acceptState
        ]
        let allStates = newStates.union(firstNFA.states).union(secondNFA.states)
        
    
        let firstNFAtransitions = firstNFA.transitions
        let secondNFAtransitions = secondNFA.transitions
        
        let firstNFAepsTransitions = firstNFA.epsilonTransitions
        let secondNFAepsTransitions = secondNFA.epsilonTransitions
        
        let newEpsTransitions = [
            (initState, firstNFAinitState),
            (initState, secondNFAinitState),
            (firstNFAacceptState, acceptState),
            (secondNFAacceptState, acceptState)
        ]
        
        let nfa = NFA<String, String>(states: allStates, initState: initState, acceptStates: acceptStateSet, ts: [], epsTs: newEpsTransitions)
        firstNFAtransitions.stored.forEach { (key, value) in
            nfa.transitions.stored[key] = value
        }
        nfa.transitions.storedKeys = nfa.transitions.storedKeys.union(firstNFAtransitions.storedKeys)
        
        secondNFAtransitions.stored.forEach { (key, value) in
            nfa.transitions.stored[key] = value
        }
        nfa.transitions.storedKeys = nfa.transitions.storedKeys.union(secondNFAtransitions.storedKeys)
        
        firstNFAepsTransitions.forEach { (key, value) in
            nfa.epsilonTransitions[key] = value
        }
        
        secondNFAepsTransitions.forEach { (key, value) in
            nfa.epsilonTransitions[key] = value
        }
        
        return nfa
    }
    
    func handleAndNode(firstNFA: NFA<String, String>, secondNFA: NFA<String, String>) -> NFA<String, String> {
        let initState = firstNFA.initState
        guard let acceptState = secondNFA.acceptStates.first else {
            fatalError("no accept states in first nfa")
        }
        
        let acceptStateSet: Set<String> = [
            acceptState
        ]
        
        var states = firstNFA.states.union(secondNFA.states)
        guard let firstNFAacceptState = firstNFA.acceptStates.first else {
            fatalError("no accept states in first nfa")
        }
        
        states = states.subtracting([firstNFAacceptState]).subtracting([secondNFA.initState])
        let intersectionState = firstNFAacceptState + "_" + secondNFA.initState
        states = states.union([intersectionState])
        
        let nfa = NFA<String, String>(states: states, initState: initState, acceptStates: acceptStateSet, ts: [], epsTs: [])
        
        let firstNFAtransitions = firstNFA.transitions
        let secondNFAtransitions = secondNFA.transitions
        
        let firstNFAepsTransitions = firstNFA.epsilonTransitions
        let secondNFAepsTransitions = secondNFA.epsilonTransitions
        
        firstNFAtransitions.stored.forEach { (key, value) in
            nfa.transitions.stored[key] = value
        }
        nfa.transitions.storedKeys = nfa.transitions.storedKeys.union(firstNFAtransitions.storedKeys)
        
        for key in firstNFAtransitions.keys {
            guard let brokenTransition = firstNFAtransitions[key.x, key.y] else {
                fatalError("cant get broken transition")
            }
            if brokenTransition.first! == firstNFAacceptState {
                nfa.transitions.storedKeys = nfa.transitions.storedKeys.subtracting([MyPair(x: key.x, y: key.y)])
                nfa.transitions.stored.removeValue(forKey: MyPair(x: key.x, y: key.y).hashValue)
                nfa.transitions[key.x, key.y] = [intersectionState]
            }
        }
        
        secondNFAtransitions.stored.forEach { (key, value) in
            nfa.transitions.stored[key] = value
        }
        nfa.transitions.storedKeys = nfa.transitions.storedKeys.union(secondNFAtransitions.storedKeys)
        
        for key in secondNFAtransitions.keys {
            guard let brokenTransitions = secondNFAtransitions[key.x, key.y] else {
                fatalError("cant get broken transition")
            }
            
            print(brokenTransitions.first!)
            if key.x == secondNFA.initState {
                nfa.transitions.storedKeys = nfa.transitions.storedKeys.subtracting([MyPair(x: key.x, y: key.y)])
                nfa.transitions.stored.removeValue(forKey: MyPair(x: key.x, y: key.y).hashValue)
                nfa.transitions[intersectionState, key.y] = brokenTransitions
            }
        }
        
        let firstNFAstates = firstNFA.states
        for state in firstNFAstates {
            guard let stateEpsDestinations = firstNFAepsTransitions[state] else {
                continue
            }
            if stateEpsDestinations.contains(firstNFAacceptState) {
                nfa.epsilonTransitions[state] = stateEpsDestinations.subtracting([firstNFAacceptState]).union([intersectionState])
            } else {
                nfa.epsilonTransitions[state] = stateEpsDestinations
            }
        }
        
        let secondNFAstates = secondNFA.states
        for state in secondNFAstates {
            guard let stateEpsDestinations = secondNFAepsTransitions[state] else {
                continue
            }
            if state == secondNFA.initState {
                nfa.epsilonTransitions[intersectionState] = stateEpsDestinations
            } else {
                nfa.epsilonTransitions[state] = stateEpsDestinations
            }
        }
        
        return nfa
    }
    
}



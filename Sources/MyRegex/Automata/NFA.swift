//
//  File.swift
//  
//
//  Created by Ilya Buldin on 15.10.2021.
//

import Foundation

final public class NFA<State: Hashable, Symbol: Hashable>: Automata {
    
    // MARK: -Properties
    
    
    var states: Set<State>
    
    var initState: State
    
    var acceptStates: Set<State>
    
    var transitions: Table<State, Symbol, Set<State>>
    
    var epsilonTransitions: [State: Set<State>]
    
    var currentStates: Set<State>
    
    
    // MARK: -Init
    
    init(states: Set<State>,
         initState: State,
         acceptStates: Set<State>,
         ts: [(start: State, symbol: Symbol?, destination: State)],
         epsTs: [(start: State, destination: State)]) {
        
//        self.alphabet = alphabet
        self.states = states
        self.initState = initState
        self.acceptStates = acceptStates
        self.transitions = Table<State, Symbol, Set<State>>()
        self.epsilonTransitions = [:]
        self.currentStates = []
        
        self.addTransitions(ts: ts)
        self.addEpsilonTransitions(ts: epsTs)
        self.currentStates = epsClosureHandlerForState(state: initState)
    }
    
    // MARK: -Methods
    func epsClosureHandlerForState(state: State, visitedStates: Set<State> = []) -> Set<State> {
        guard let epsStates = self.epsilonTransitions[state] else {
            return [state]
        }
        
        
        var nvStates = visitedStates
        nvStates.insert(state)
        
        return epsClosureHandlerForStatesSet(states: epsStates.subtracting(nvStates), visitedStates: nvStates).union([state])
    }
    
    
    func epsClosureHandlerForStatesSet(states: Set<State>, visitedStates: Set<State> = []) -> Set<State> {
        var epsStates = Set<State>()
        for state in states {
            epsStates.formUnion(epsClosureHandlerForState(state: state))
        }
        
        return epsStates
    }
    
    func transit(with symbol: Symbol) -> AutomataStatus? {
        var targetStates = Set<State>()
        for state in self.currentStates {
            if let destinationStates = self.transitions[state, symbol] {
                targetStates.formUnion(destinationStates)
            }
        }
        currentStates = self.epsClosureHandlerForStatesSet(states: targetStates)
        if !(currentStates.isDisjoint(with: acceptStates)) {
            return .acceptable
        } else if !(currentStates.isEmpty) {
            return .common
        }
        return nil
    }
    
    func addTransition(from start: State, for symbol: Symbol?, to destination: State) {
        guard let symbol = symbol else {
            if let _ = self.epsilonTransitions[start] {
                self.epsilonTransitions[start]!.insert(destination)
            } else {
                self.epsilonTransitions[start] = [destination]
            }
            
            return
        }
        
        if let _ = self.transitions[start, symbol] {
            self.transitions[start, symbol]!.insert(destination)
        } else {
            self.transitions[start, symbol] = [destination]
        }
    }
    
    func addTransition(ts: (start: State, symbol: Symbol?, destination: State)) {
        self.addTransition(from: ts.start, for: ts.symbol, to: ts.destination)
    }
    
    func addEpsilonTransition(from start: State, to destination: State) {
        self.addTransition(from: start, for: nil, to: destination)
    }
    
    func addEpsilonTransitions(ts: [(start: State, destination: State)]) {
        for transition in ts {
            self.addTransition(from: transition.start, for: nil, to: transition.destination)
        }
    }
    
    func addTransitions(ts: [(start: State, symbol: Symbol?, destination: State)]) {
        for transition in ts {
            self.addTransition(from: transition.start,
                               for: transition.symbol,
                               to: transition.destination)
        }
    }
    
    func checkLine(line: String) -> Bool {
        var current: AutomataStatus? = nil
        for c in line {
            print("Before transition: \(self.currentStates)")
            guard let symbol = String(c) as? Symbol else {
                fatalError("Can't convert \(type(of: c)) to Type which conforms Hashable protocol")
            }
            
            current = self.transit(with: symbol)
            print("After transition: \(self.currentStates)")
        }
        print(current == .acceptable ? "Acceptable" : "Not acceptable")
        return current == .acceptable ? true : false
    }
    
    
    func printNFAinfo() {
        print("=====================")
        print("States: \(states)")
        print("---------------------")
        print("Init State: \(initState)")
        print("---------------------")
        print("Accept states: \(acceptStates)")
        print("---------------------")
        print("Transitions: \n")
        var result = ""
        for (start, symbol) in self.transitions.keys {
            guard let destination = self.transitions[start, symbol] else {
                fatalError("Table Error: can't get access to value by corrent key!")
            }
            result += "\(start) --> \(destination)  { by symbol: \(symbol) } "
            result += "\n"
        }
        print(result)
        result = ""
        print("Epsilon transitions: \n")
        for start in self.epsilonTransitions.keys {
            guard let destination = self.epsilonTransitions[start] else {
                fatalError("Table Error: can't get access to value by corrent key!")
            }
            result += "\(start) --> \(destination)"
            result += "\n"
        }
        print(result)
        print("=====================")
        
    }
}

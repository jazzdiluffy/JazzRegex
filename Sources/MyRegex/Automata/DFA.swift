//
//  File.swift
//  
//
//  Created by Ilya Buldin on 15.10.2021.
//

import Foundation

final public class DFA<State: Hashable, Symbol: Hashable>: Automata {
    // MARK: -Properties
    var alphabet: Set<Symbol>
    
    var states: Set<State>
    
    var initState: State
    
    var acceptStates: Set<State>
    
    var transitions: Table<State, Symbol, State>
    
    var defaultTransitions: Table<State, Symbol, State>
    
    var currentState: State
    
    
    // MARK: -Init
    public init(alphabet: Set<Symbol>,
                states: Set<State>,
                initState: State,
                acceptStates: Set<State>,
                ts: [(start: State, symbol: Symbol, destination: State)],
                defaultTs: [(start: State, symbol: Symbol, defaultDestination: State)]) {
        
        self.alphabet = alphabet
        self.states = states
        self.initState = initState
        self.acceptStates = acceptStates
        self.transitions = Table<State, Symbol, State>()
        self.defaultTransitions = Table<State, Symbol, State>()
        self.currentState = initState
        
        self.addDefaultTransitions(ts: defaultTs)
        self.addTransitions(ts: ts)
        
        
    }
    
    convenience init(alphabet: Set<Symbol>,
                     states: Set<State>,
                     initState: State,
                     acceptStates: Set<State>) {
        
        self.init(alphabet: alphabet,
                  states: states, initState: initState,
                  acceptStates: acceptStates,
                  ts: [],
                  defaultTs: [])
        
    }
    
    
    // MARK: -Methods
    
    func transit(with symbol: Symbol) -> AutomataStatus? {
        guard let destination = self.transitions[self.currentState, symbol] else {
            guard let defaultDestination = self.defaultTransitions[self.currentState, symbol] else {
                print("You should define transition for symbol \"\(symbol)\"")
                fatalError("There is no defined transition for state - \"\(self.currentState)\"")
            }
            self.currentState = defaultDestination
            let status: AutomataStatus = self.acceptStates.contains(currentState) ? .acceptable : .common

            return status
        }
        self.currentState = destination
        let status: AutomataStatus = self.acceptStates.contains(currentState) ? .acceptable : .common

        return status
    }
    
    func nextState(from state: State, by symbol: Symbol) -> State {
        guard let destination = self.transitions[state, symbol] else {
            guard let defaultDestination = self.defaultTransitions[state, symbol] else {
                print("You should define transition for symbol \"\(symbol)\"")
                fatalError("There is no defined transition for state - \"\(self.currentState)\"")
            }

            return defaultDestination
        }
        return destination
    }
    
    
    // функции добавления переходов
    func addTransition(from start: State, for symbol: Symbol, to destination: State) {
        self.transitions[start, symbol] = destination
    }
    
    func addTransition(ts: (start: State, symbol: Symbol, destination: State)) {
        self.addTransition(from: ts.start, for: ts.symbol, to: ts.destination)
    }
    
    func addTransitions(ts: [(start: State, symbol: Symbol, destination: State)]) {
        for transition in ts {
            self.addTransition(ts: transition)
        }
    }
    
    // функции добавления плейсхолдеров для неопределенных переходов
    func addDefaultTransition(from start: State, for symbol: Symbol, to defaultDestination: State) {
        self.defaultTransitions[start, symbol] = defaultDestination
    }
    
    func addDefaultTransition(ts: (start: State, symbol: Symbol, defaultDestination: State)) {
        self.addDefaultTransition(from: ts.start, for: ts.symbol, to: ts.defaultDestination)
    }
    
    func addDefaultTransitions(ts: [(start: State, symbol: Symbol, defaultDestination: State)]) {
        for transition in ts {
            self.addDefaultTransition(ts: transition)
        }
    }
    
    private func printTransition(symbol: Symbol) {
        guard let destination = self.transitions[self.currentState, symbol] else {
            guard let defaultDestination = self.defaultTransitions[self.currentState, symbol] else {
                print("You should define transition for symbol \"\(symbol)\"")
                fatalError("There is no defined transition for state - \"\(self.currentState)\"")
                
            }
            
            let status: AutomataStatus = self.acceptStates.contains(defaultDestination) ? .acceptable : .common
            print("\(currentState) -> \(defaultDestination) {symbol: \(symbol)} (\(status.description))")
            self.currentState = defaultDestination
            
            return
        }
        
        let status: AutomataStatus = self.acceptStates.contains(destination) ? .acceptable : .common
        print("\(currentState) -> \(destination) {symbol: \(symbol)} (\(status.description))")
        self.currentState = destination
         
    }
    
    func makeAllDefaultTransitionsGoToErrorState() {
        let errorState = "Error"
        guard let uwrappedErrorState = errorState as? State else {
            fatalError("Can't convert String \"\(errorState)\" to Hashable")
        }
        for c in alphabet {
            for state in states {
                self.addDefaultTransition(ts: (state, c, uwrappedErrorState))
            }
        }
    }
    
    func validateDFA() {
        if self.defaultTransitions.storedKeys.isEmpty && self.transitions.storedKeys.isEmpty {
            fatalError("DFA VALIDATION: There are no defined transitions!")
        }
        
        for state in states {
            for symbol in alphabet {
                guard self.transitions[state, symbol] != nil || self.defaultTransitions[state, symbol] != nil else {
                    print("You should define transition for symbol \"\(symbol)\"")
                    fatalError("There is no transitions for state - \"\(state)\"")
                }
            }
        }
    }
    
    public func printDFAWork(for line: String) {
        self.validateDFA()
        
        for c in line {
            guard let symbol = String(c) as? Symbol else {
                fatalError("Can't convert \(type(of: c)) to Type which conforms Hashable protocol")
            }
            printTransition(symbol: symbol)
        }
    }
    
    func checkLine(line: String) -> Bool {
        var current: AutomataStatus? = nil
        
        self.validateDFA()
        for c in line {
            guard let symbol = String(c) as? Symbol else {
                fatalError("Can't convert \(type(of: c)) to Type which conforms Hashable protocol")
            }
            current = self.transit(with: symbol)
        }
        return current == .acceptable ? true : false
    }
    
}


extension DFA: CustomStringConvertible {
    public var description: String {
        var result = ""
        
        for (start, symbol) in self.transitions.keys {
            guard let destination = self.transitions[start, symbol] else {
                fatalError("Table Error: can't get access to value by corrent key!")
            }
            result += "\(start) --> \(destination)  { by symbol: \(symbol) } "
            if self.acceptStates.contains(destination) {
                result += " (ACCEPTING)"
            } else {
                result += " (COMMON)"
            }
            result += "\n"
        }
        
        for (start, symbol) in self.defaultTransitions.keys {
            guard let destination = self.defaultTransitions[start, symbol] else {
                fatalError("Table Error: can't get access to value by corrent key!")
            }
            result += "\(start) --> \(destination)  { by symbol: \(symbol) } "
            if self.acceptStates.contains(destination) {
                result += " (ACCEPTING)"
            } else {
                result += " (COMMON)"
            }
            result += "\n"
        }
        
        return result
    }
}


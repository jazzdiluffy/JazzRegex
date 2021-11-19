//
//  File.swift
//  
//
//  Created by Ilya Buldin on 15.10.2021.
//

import Foundation

enum AutomataStatus {
    case common
    case acceptable
    
    var description: String {
        switch self {
        case .common:
            return "Automata Status is Common"
        default:
            return "Automata Status is Acceptable"
        }
    }
}

protocol Automata {
    associatedtype State: Hashable
    associatedtype Symbol: Hashable
    
    var initState: State { get set }
    var acceptStates: Set<State> { get set }
//    var alphabet: Set<Symbol> { get set }
    var states: Set<State> { get set }
    func transit(with symbol: Symbol) -> AutomataStatus?
}

//
//  File.swift
//  
//
//  Created by Ilya Buldin on 13.11.2021.
//

import Foundation


final class STtoNFAFormatter {
    
    private var stateName = 0
    
    var captureGroups: [Int : Node] = [:]
    
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
        nfa.currentStates = nfa.epsClosureHandlerForState(state: nfa.initState)
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
        
        nfa.currentStates = nfa.epsClosureHandlerForState(state: nfa.initState)
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
        nfa.currentStates = nfa.epsClosureHandlerForState(state: nfa.initState)
        return nfa
    }
    
    
    func handleAndNode(firstNFA: NFA<String, String>, secondNFA: NFA<String, String>) -> NFA<String, String> {
        let secondNFAcopy = NFA<String, String>(states: secondNFA.states, initState: secondNFA.initState, acceptStates: secondNFA.acceptStates, ts: [], epsTs: [])
        secondNFA.transitions.stored.forEach { (key, value) in
            secondNFAcopy.transitions.stored[key] = value
        }
        secondNFA.transitions.storedKeys.forEach {
            secondNFAcopy.transitions.storedKeys = secondNFAcopy.transitions.storedKeys.union([$0])
        }
        secondNFA.epsilonTransitions.forEach { (key, value) in
            secondNFAcopy.epsilonTransitions[key] = value
        }
        
        
        
        let firstNFAcopy = NFA<String, String>(states: firstNFA.states, initState: firstNFA.initState, acceptStates: firstNFA.acceptStates, ts: [], epsTs: [])
        firstNFA.transitions.stored.forEach { (key, value) in
            firstNFAcopy.transitions.stored[key] = value
        }
        firstNFA.transitions.storedKeys.forEach {
            firstNFAcopy.transitions.storedKeys = firstNFAcopy.transitions.storedKeys.union([$0])
        }
        firstNFA.epsilonTransitions.forEach { (key, value) in
            firstNFAcopy.epsilonTransitions[key] = value
        }
        
        let initState = firstNFAcopy.initState
        guard let acceptState = secondNFAcopy.acceptStates.first else {
            fatalError("no accept states in first nfa")
        }
        
        let acceptStateSet: Set<String> = [
            acceptState
        ]
        
        var states = firstNFAcopy.states.union(secondNFAcopy.states)
        guard let firstNFAacceptState = firstNFAcopy.acceptStates.first else {
            fatalError("no accept states in first nfa")
        }
        
        
        states = states.subtracting([firstNFAacceptState]).subtracting([secondNFAcopy.initState])
        
        
        let intersectionState = firstNFAacceptState + "_" + secondNFAcopy.initState
        
        states = states.union([intersectionState])
        
        let nfa = NFA<String, String>(states: states, initState: initState, acceptStates: acceptStateSet, ts: [], epsTs: [])
        
        let firstNFAtransitions = firstNFAcopy.transitions
        let secondNFAtransitions = secondNFAcopy.transitions
        
        let firstNFAepsTransitions = firstNFAcopy.epsilonTransitions
        let secondNFAepsTransitions = secondNFAcopy.epsilonTransitions
        
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
            
            if key.x == secondNFAcopy.initState {
                nfa.transitions.storedKeys = nfa.transitions.storedKeys.subtracting([MyPair(x: key.x, y: key.y)])
                nfa.transitions.stored.removeValue(forKey: MyPair(x: key.x, y: key.y).hashValue)
                
                nfa.transitions[intersectionState, key.y] = brokenTransitions
            }
        }
        
        let firstNFAstates = firstNFAcopy.states
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
        
        let secondNFAstates = secondNFAcopy.states
        for state in secondNFAstates {
            guard let stateEpsDestinations = secondNFAepsTransitions[state] else {
                continue
            }
            if state == secondNFAcopy.initState {
                nfa.epsilonTransitions[intersectionState] = stateEpsDestinations
            } else {
                nfa.epsilonTransitions[state] = stateEpsDestinations
            }
        }
        nfa.currentStates = nfa.epsClosureHandlerForState(state: nfa.initState)
        
        return nfa
    }
    
    
    func addSymbolToStateNames(inputNFA: NFA<String, String>, symbol: String) -> NFA<String, String> {
        let secondNFAcopy = NFA<String, String>(states: inputNFA.states, initState: inputNFA.initState, acceptStates: inputNFA.acceptStates, ts: [], epsTs: [])
        inputNFA.transitions.stored.forEach { (key, value) in
            secondNFAcopy.transitions.stored[key] = value
        }
        inputNFA.transitions.storedKeys.forEach {
            secondNFAcopy.transitions.storedKeys = secondNFAcopy.transitions.storedKeys.union([$0])
        }
        inputNFA.epsilonTransitions.forEach { (key, value) in
            secondNFAcopy.epsilonTransitions[key] = value
        }
        
        secondNFAcopy.initState = inputNFA.initState + "\(symbol)"
        guard let _ = inputNFA.acceptStates.first else {
            fatalError("no accept states in second NFA")
        }
        let secondNFAcopyAcceptState = inputNFA.acceptStates.first! + "\(symbol)"
        secondNFAcopy.acceptStates = [secondNFAcopyAcceptState]
        
        secondNFAcopy.states.forEach { state in
            let newState = state + "\(symbol)"
            secondNFAcopy.states.remove(state)
            secondNFAcopy.states = secondNFAcopy.states.union([newState])
            
        }
        
        secondNFAcopy.currentStates.forEach { state in
            let newState = state + "\(symbol)"
            secondNFAcopy.states.remove(state)
            secondNFAcopy.states = secondNFAcopy.states.union([newState])
        }
        
        inputNFA.transitions.storedKeys.forEach { pair in
            let newPair = MyPair(x: pair.x + "\(symbol)", y: pair.y)
            let oldSet = secondNFAcopy.transitions.stored.removeValue(forKey: pair.hashValue)!
            var newSet: Set<String> = []
            oldSet.forEach {
                let newValue = $0 + "\(symbol)"
                newSet = newSet.union([newValue])
            }
            secondNFAcopy.transitions.stored[newPair.hashValue] = newSet
            secondNFAcopy.transitions.storedKeys.remove(pair)
            secondNFAcopy.transitions.storedKeys = secondNFAcopy.transitions.storedKeys.union([newPair])
        }
        inputNFA.epsilonTransitions.forEach { (key, value) in
            var newValuesSet: Set<String> = []
            value.forEach {
                let newValue = $0 + "\(symbol)"
                newValuesSet = newValuesSet.union([newValue])
            }
            let newKey = key + "\(symbol)"
            secondNFAcopy.epsilonTransitions.removeValue(forKey: key)
            secondNFAcopy.epsilonTransitions[newKey] = newValuesSet
        }
        return secondNFAcopy
    }
    
    
    func handleKleneeNode(inputNFA: NFA<String, String>) -> NFA<String, String> {
        stateName += 1
        let initState = String(stateName)
        stateName += 1
        let acceptState = String(stateName)
        
        let acceptStateSet: Set<String> = [acceptState]
        
        let inputNFAinitState = inputNFA.initState
        
        guard let inputNFAacceptState = inputNFA.acceptStates.first else {
            fatalError("no accept states in input nfa")
        }
        
        let states = inputNFA.states.union([initState, acceptState])
        
        let newEpsTransitions = [
            (initState, acceptState),
            (inputNFAacceptState, inputNFAinitState),
            (inputNFAacceptState, acceptState),
            (initState, inputNFAinitState)
        ]
        
        let nfa = NFA<String, String>(states: states, initState: initState, acceptStates: acceptStateSet, ts: [], epsTs: newEpsTransitions)
        
        let inputNFAtransitions = inputNFA.transitions
        inputNFAtransitions.stored.forEach { (key, value) in
            nfa.transitions.stored[key] = value
        }
        
        nfa.transitions.storedKeys = nfa.transitions.storedKeys.union(inputNFAtransitions.storedKeys)
        
        let inputNFAepsTransitions = inputNFA.epsilonTransitions
        inputNFAepsTransitions.forEach { (key, value) in
            nfa.epsilonTransitions[key] = value
        }
        
        nfa.currentStates = nfa.epsClosureHandlerForState(state: nfa.initState)
        
        return nfa
    }
    
    
    func handlePositiveClosureNode(inputNFA: NFA<String, String>) -> NFA<String, String> {
        let firstNFA = handleKleneeNode(inputNFA: inputNFA)
        let secondCopyOfInputNFA = addSymbolToStateNames(inputNFA: inputNFA, symbol: "=")
        
        let nfa = handleAndNode(firstNFA: firstNFA, secondNFA: secondCopyOfInputNFA)
        
        return nfa
    }
    
    
    func handleRepeatNode(inputNFA: NFA<String, String>, lowerBorder: Int, higherBorder: Int?) -> NFA<String, String> {
        guard let unwrappedHigherBorder = higherBorder else {
            var leftNFA = addSymbolToStateNames(inputNFA: inputNFA, symbol: "@")
            var inputNFAcopy = inputNFA
            
            if lowerBorder <= 0 {
                fatalError("lower border of repeat node couldnt be less or equal than zero")
            }
            for _ in 1..<lowerBorder {
                inputNFAcopy = addSymbolToStateNames(inputNFA: inputNFAcopy, symbol: "&")
                leftNFA = handleAndNode(firstNFA: leftNFA, secondNFA: inputNFAcopy)
            }
            
            leftNFA.currentStates = leftNFA.epsClosureHandlerForState(state: leftNFA.initState)
            return leftNFA
        }
//        print("🥡 Start right NFA: \n")
        var rightNFA = handleEpsilonNode(with: Literal(token: Token(tag: 94)))
//        rightNFA.printNFAinfo()
//        print("🥡 Start inputNFAcopy: \n")
        var inputNFAcopy = inputNFA
        
//        inputNFAcopy.printNFAinfo()
        let range = unwrappedHigherBorder - lowerBorder
//        print("🥡 Start growing NFA: \n")
        var growingNFA = addSymbolToStateNames(inputNFA: inputNFA, symbol: "{}")
//        growingNFA.printNFAinfo()
        for i in 1...range {
            if i == 1 {
//                print("🏀 Right NFA iteration - \(i):\n")
                rightNFA = handleOrNode(firstNFA: rightNFA, secondNFA: addSymbolToStateNames(inputNFA: inputNFA, symbol: "<>"))
//                rightNFA.printNFAinfo()
            } else {
//                print("🎾 Growing NFA iteration - \(i):\n")
                
                
                inputNFAcopy = addSymbolToStateNames(inputNFA: inputNFAcopy, symbol: "&")
                growingNFA = handleAndNode(firstNFA: addSymbolToStateNames(inputNFA: growingNFA, symbol: "[]"), secondNFA: inputNFAcopy)
//                growingNFA.printNFAinfo()
//                print("🏀 Right NFA iteration - \(i):\n")
                rightNFA = handleOrNode(firstNFA: rightNFA, secondNFA: growingNFA)
//                rightNFA.printNFAinfo()
            }
        }
        
        var leftNFA = inputNFA
        inputNFAcopy = inputNFA

        
        if lowerBorder >= unwrappedHigherBorder {
            fatalError("lower border of repeat node couldnt be more or equal than higher one: try to use this constuction: s{n,}")
        } else if lowerBorder <= 0 {
            fatalError("lower border of repeat node couldnt be less or equal than zero")
        } else if unwrappedHigherBorder <= 0 {
            fatalError("higher border of repeat node couldnt be less or equal than zero")
        } else {
            for _ in 1..<lowerBorder {
//                print("🏉 Left NFA iteration - \(i):\n")
                inputNFAcopy = addSymbolToStateNames(inputNFA: inputNFAcopy, symbol: "~")
                leftNFA = handleAndNode(firstNFA: addSymbolToStateNames(inputNFA: leftNFA, symbol: "?"), secondNFA: inputNFAcopy)
//                leftNFA.printNFAinfo()
            }
        }
        
        let nfa = handleAndNode(firstNFA: leftNFA, secondNFA: rightNFA)
        
        nfa.currentStates = nfa.epsClosureHandlerForState(state: nfa.initState)
        
        return nfa
    }
    
    
    func makeNFA(rootOfSyntaxTree: BinaryNode) -> NFA<String, String> {
        let nfa = handleNode(node: rootOfSyntaxTree.leftNode)
        nfa.captureGroups = captureGroups
        return nfa
    }
    
    func makeNFA(rootOfSyntaxTree: Node) -> NFA<String, String> {
        let nfa = handleNode(node: rootOfSyntaxTree)
        nfa.captureGroups = captureGroups
        
        return nfa
    }
    
    func handleNode(node: Node) -> NFA<String, String> {
        var nfa = NFA<String, String>(states: [], initState: "", acceptStates: [], ts: [], epsTs: [])
        
        
        if let binaryNode = node as? BinaryNode {
            if let concatenationNode = binaryNode as? Concatenation {
                nfa = handleAndNode(firstNFA: handleNode(node: concatenationNode.leftNode), secondNFA: handleNode(node: concatenationNode.rightNode))
            } else if let orNode = binaryNode as? Or {
                nfa = handleOrNode(firstNFA: handleNode(node: orNode.leftNode), secondNFA: handleNode(node: orNode.rightNode))
            } else {
                fatalError("foo")
            }
        } else {
            if let literalNode = node as? Literal {
                if literalNode.token.tag == 94 {
                    nfa = handleEpsilonNode(with: literalNode)
                } else {
                    nfa = handleLiteralNode(with: literalNode)
                }
                
            } else if let positiveClosureNode = node as? PositiveClosure {
                nfa = handlePositiveClosureNode(inputNFA: handleNode(node: positiveClosureNode.targetNode))
            } else if let repeatNode = node as? RepeatExpression {
                guard let repeatToken = repeatNode.token as? TokenRepeat else {
                    fatalError("no borders in repeat")
                }
                
                nfa = handleRepeatNode(inputNFA: handleNode(node: repeatNode.targetNode), lowerBorder: repeatToken.start, higherBorder: repeatToken.end)
            } else if let captureGroupNode = node as? CaptureNode {
                nfa = handleNode(node: captureGroupNode.child)
                guard let token = captureGroupNode.token as? CaptureGroup else {
                    fatalError("[DEBUG]: No id in capture group")
                }
                
                captureGroups[token.num] = captureGroupNode.child
            }
            else {
                fatalError("boo")
            }
        }
        
        return nfa
    }
}





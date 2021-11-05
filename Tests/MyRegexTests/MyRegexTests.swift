    import XCTest
    @testable import MyRegex

    final class MyRegexTests: XCTestCase {
        
        func testInit() {
            let dfa = DFA(alphabet: ["a", "b", "c"],
                          states: ["s0", "s1", "s2", "Error"],
                          initState: "s0",
                          acceptStates: ["s2"],
                          ts: [
                            ("s0", "a", "s1"),
                            ("s1", "b", "s2"),
                            ("s2", "c", "s2"),
                            ("s0", "b", "Error"),
                            ("s0", "c", "Error"),
                            ("s1", "a", "Error"),
                            ("s1", "c", "Error"),
                            ("s2", "a", "Error"),
                            ("s2", "b", "Error")
                          ],
                          defaultTs: [])
            
            XCTAssertEqual(dfa.alphabet, ["a", "b", "c"])
            XCTAssertEqual(dfa.states, ["s0", "s1", "s2", "Error"])
            XCTAssertEqual(dfa.acceptStates, ["s2"])
            XCTAssertEqual(dfa.transitions.storedKeys, [
                            MyPair(x: "s0", y: "a"),
                            MyPair(x: "s0", y: "b"),
                            MyPair(x: "s0", y: "c"),
                            MyPair(x: "s1", y: "a"),
                            MyPair(x: "s1", y: "b"),
                            MyPair(x: "s1", y: "c"),
                            MyPair(x: "s2", y: "a"),
                            MyPair(x: "s2", y: "b"),
                            MyPair(x: "s2", y: "c")])
            XCTAssertEqual(dfa.defaultTransitions.storedKeys, [])
        }
        
        func testInit2() {
                let defaultTs = [
                    (start: "s1", symbol: "b", defaultDestination: "Error"),
                    (start: "s2", symbol: "c", defaultDestination: "Error"),
                    (start: "s0", symbol: "b", defaultDestination: "Error"),
                    (start: "s0", symbol: "c", defaultDestination: "Error")
                  ]
                let dfa = DFA(alphabet: ["a", "b", "c"],
                              states: ["s0", "s1", "s2", "Error"],
                              initState: "s0",
                              acceptStates: ["s2"],
                              ts: [
                                ("s0", "a", "s1"),
                                ("s1", "b", "s2"),
                                ("s2", "c", "s2"),
                                ("s1", "a", "Error"),
                                ("s1", "c", "Error"),
                                ("s2", "a", "Error"),
                                ("s2", "b", "Error")
                              ],
                              defaultTs: defaultTs)
            
            
            XCTAssertEqual(dfa.alphabet, ["a", "b", "c"])
            XCTAssertEqual(dfa.states, ["s0", "s1", "s2", "Error"])
            XCTAssertEqual(dfa.acceptStates, ["s2"])
            XCTAssertEqual(dfa.transitions.storedKeys, [
                            MyPair(x: "s0", y: "a"),
                            MyPair(x: "s1", y: "a"),
                            MyPair(x: "s1", y: "b"),
                            MyPair(x: "s1", y: "c"),
                            MyPair(x: "s2", y: "a"),
                            MyPair(x: "s2", y: "b"),
                            MyPair(x: "s2", y: "c")])
            XCTAssertEqual(dfa.defaultTransitions.storedKeys, [
                            MyPair(x: "s1", y: "b"),
                            MyPair(x: "s2", y: "c"),
                            MyPair(x: "s0", y: "b"),
                            MyPair(x: "s0", y: "c"),
            ])
        }
        
        func testInit3() {
            let defaultTs = [
                (start: "s0", symbol: "b", defaultDestination: "Error"),
                (start: "s0", symbol: "c", defaultDestination: "Error"),
                (start: "s1", symbol: "a", defaultDestination: "Error"),
                (start: "s1", symbol: "c", defaultDestination: "Error"),
                (start: "s2", symbol: "a", defaultDestination: "Error"),
                (start: "s2", symbol: "b", defaultDestination: "Error")
              ]
            let dfa = DFA(alphabet: ["a", "b", "c"],
                          states: ["s0", "s1", "s2", "Error"],
                          initState: "s0",
                          acceptStates: ["s2"],
                          ts: [
                            ("s0", "a", "s1"),
                            ("s1", "b", "s2"),
                            ("s2", "c", "s2")
                          ],
                          defaultTs: defaultTs)
            
            XCTAssertEqual(dfa.alphabet, ["a", "b", "c"])
            XCTAssertEqual(dfa.states, ["s0", "s1", "s2", "Error"])
            XCTAssertEqual(dfa.acceptStates, ["s2"])
            XCTAssertEqual(dfa.transitions.storedKeys, [
                            MyPair(x: "s0", y: "a"),
                            MyPair(x: "s1", y: "b"),
                            MyPair(x: "s2", y: "c")
            ])
            XCTAssertEqual(dfa.defaultTransitions.storedKeys, [
                            MyPair(x: "s0", y: "b"),
                            MyPair(x: "s0", y: "c"),
                            MyPair(x: "s1", y: "a"),
                            MyPair(x: "s1", y: "c"),
                            MyPair(x: "s2", y: "a"),
                            MyPair(x: "s2", y: "b")
            ])
        }
        
        func testConvenianceInit() {
            let dfa = DFA(alphabet: ["a", "b", "c"],
                          states: ["s0", "s1", "s2"],
                          initState: "s0",
                          acceptStates: ["s2"])
            XCTAssertEqual(dfa.alphabet, ["a", "b", "c"])
            XCTAssertEqual(dfa.states, ["s0", "s1", "s2"])
            XCTAssertEqual(dfa.acceptStates, ["s2"])
            XCTAssertEqual(dfa.transitions.storedKeys, [])
            XCTAssertEqual(dfa.defaultTransitions.storedKeys, [])
        }
        
        func testFillDefaultToErrorFunc() {
            let defaultTs = [
                (start: "s1", symbol: "b", defaultDestination: "Error"),
                (start: "s2", symbol: "c", defaultDestination: "Error"),
                (start: "s0", symbol: "b", defaultDestination: "Error"),
                (start: "s0", symbol: "c", defaultDestination: "Error")
              ]
            let dfa = DFA(alphabet: ["a", "b", "c"],
                          states: ["s0", "s1", "s2", "Error"],
                          initState: "s0",
                          acceptStates: ["s2"],
                          ts: [],
                          defaultTs: defaultTs)
            dfa.makeAllDefaultTransitionsGoToErrorState()
            XCTAssertEqual(dfa.alphabet, ["a", "b", "c"])
            XCTAssertEqual(dfa.states, ["s0", "s1", "s2", "Error"])
            XCTAssertEqual(dfa.acceptStates, ["s2"])
            XCTAssertEqual(dfa.transitions.storedKeys, [])
            XCTAssertEqual(dfa.defaultTransitions.storedKeys, [
                            MyPair(x: "s0", y: "a"),
                            MyPair(x: "s0", y: "b"),
                            MyPair(x: "s0", y: "c"),
                            MyPair(x: "s1", y: "a"),
                            MyPair(x: "s1", y: "b"),
                            MyPair(x: "s1", y: "c"),
                            MyPair(x: "s2", y: "a"),
                            MyPair(x: "s2", y: "b"),
                            MyPair(x: "s2", y: "c"),
                            MyPair(x: "Error", y: "a"),
                            MyPair(x: "Error", y: "b"),
                            MyPair(x: "Error", y: "c")
            ])
        }
        
        
        func testFillDefaultToErrorFunc1() {
            let dfa = DFA(alphabet: ["a", "b", "c"],
                          states: ["s0", "s1", "s2", "Error"],
                          initState: "s0",
                          acceptStates: ["s2"],
                          ts: [],
                          defaultTs: [])
            dfa.makeAllDefaultTransitionsGoToErrorState()
            dfa.addTransitions(ts: [
                ("s0", "a", "s1"),
                ("s0", "b", "s2"),
                ("s0", "c", "s2"),
                ("s1", "b", "Error"),
                ("s1", "c", "Error"),
                ("s1", "a", "Error"),
                ("s2", "c", "Error"),
                ("s2", "a", "Error"),
                ("s2", "b", "Error"),
                ("Error", "a", "Error"),
                ("Error", "b", "Error"),
                ("Error", "c", "Error")
            ])
            XCTAssertEqual(dfa.alphabet, ["a", "b", "c"])
            XCTAssertEqual(dfa.states, ["s0", "s1", "s2", "Error"])
            XCTAssertEqual(dfa.acceptStates, ["s2"])
            XCTAssertEqual(dfa.transitions.storedKeys, [
                MyPair(x: "s0", y: "a"),
                MyPair(x: "s0", y: "b"),
                MyPair(x: "s0", y: "c"),
                MyPair(x: "s1", y: "a"),
                MyPair(x: "s1", y: "b"),
                MyPair(x: "s1", y: "c"),
                MyPair(x: "s2", y: "a"),
                MyPair(x: "s2", y: "b"),
                MyPair(x: "s2", y: "c"),
                MyPair(x: "Error", y: "a"),
                MyPair(x: "Error", y: "b"),
                MyPair(x: "Error", y: "c")
            ])
            XCTAssertEqual(dfa.defaultTransitions.storedKeys, [
                MyPair(x: "s0", y: "a"),
                MyPair(x: "s0", y: "b"),
                MyPair(x: "s0", y: "c"),
                MyPair(x: "s1", y: "a"),
                MyPair(x: "s1", y: "b"),
                MyPair(x: "s1", y: "c"),
                MyPair(x: "s2", y: "a"),
                MyPair(x: "s2", y: "b"),
                MyPair(x: "s2", y: "c"),
                MyPair(x: "Error", y: "a"),
                MyPair(x: "Error", y: "b"),
                MyPair(x: "Error", y: "c")
            ])
        }
        
        func testPrintDFAWork() {
            let defaultTs = [
                (start: "s0", symbol: "b", defaultDestination: "Error"),
                (start: "s0", symbol: "c", defaultDestination: "Error"),
                (start: "s1", symbol: "a", defaultDestination: "Error"),
                (start: "s1", symbol: "c", defaultDestination: "Error"),
                (start: "s2", symbol: "a", defaultDestination: "Error"),
                (start: "s2", symbol: "b", defaultDestination: "Error")
              ]
            let dfa = DFA(alphabet: ["a", "b", "c"],
                          states: ["s0", "s1", "s2", "Error"],
                          initState: "s0",
                          acceptStates: ["s2"],
                          ts: [
                            ("s0", "a", "s1"),
                            ("s1", "b", "s2"),
                            ("s2", "c", "s2")
                          ],
                          defaultTs: defaultTs)
            dfa.makeAllDefaultTransitionsGoToErrorState()
            let test = "aaaabc"
            dfa.printDFAWork(for: test)
        }
        
        func testDFAValidation() {
            let defaultTs = [
                (start: "s0", symbol: "b", defaultDestination: "Error"),
                (start: "s0", symbol: "c", defaultDestination: "Error"),
                (start: "s1", symbol: "a", defaultDestination: "Error"),
                (start: "s1", symbol: "c", defaultDestination: "Error"),
                (start: "s2", symbol: "a", defaultDestination: "Error"),
                (start: "s2", symbol: "b", defaultDestination: "Error")
              ]
            let dfa = DFA(alphabet: ["a", "b", "c"],
                          states: ["s0", "s1", "s2", "Error"],
                          initState: "s0",
                          acceptStates: ["s2"],
                          ts: [
                            ("s0", "a", "s1"),
                            ("s1", "b", "s2"),
                            ("s2", "c", "s2")
                          ],
                          defaultTs: defaultTs)
            
            expectFatalError(expectedMessage: "There is no transitions for state - \"Error\"") {
                dfa.validateDFA()
            }
            
        }
        
        func testDFADescription() {
            let defaultTs = [
                (start: "s0", symbol: "b", defaultDestination: "Error"),
                (start: "s0", symbol: "c", defaultDestination: "Error"),
                (start: "s1", symbol: "a", defaultDestination: "Error"),
                (start: "s1", symbol: "c", defaultDestination: "Error"),
                (start: "s2", symbol: "a", defaultDestination: "Error"),
                (start: "s2", symbol: "b", defaultDestination: "Error")
              ]
            let dfa = DFA(alphabet: ["a", "b", "c"],
                          states: ["s0", "s1", "s2", "Error"],
                          initState: "s0",
                          acceptStates: ["s2"],
                          ts: [
                            ("s0", "a", "s1"),
                            ("s1", "b", "s2"),
                            ("s2", "c", "s2")
                          ],
                          defaultTs: defaultTs)
            
            print(dfa)
        }
        
        func testInitNFA() {
            let nfa = NFA(alphabet: ["a", "b", "c"],
                          states: ["A", "B", "C", "D", "E", "F", "G", "H", "J", "K"],
                          initState: "A",
                          acceptStates: ["K"],
                          ts: [
                            ("C", "0", "D"),
                            ("D", "0", "E"),
                            ("F", "1", "G"),
                            ("G", "1", "H")
                          ],
                          epsTs: [
                            ("A", "B"),
                            ("A", "K"),
                            ("B", "C"),
                            ("B", "F"),
                            ("E", "J"),
                            ("H", "J"),
                            ("J", "K"),
                            ("J", "B")
                          ])
            nfa.checkLine(line: "001100")
        }
        
        
        func testAnalyzingTokenOfCaptureGroup() {
            let lexer = Lexer(withPattern: "(2:aaa)")
            let tmp = lexer.analyze()
            guard let capture = tmp as? CaptureGroup else {
                print("literal")
                return
            }
            print(capture.getNum())
        }
        
        
        func testAnalyzingTokenOfGrille() {
            let lexer1 = Lexer(withPattern: "#f")
            let tmp = lexer1.analyze()
            guard let grille = tmp as? Grille else {
                print("literal")
                return
            }
            print(grille.getLiteral())
        }
        
        func testSth() {
            //            print(Tag.getGrilleTag())
            //            print(Tag.getEmptyTag())
            //            print(Tag.getOrTag())
            //            print(Tag.getConcatenationTag())
            //            print(Tag.getPositiveClosureTag())
            //            print(Tag.getRepeatExpressionTag())
            //            print(Tag.getCaptureTag())
            //            print(Tag.getGroupTag())
            //            print(Tag.getEOSTag())
            
            
            
        }
      
        
        func testParser1() {
            let lexer = Lexer(withPattern: "a|b")
            let parser = Parser(lexer: lexer)
            
            parser.program()
            print(parser.root ?? "lol")
            
        }
        
        
        func testParser2() {
            let lexer = Lexer(withPattern: "ab")
            let parser = Parser(lexer: lexer)
            
            parser.program()
            print(parser.root ?? "lol")
            
        }
        
        func testParser3() {
            let lexer = Lexer(withPattern: "ab|b+")
            let parser = Parser(lexer: lexer)
            
            parser.program()
            parser.root?.printNode(tabsNum: 0)
            
        }
        
        func testParser4() {
            let lexer = Lexer(withPattern: "(a|bc)+")
            let parser = Parser(lexer: lexer)
            
            parser.program()
            parser.root?.printNode(tabsNum: 0)
        }
        
        func testParser5() {
            let lexer = Lexer(withPattern: "(1:a)ab\\1")
            let parser = Parser(lexer: lexer)
            
            parser.program()
            parser.root?.printNode(tabsNum: 0)
        }
        
        func testParser6() {
            let lexer = Lexer(withPattern: "\\1(1:a)ab")
            let parser = Parser(lexer: lexer)
            
            parser.program()
            parser.root?.printNode(tabsNum: 0)
        }
        
        
        func testParser7() {
            let lexer = Lexer(withPattern: "a|((a|b){2,5}bc(1:a|b)f+\\1)#|")
            let parser = Parser(lexer: lexer)
            
            parser.program()
            parser.root?.printNode(tabsNum: 0)
        }
        
        
        func testParser8() {
            let lexer = Lexer(withPattern: "a{2,5}b)")
            let parser = Parser(lexer: lexer)
            
            parser.program()
            parser.root?.printNode(tabsNum: 0)
        }
        
        
    }
    
    extension XCTestCase {
        func expectFatalError(expectedMessage: String, testcase: @escaping () -> Void) {
            let expectation = self.expectation(description: "expectingFatalError")
            var assertionMessage: String? = nil
            FatalErrorUtil.replaceFatalError { message, _, _ in
                assertionMessage = message
                expectation.fulfill()
                self.unreachable()
            }
            DispatchQueue.global(qos: .userInitiated).async(execute: testcase)
            waitForExpectations(timeout: 2) { _ in
                XCTAssertEqual(assertionMessage, expectedMessage)
                FatalErrorUtil.restoreFatalError()
            }
        }
        private func unreachable() -> Never {
            repeat {
                RunLoop.current.run()
            } while (true)
        }
    }
    
    
    //    a|(a{2,5}bc(1:a|b)f+\1)#|


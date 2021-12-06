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
            let nfa = NFA(states: ["A", "B", "C", "D", "E", "F", "G", "H", "J", "K"],
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
            XCTAssertEqual(true, nfa.checkLine(line: "001100"))
            XCTAssertEqual(false, nfa.checkLine(line: "00100"))
        }
        
        
        func testCorrectAnalyzingTokenOfCaptureGroup() {
            let lexer = Lexer(withPattern: "(2:aaa)")
            let tmp = lexer.analyze()
            guard let captureToken = tmp as? CaptureGroup else {
                return
            }
            XCTAssertEqual(captureToken.getNum(), 2)
            XCTAssertEqual(captureToken.tag, 258)
        }
        
        func testCorrectAnalyzingTokenOfRepeatTokenWithAllBorders() {
            let lexer = Lexer(withPattern: "{2,5}")
            let tmp = lexer.analyze()
            guard let repeatToken = tmp as? TokenRepeat else {
                print("literal")
                return
            }
            
            XCTAssertEqual(repeatToken.start, 2)
            XCTAssertEqual(repeatToken.end, 5)
            XCTAssertEqual(repeatToken.tag, 257)
        }
        
        func testCorrectAnalyzingOfRepeatTokenWithOnlyLowerBorder() {
            let lexer = Lexer(withPattern: "{2,}")
            let tmp = lexer.analyze()
            guard let repeatToken = tmp as? TokenRepeat else {
                print("literal")
                return
            }
            
            XCTAssertEqual(repeatToken.start, 2)
            XCTAssertEqual(repeatToken.end, nil)
            XCTAssertEqual(repeatToken.tag, 257)
        }
        
        
        func testIncorrectAnalyzingTokenOfRepeatWithOnlyLowerBorder() {
            let lexer = Lexer(withPattern: "{2}")
            expectFatalError(expectedMessage: "Bad syntax in repeat regex structure") {
                let _ = lexer.analyze()
            }
        }
        
        func testIncorrectAnalyzingTokenOfRepeatWithNoCloseBrace() {
            let lexer = Lexer(withPattern: "{2")
            expectFatalError(expectedMessage: "Bad syntax in repeat regex structure") {
                let _ = lexer.analyze()
            }
        }
        
        func testCorrectAnalyzingTokenOfGrille() {
            let lexer = Lexer(withPattern: "#f")
            let tmp = lexer.analyze()
            guard let grille = tmp as? Grille else {
                return
            }
            XCTAssertEqual(102, grille.getLiteral())
            XCTAssertEqual(35, grille.tag)
        }
        
        
        func testMove() {
            let lexer = Lexer(withPattern: "a{2,5}")
            let parser = Parser(lexer: lexer)
            XCTAssertEqual(97, parser.look.tag)
            parser.move()
            XCTAssertEqual(257, parser.look.tag)
        }
        
        
        func testMatch() {
            let lexer = Lexer(withPattern: "abc")
            let parser = Parser(lexer: lexer)
            parser.match(tag: 97)
            XCTAssertEqual(98, parser.look.tag)
            expectFatalError(expectedMessage: "Bad match") {
                parser.match(tag: 97)
            }
        }
        
        
        func testLiteralParserFunc1() {
            let parser = Parser(lexer: Lexer(withPattern: "a"))
            let tag = parser.literal().token.tag
            XCTAssertNotNil(parser.literal() as? Literal, "Converts")
            XCTAssertEqual(97, tag)
        }
        
        
        func testLiteralParserFunc2() {
            let parser = Parser(lexer: Lexer(withPattern: "(2:a)"))
            let tmp = parser.literal()
            XCTAssertNotNil(tmp as? CaptureNode, "Converts")
            guard let newTmp = tmp as? CaptureNode else {
                return
            }
            XCTAssertEqual(258, newTmp.token.tag)
            XCTAssertEqual(97, newTmp.child.token.tag)
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
            let lexer = Lexer(withPattern: "(1:a)a^b\\1")
            let parser = Parser(lexer: lexer)
            
            parser.program()
            parser.root?.printNode(tabsNum: 0)
        }
        
        func testParser6() {
            let lexer = Lexer(withPattern: "\\1(1:a)ab")
            let parser = Parser(lexer: lexer)

            expectFatalError(expectedMessage: "You have to define numeric capture group before using it") {
                parser.program()
            }
            
            parser.root?.printNode(tabsNum: 0)
        }
        
        
        func testParser10() {
            let lexer = Lexer(withPattern: "((1:a)|(2:b))\\1|\\2")
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
            let lexer = Lexer(withPattern: "(1:a|b)\\1")
            let parser = Parser(lexer: lexer)
            
            parser.program()
            parser.root?.printNode(tabsNum: 0)
        }
        
        func testLiteralTypeTransformation() {
            let literal = Literal(token: Token(tag: 97))
            let nfa = STtoNFAFormatter().handleLiteralNode(with: literal)
            XCTAssertTrue(nfa.checkLine(line: "a"))
            XCTAssertFalse(nfa.checkLine(line: "b"))
        }
        
        func testEpsilonTypeTransforamtion() {
            let eps = Literal(token: Token(tag: 94))
            let nfa = STtoNFAFormatter().handleEpsilonNode(with: eps)
            XCTAssertTrue(nfa.checkLine(line: ""))
            XCTAssertFalse(nfa.checkLine(line: "a"))
        }
        
        func testOrTypeTransformation() {
            let formatter = STtoNFAFormatter()
            let literal = Literal(token: Token(tag: 97))
            let nfa1 = formatter.handleLiteralNode(with: literal)
            
            let eps = Literal(token: Token(tag: 98))
            let nfa2 = formatter.handleLiteralNode(with: eps)
            
            let nfa = formatter.handleOrNode(firstNFA: nfa1, secondNFA: nfa2)
            
            XCTAssertTrue(nfa.checkLine(line: "a"))
            XCTAssertTrue(nfa.checkLine(line: "b"))
            XCTAssertFalse(nfa.checkLine(line: "c"))
        }
        
        func testAndTypeTransformation() {
            let formatter = STtoNFAFormatter()
            let literal = Literal(token: Token(tag: 97))
            let nfa1 = formatter.handleLiteralNode(with: literal)
            
            let eps = Literal(token: Token(tag: 98))
            let nfa2 = formatter.handleLiteralNode(with: eps)
            
            let nfa3 = formatter.handleOrNode(firstNFA: nfa1, secondNFA: nfa2)
            
            let literal2 = Literal(token: Token(tag: 110))
            let nfa4 = formatter.handleLiteralNode(with: literal2)
            
            let nfa = formatter.handleAndNode(firstNFA: nfa3, secondNFA: nfa4)
            
            XCTAssertTrue(nfa.checkLine(line: "an"))
            XCTAssertTrue(nfa.checkLine(line: "bn"))
            XCTAssertFalse(nfa.checkLine(line: "ab"))
        }
        
        func testKleneeTypeTranformations() {
            let formatter = STtoNFAFormatter()
            let literal = Literal(token: Token(tag: 97))
            let nfa1 = formatter.handleLiteralNode(with: literal)
            
            let nfa = formatter.handleKleneeNode(inputNFA: nfa1)
            
            XCTAssertTrue(nfa.checkLine(line: ""))
            XCTAssertTrue(nfa.checkLine(line: "a"))
            XCTAssertTrue(nfa.checkLine(line: "aa"))
            XCTAssertTrue(nfa.checkLine(line: "aaaaa"))
            
            XCTAssertFalse(nfa.checkLine(line: "b"))
        }
        
        func testPositiveClosureTypeTransformation() {
            let formatter = STtoNFAFormatter()
            let literal = Literal(token: Token(tag: 97))
            let nfa1 = formatter.handleLiteralNode(with: literal)
            
            let nfa = formatter.handlePositiveClosureNode(inputNFA: nfa1)

            XCTAssertFalse(nfa.checkLine(line: ""))
            
            XCTAssertTrue(nfa.checkLine(line: "a"))
            XCTAssertTrue(nfa.checkLine(line: "aa"))
            XCTAssertTrue(nfa.checkLine(line: "aaa"))
            XCTAssertTrue(nfa.checkLine(line: "aaaaa"))
        }
        
        
        func testRepeatTypeTransformation() {
            let formatter = STtoNFAFormatter()
            let literal = Literal(token: Token(tag: 97))
            let nfa1 = formatter.handleLiteralNode(with: literal)
            
            let nfa = formatter.handleRepeatNode(inputNFA: nfa1, lowerBorder: 2, higherBorder: 5)

            XCTAssertFalse(nfa.checkLine(line: ""))
            XCTAssertFalse(nfa.checkLine(line: "a"))

            XCTAssertTrue(nfa.checkLine(line: "aa"))
            XCTAssertTrue(nfa.checkLine(line: "aaa"))
            XCTAssertTrue(nfa.checkLine(line: "aaaaa"))

            XCTAssertFalse(nfa.checkLine(line: "aaaaaa"))
        }
        
        
        func testRegexToNFAtransformation1() {
            let lexer = Lexer(withPattern: "ab|b+")
            let parser = Parser(lexer: lexer)
            parser.program()
            
            let formatter = STtoNFAFormatter()
            let nfa = formatter.makeNFA(rootOfSyntaxTree: parser.root!)
            XCTAssertTrue(nfa.checkLine(line: "ab"))
            XCTAssertTrue(nfa.checkLine(line: "b"))
            XCTAssertTrue(nfa.checkLine(line: "bbb"))
            
            XCTAssertFalse(nfa.checkLine(line: "a"))
        }
        
        
        func testNFA2() {
            let lexer = Lexer(withPattern: "mephi|mipt|msu")
            let parser = Parser(lexer: lexer)
            
            parser.program()
            parser.root?.printNode(tabsNum: 0)
            let formatter = STtoNFAFormatter()
            let nfa = formatter.makeNFA(rootOfSyntaxTree: parser.root!)
            
            XCTAssertTrue(nfa.checkLine(line: "mephi"))
            XCTAssertTrue(nfa.checkLine(line: "mipt"))
            XCTAssertTrue(nfa.checkLine(line: "msu"))
            
            XCTAssertFalse(nfa.checkLine(line: "hse"))
        }
        

        
        
        func testNFA3() {
            let lexer = Lexer(withPattern: "(mephi){4,5}|(mipt)+")
            let parser = Parser(lexer: lexer)
            
            parser.program()
            parser.root?.printNode(tabsNum: 0)
            let formatter = STtoNFAFormatter()
            let nfa = formatter.makeNFA(rootOfSyntaxTree: parser.root!)
            

            XCTAssertFalse(nfa.checkLine(line: "mephimephimephi"))
            
            XCTAssertTrue(nfa.checkLine(line: "mephimephimephimephi"))
            XCTAssertTrue(nfa.checkLine(line: "mephimephimephimephimephi"))
            XCTAssertTrue(nfa.checkLine(line: "mipt"))
            XCTAssertTrue(nfa.checkLine(line: "miptmipt"))
            
        }
        
        
        func testNFA4() {
            let lexer = Lexer(withPattern: "a{2,}")
            let parser = Parser(lexer: lexer)
            
            parser.program()
            parser.root?.printNode(tabsNum: 0)
            let formatter = STtoNFAFormatter()
            let nfa = formatter.makeNFA(rootOfSyntaxTree: parser.root!)
            nfa.printNFAinfo()
            XCTAssertTrue(nfa.checkLine(line: "aa"))
        }
        
        
        func testGettingStartState() {
            let lexer = Lexer(withPattern: "a|b")
            let parser = Parser(lexer: lexer)
            parser.program()
            
            let nfa = STtoNFAFormatter().makeNFA(rootOfSyntaxTree: parser.root!)
            nfa.printNFAinfo()
            let formatter = NFAtoDFAformatter(nfa: nfa)
            formatter.getStartState()
            XCTAssertEqual(formatter.dfa.initState, "S0")
            XCTAssertEqual(["S0": Set(["1", "5", "3"])], formatter.statesRep)
            XCTAssertEqual(["S0"], formatter.states)
        }
        
        func testGettingAlphabet() {
            let lexer = Lexer(withPattern: "abcdefg|m")
            let parser = Parser(lexer: lexer)
            parser.program()
            
            let nfa = STtoNFAFormatter().makeNFA(rootOfSyntaxTree: parser.root!)
            nfa.printNFAinfo()
            let formatter = NFAtoDFAformatter(nfa: nfa)
            formatter.getAlphabetFromNFA()
            XCTAssertEqual(formatter.alphabet, ["a", "b", "c", "d", "e", "f", "g", "m"])
            XCTAssertEqual(formatter.dfa.alphabet, ["a", "b", "c", "d", "e", "f", "g", "m"])
        }
        
        func testDFAconstruction() {
            let nfa = NFA(states: ["A", "BI", "G", "C", "E", "D", "F", "H", "J"],
                          initState: "A",
                          acceptStates: ["J"],
                          ts: [
                            ("A", "letter", "BI"),
                            ("C", "letter", "D"),
                            ("E", "digit", "F")
                          ],
                          epsTs: [
                            ("BI", "G"),
                            ("G", "C"),
                            ("G", "E"),
                            ("D", "H"),
                            ("F", "H"),
                            ("H", "G"),
                            ("H", "J"),
                            ("BI", "J")
                          ])
            let formatter = NFAtoDFAformatter(nfa: nfa)
            formatter.constructDFA()
            let dfa = formatter.dfa
            
            print(dfa.initState)
            print(dfa.states)
            print("================")
            print(dfa)
        }

        func testDFAconstruction1() {
            let lexer = Lexer(withPattern: "a{2,3}|b")
            let parser = Parser(lexer: lexer)
            
            parser.program()
            parser.root?.printNode(tabsNum: 0)
            let nfaFormatter = STtoNFAFormatter()
            let nfa = nfaFormatter.makeNFA(rootOfSyntaxTree: parser.root!)
            nfa.checkLine(line: "aa")
            let dfaFormatter = NFAtoDFAformatter(nfa: nfa)
            dfaFormatter.constructDFA()
            let dfa = dfaFormatter.dfa
            print(dfa.checkLine(line: "aa") ? "Acceptable dfa" : "Not accceptable dfa")
        }
        
        func testMakeStartPiSplit() {
            let lexer = Lexer(withPattern: "a|b")
            let parser = Parser(lexer: lexer)
            
            parser.program()
            parser.root?.printNode(tabsNum: 0)
            let nfaFormatter = STtoNFAFormatter()
            let nfa = nfaFormatter.makeNFA(rootOfSyntaxTree: parser.root!)
            let dfaFormatter = NFAtoDFAformatter(nfa: nfa)
            dfaFormatter.constructDFA()
            let dfa = dfaFormatter.dfa
            
            let minDFAformatter = DFAtoMinDFAFormatter(dfa: dfa)
            let result = minDFAformatter.makeStartPiSplit()
            print(result[0])
            print(result[1])
            print(dfa)
        }
        
        func testDFAMinimization() {
            let nfa = NFA(states: ["A", "BI", "G", "C", "E", "D", "F", "H", "J"],
                          initState: "A",
                          acceptStates: ["J"],
                          ts: [
                            ("A", "letter", "BI"),
                            ("C", "letter", "D"),
                            ("E", "digit", "F")
                          ],
                          epsTs: [
                            ("BI", "G"),
                            ("G", "C"),
                            ("G", "E"),
                            ("D", "H"),
                            ("F", "H"),
                            ("H", "G"),
                            ("H", "J"),
                            ("BI", "J")
                          ])
            let formatter = NFAtoDFAformatter(nfa: nfa)
            formatter.constructDFA()
            let dfa = formatter.dfa
            
            let minimizeFormatter = DFAtoMinDFAFormatter(dfa: dfa)
            let minDFA = minimizeFormatter.minimizeDFA()
            
            print(minDFA)
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

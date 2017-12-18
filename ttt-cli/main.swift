//
//  main.swift
//  ttt-cli
//
//  Created by David Davis on 12/1/17.
//  Copyright © 2017 David Davis. All rights reserved.
//

import Foundation

class Main
{
    func usage() -> Never
    {
        let programName = CommandLine.arguments[0].split(separator: "/").last!
        print("usage: \(programName) [-player1 local|airandom|aiminimax] [-player2 local|airandom|aiminimax] [-first player1|player2] [-board 3x3|4x4|5x5]")
        exit(1)
    }
    
    func makeAiPlayerName(_ type: Settings.PlayerType) -> String?
    {
        switch type
        {
        case .AI_MINIMAX:
            return "AI (minimax)"
        case .AI_RANDOM:
            return "AI (random)"
        default:
            break
        }
        
        return nil
    }
    
    func parseOptions()
    {
        var p1Name = "Player 1"
        var p2Name = "Player 2"
        var p1Type = Settings.PlayerType.LOCAL
        var p2Type = Settings.PlayerType.LOCAL
        var p1First = true
        var boardType = Settings.BoardSize.SIZE_3x3
        
        enum CommandLineOptions: Int32
        {
            case PLAYER_1 = 1
            case PLAYER_2
            case FIRST
            case BOARD_SIZE
        }
        
        typealias OptionsDict = [String: CommandLineOptions]
        typealias OptionsDictIter = DictionaryIterator<String, CommandLineOptions>
        typealias CString = UnsafePointer<Int8>
        typealias OptionsCStringDict = [CString : CommandLineOptions]
        
        let optionsDict: OptionsDict =
        [
            "player1": .PLAYER_1,
            "player2": .PLAYER_2,
            "first": .FIRST,
            "board": .BOARD_SIZE,
        ]
        
        func makeCStrings(iter: OptionsDictIter, cStringsDict: inout OptionsCStringDict, body: (OptionsCStringDict) -> Void)
        {
            var iter = iter
            if let (key, value) = iter.next()
            {
                // tempCString does not exist on return from the withCString closure, so we use recursion
                key.withCString
                {
                    tempCString in
                    
                    cStringsDict.updateValue(value, forKey: tempCString)
                    makeCStrings(iter: iter, cStringsDict: &cStringsDict, body: body)
                }
            }
            else
            {
               body(cStringsDict)
            }
        }
        
        var optionCStringDict: OptionsCStringDict = [:]
        makeCStrings(iter: optionsDict.makeIterator(), cStringsDict: &optionCStringDict)
        {
            var longopts = $0.map
            {
                (tuple) -> option in
                
                let (key, value) = tuple
                
                // option is defined in Darwin.getopt
                return option(name: key, has_arg: required_argument, flag: nil, val: value.rawValue)
            }
            longopts.append(option(name: nil, has_arg: 0, flag: nil, val: 0))

            while let commandLineOptionRaw = Optional(getopt_long_only(CommandLine.argc, CommandLine.unsafeArgv, "", longopts, nil)), commandLineOptionRaw != -1
            {
                let playerOptions: [String: Settings.PlayerType] =
                [
                    "local": .LOCAL,
                    "airandom": .AI_RANDOM,
                    "aiminimax": .AI_MINIMAX,
                ]
                
                let boardOptions: [String: Settings.BoardSize] =
                [
                    "3x3": .SIZE_3x3,
                    "4x4": .SIZE_4x4,
                    "5x5": .SIZE_5x5,
                ]
                
                switch commandLineOptionRaw
                {
                case CommandLineOptions.PLAYER_1.rawValue:
                    if let type = playerOptions[String(cString: optarg)]
                    {
                        p1Type = type
                        p1Name = makeAiPlayerName(type) ?? p1Name
                    }
                    else
                    {
                        usage()
                    }
                case CommandLineOptions.PLAYER_2.rawValue:
                    if let type = playerOptions[String(cString: optarg)]
                    {
                        p2Type = type
                        p2Name = makeAiPlayerName(type) ?? p2Name
                    }
                    else
                    {
                        usage()
                    }
                case CommandLineOptions.FIRST.rawValue:
                    let first = String(cString: optarg)
                    if first == "player1"
                    {
                        p1First = true
                    }
                    else if first == "player2"
                    {
                        p1First = false
                    }
                    else
                    {
                        usage()
                    }
                case CommandLineOptions.BOARD_SIZE.rawValue:
                    if let type = boardOptions[String(cString: optarg)]
                    {
                        boardType = type
                    }
                    else
                    {
                        usage()
                    }
                default:
                    usage()
                }
            }
        }
        
        Settings(name: p1Name, movesFirst: p1First, type: p1Type, size: boardType).update()
        Settings(name: p2Name, movesFirst: !p1First, type: p2Type, size: boardType).update()
    }
    
    func showBoardRow(board: GameBoard, row: Int)
    {
        let columns = board.stride
        
        for c in 1...columns
        {
            if c != 1
            {
                print("|", terminator: "")
            }
            
            let state = board[((row - 1) * columns) + c]
            switch state
            {
            case .CROSS:
                print("X", terminator: "")
            case .NAUGHT:
                print("O", terminator: "")
            case .EMPTY:
                print(" ", terminator: "")
            }
        }
        print("")
    }
    
    func showBoard()
    {
        let board = Game.instance.board
        let columns = board.stride
        let rows = board.stride
        
        print("")
        for r in 1...rows
        {
            if r != 1
            {
                print(String(repeating: "-", count: (2 * columns) - 1))
            }
            showBoardRow(board: board, row: r)
        }
        print("")
    }
    
    func scheduleInput()
    {
        DispatchQueue.main.async
        {
            self.processInput()
        }
    }
    
    func processEvent(event: GameEvents)
    {
        switch event
        {
        case .GAME_TIE:
            print("Game Draw\n")
            if !Game.instance.currentPlayer.isLocal
            {
                scheduleInput()
            }
        case .GAME_WON(let winPositions, let player):
            print("Game Won [\(player.name)] Positions: \(winPositions)\n")
            if !Game.instance.currentPlayer.isLocal
            {
                scheduleInput()
            }
        case .PLAYER_MOVE(_, _):
            fatalError()
        case .PLAYER_MOVE_COMMIT(let position, let player):
            print("Move: \(position) [\(player.name)]")
            showBoard()
            if Game.instance.currentPlayer.isLocal
            {
               scheduleInput()
            }
        }
    }
    
    func processInput()
    {
        var processing = true
        let positionStrings = (1...Game.instance.board.maxPosition).map { String($0) }
        
        while processing
        {
            print("> ", terminator: "")
            let cmd = readLine()
            
            switch cmd
            {
            case let pos where pos != nil && positionStrings.contains(pos!):
                let position = Int(pos!)!
                if (Game.instance.board[position] == .EMPTY && Game.instance.isPlaying)
                {
                    BoardEvents.MOVE_COMMIT(position: position).postEvent()
                    processing = false
                }
                else
                {
                    print("Illegal Move")
                }
            case "q"?, "Q"?:
                exit(0)
            case "n"?, "N"?:
                startNewGame()
                processing = false
            case nil:
                print("EOF")
                exit(1)
            default:
                print("Error")
            }
        }
    }
    
    func startNewGame()
    {
        Game.instance.newGame()
        if Game.instance.currentPlayer.isLocal
        {
            showBoard()
            scheduleInput()
        }
    }
    
    private var observerToken: Any?
    
    func main()
    {
        print("Running...")
        
        // initialize settings from command line arguments
        parseOptions()
        
        // setup game object event observers
        GameEvents.addObserver(token: &observerToken, callback: processEvent)
        
        // Start a new game
        // if game object current player is local player, then process input for first move
        startNewGame()
        
        // return and let runloop process async blocks (notifications from game object)
        return
    }
    
    func _start()
    {
        DispatchQueue.main.async
        {
            self.main()
        }
        RunLoop.main.run()
        exit(99)
    }
}

Main()._start()



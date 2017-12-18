//
//  Settings.swift
//  TicTacToe
//
//  Created by David Davis on 11/28/17.
//  Copyright © 2017 David Davis. All rights reserved.
//

import Foundation

struct Settings
{
    private static var _first: Settings = Settings(name: "Unknown-1", movesFirst: true, type: PlayerType.LOCAL, size: BoardSize.SIZE_3x3)
    private static var _second: Settings = Settings(name: "Unknown-2", movesFirst: false, type: PlayerType.LOCAL, size: BoardSize.SIZE_3x3)
    
    static var first: Settings
    {
        return _first
    }
    
    static var second: Settings
    {
        return _second
    }
    
    enum PlayerType
    {
        case LOCAL
        //case REMOTE
        case AI_RANDOM
        case AI_MINIMAX
    }
    
    enum BoardSize
    {
        case SIZE_3x3
        case SIZE_4x4
        case SIZE_5x5
        case SIZE_3x3x3
        case SIZE_4x4x4
        case SIZE_5x5x5
    }
    
    let playerName: String
    let playerMovesFirst: Bool
    let playerType: PlayerType
    let boardSize: BoardSize
    
    func update()
    {
        if playerMovesFirst
        {
            Settings._first = self
        }
        else
        {
            Settings._second = self
        }
    }
    
    init(name: String, movesFirst: Bool, type: PlayerType, size: BoardSize)
    {
        playerName = name
        playerMovesFirst = movesFirst
        playerType = type
        boardSize = size
    }
}












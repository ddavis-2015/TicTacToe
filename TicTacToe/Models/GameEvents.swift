//
//  GameEvents.swift
//  TicTacToe
//
//  Created by David Davis on 11/28/17.
//  Copyright © 2017 David Davis. All rights reserved.
//

import Foundation

enum GameEvents: EventsProtocol
{
    case PLAYER_MOVE(position: GameBoard.Position, player: Player)
    case PLAYER_MOVE_COMMIT(position: GameBoard.Position, player: Player)
    //case PLAYER_MOVE_CANCEL(player: Player)
    
    case GAME_WON(winPositions: [GameBoard.PositionSet], player: Player)
    case GAME_TIE
    
    static let EVENT_NAME = Notification.Name(rawValue: "GameEvent")
}

//
//  BoardEvents.swift
//  TicTacToe
//
//  Created by David Davis on 11/28/17.
//  Copyright © 2017 David Davis. All rights reserved.
//

import Foundation

enum BoardEvents: EventsProtocol
{
    case MOVE_NOT_COMMITED(position: GameBoard.Position)
    case MOVE_COMMIT(position: GameBoard.Position)
    //case MOVE_CANCELED
    
    static let EVENT_NAME = Notification.Name(rawValue: "BoardEvent")
}

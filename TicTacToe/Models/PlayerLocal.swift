//
//  PlayerLocal.swift
//  TicTacToe
//
//  Created by David Davis on 11/28/17.
//  Copyright © 2017 David Davis. All rights reserved.
//

import Foundation

class PlayerLocal: Player
{
    private var _observerToken: Any?
    
    override var isLocal: Bool
    {
        return true
    }
    
    deinit
    {
        removeNotificationObserver()
    }
    
    private func removeNotificationObserver()
    {
        BoardEvents.removeObserver(token: &_observerToken)
    }
    
    private func processBoardEvent(event: BoardEvents)
    {
        switch event
        {
        case .MOVE_COMMIT(let newPosition):
            Game.instance.submitMove(commit: true, position: newPosition)
        case .MOVE_NOT_COMMITED(let newPosition):
            Game.instance.submitMove(position: newPosition)
        }
    }
    
    override func beginTurn()
    {
        BoardEvents.addObserver(token: &_observerToken, callback: processBoardEvent)
    }
    
    override func endTurn()
    {
        removeNotificationObserver()
    }
}

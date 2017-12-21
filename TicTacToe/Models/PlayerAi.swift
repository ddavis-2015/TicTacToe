//
//  PlayerAi.swift
//  TicTacToe
//
//  Created by David Davis on 11/28/17.
//  Copyright © 2017 David Davis. All rights reserved.
//

import Foundation

class PlayerAi: Player
{
    override var isAi: Bool
    {
        return true
    }
    
    private let strategy: Strategy
    
    init(name: String, isFirst: Bool, strategy: Strategy)
    {
        self.strategy = strategy
        super.init(name: name, isFirst: isFirst)
    }
    
    override func beginTurn()
    {
        self.strategy.computeNextMove(using: Game.instance.board)
        {
            position in
            
            DispatchQueue.main.async
            {
                Game.instance.submitMove(commit: true, position: position)
            }
        }
    }
}

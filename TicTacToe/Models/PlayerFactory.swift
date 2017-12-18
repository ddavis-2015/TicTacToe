//
//  PlayerFactory.swift
//  TicTacToe
//
//  Created by David Davis on 11/28/17.
//  Copyright © 2017 David Davis. All rights reserved.
//

import Foundation

struct PlayerFactory
{
    static func makePlayer(settings: Settings) -> Player
    {
        let player: Player
        
        switch settings.playerType
        {
        case .LOCAL:
            player = PlayerLocal(name: settings.playerName, isFirst: settings.playerMovesFirst)
        case .AI_MINIMAX:
            player = PlayerAi(name: settings.playerName, isFirst: settings.playerMovesFirst, strategy: StrategyMiniMax())
        case .AI_RANDOM:
            player = PlayerAi(name: settings.playerName, isFirst: settings.playerMovesFirst, strategy: StrategyRandom())
        }
        
        return player
    }
}

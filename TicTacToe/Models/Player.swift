//
//  Player.swift
//  TicTacToe
//
//  Created by David Davis on 11/28/17.
//  Copyright © 2017 David Davis. All rights reserved.
//

import Foundation

class Player
{
    // player's name
    let name: String
    // player goes first: the player is playing cross (X)
    let isFirst: Bool
    
    // Player subclasses
    var isLocal: Bool
    {
        return false
    }
    
    var isRemote: Bool
    {
        return false
    }
    
    var isAi: Bool
    {
        return false
    }
    
    init(name: String, isFirst: Bool)
    {
        self.name = name
        self.isFirst = isFirst
    }
    
    func beginTurn()
    {
    }
    
    func endTurn()
    {
    }
}

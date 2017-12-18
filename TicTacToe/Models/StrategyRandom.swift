//
//  StrategyRandom.swift
//  TicTacToe
//
//  Created by David Davis on 11/29/17.
//  Copyright © 2017 David Davis. All rights reserved.
//

import Foundation

struct StrategyRandom: Strategy
{
    func getNextMove(using board: GameBoard) -> Int
    {
        let empties = board.emptySet
        let i = Int(arc4random_uniform(UInt32(empties.count)))
        return empties[empties.index(empties.startIndex, offsetBy: i)]
    }
}

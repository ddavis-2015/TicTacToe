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
    func computeNextMove(using board: GameBoard, body: @escaping (GameBoard.Position) -> Void)
    {
        let empties = board.empties
        let i = Int(arc4random_uniform(UInt32(empties.count)))
        let position = empties[empties.index(empties.startIndex, offsetBy: i)]
        
        let atTime = DispatchTime.now() + 0.7
        DispatchQueue.main.asyncAfter(deadline: atTime)
        {
            body(position)
        }
    }
}

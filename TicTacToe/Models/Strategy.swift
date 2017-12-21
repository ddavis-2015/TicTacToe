//
//  Strategy.swift
//  TicTacToe
//
//  Created by David Davis on 11/29/17.
//  Copyright © 2017 David Davis. All rights reserved.
//

import Foundation

protocol Strategy
{
    func computeNextMove(using board: GameBoard, body: @escaping (GameBoard.Position) -> Void)
}

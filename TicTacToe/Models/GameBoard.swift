//
//  GameBoard.swift
//  TicTacToe
//
//  Created by David Davis on 12/8/17.
//  Copyright © 2017 David Davis. All rights reserved.
//

import Foundation

struct GameBoard
{
    enum State
    {
        case NAUGHT
        case CROSS
        case EMPTY
    }
    
    typealias Position = Int
    typealias PositionSet = Set<Position>
    
    private var board: [State]
    private let winSets: [PositionSet]
    
    private mutating func setStates(position: Position, state: State)
    {
        switch board[position - 1]
        {
        case .CROSS:
            crosses.remove(position)
        case .NAUGHT:
            naughts.remove(position)
        case .EMPTY:
            empties.remove(position)
        }
        switch state
        {
        case .CROSS:
            crosses.insert(position)
        case .NAUGHT:
            naughts.insert(position)
        case .EMPTY:
            empties.insert(position)
        }
    }
    
    private var naughts = PositionSet()
    
    var naughtSet: PositionSet
    {
        return naughts
    }
    
    private var crosses = PositionSet()
    
    var crossSet: PositionSet
    {
        return crosses
    }
    
    private var empties: PositionSet
    
    var emptySet: PositionSet
    {
        return empties
    }
    
    let stride: Int
    let levels: Int
    
    var maxPosition: Position
    {
        return stride * stride * levels
    }
    
    var hasWon: Bool
    {
        return !winPositions.isEmpty
    }
    
    var hasTied: Bool
    {
        for testState in [State.CROSS, State.NAUGHT]
        {
            var testBoard = self
            for position in 1...testBoard.maxPosition
            {
                if testBoard[position] == .EMPTY
                {
                    testBoard[position] = testState
                }
            }
            if testBoard.hasWon
            {
                return false
            }
        }
        
        return true
    }
    
    var winPositions: [PositionSet]
    {
        for testSet in [crossSet, naughtSet]
        {
            let wins = (winSets.map { $0.isSubset(of: testSet) ? $0 : PositionSet() }).filter { $0.isEmpty == false }
            if wins.isEmpty == false
            {
                return wins
            }
        }
        
        return []
    }
    
    subscript(position: Position) -> State
    {
        get
        {
            assert(position > 0)
            assert((1...board.count).contains(position))
            
            return board[position - 1]
        }
        set(value)
        {
            assert(position > 0)
            assert((1...board.count).contains(position))
            
            setStates(position: position, state: value)
            board[position - 1] = value
        }
    }
    
    private static func generateWinSets(stride: Int, levels: Int, maxPosition: Int) -> [PositionSet]
    {
        var wins: [PositionSet] = []

        // rows
        for row in 1...stride
        {
            let start = ((row - 1) * stride) + 1
            let end = start + stride - 1
            wins.append(PositionSet(start...end))
        }
        
        // columns
        for column in 1...stride
        {
            let start = column
            let end = ((stride - 1) * stride) + column
            wins.append(PositionSet(Swift.stride(from: start, through: end, by: stride)))
        }
        
        // diagonals
        wins.append(PositionSet(Swift.stride(from: 1, through: stride * stride, by: stride + 1)))
        wins.append(PositionSet(Swift.stride(from: stride, through: ((stride - 1) * stride) + 1, by: stride - 1)))
        
        return wins
    }
    
    init(stride: Int, levels: Int)
    {
        let maxPosition = stride * stride * levels
        
        self.stride = stride
        self.levels = levels
        self.board = Array<State>(repeating: .EMPTY, count: maxPosition)
        self.empties = PositionSet(1...maxPosition)
        self.winSets = GameBoard.generateWinSets(stride: stride, levels: levels, maxPosition: maxPosition)
    }
}








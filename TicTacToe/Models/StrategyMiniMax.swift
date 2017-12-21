//
//  StrategyMiniMax.swift
//  TicTacToe
//
//  Created by David Davis on 11/29/17.
//  Copyright © 2017 David Davis. All rights reserved.
//

import Foundation

//
// minimax search with alpha-beta pruning
//
struct StrategyMiniMax: Strategy
{
    func computeNextMove(using board: GameBoard, body: @escaping (GameBoard.Position) -> Void)
    {
        DispatchQueue.global().async
        {
            body(self.getPosition(board: board))
        }
    }
    
    private enum NodeScore: Int, Comparable
    {
        static func <(lhs: StrategyMiniMax.NodeScore, rhs: StrategyMiniMax.NodeScore) -> Bool
        {
            return lhs.rawValue < rhs.rawValue
        }
        
        static prefix func -(lhs: StrategyMiniMax.NodeScore) -> StrategyMiniMax.NodeScore
        {
            return NodeScore(rawValue: -lhs.rawValue)!
        }
        
        case WIN = 10
        case TIE_MAX = 2
        case INDETERMINATE_MAX = 1
        case INDETERMINATE_MIN = -1
        case TIE_MIN = -2
        case LOSE = -10
    }
    
    private typealias ScoreData = (position: GameBoard.Position, score: NodeScore)
    
    private func scoreSubTree(board: GameBoard, depth: Int, alpha: NodeScore, beta: NodeScore, maximizing: Bool, moveState: GameBoard.State) -> NodeScore
    {
        // algorithm adapted from https://en.wikipedia.org/wiki/Alpha–beta_pruning
        
        //        01 function alphabeta(node, depth, α, β, maximizingPlayer)
        //        02      if depth = 0 or node is a terminal node
        //        03          return the heuristic value of node
        //        04      if maximizingPlayer
        //        05          v := -∞
        //        06          for each child of node
        //        07              v := max(v, alphabeta(child, depth – 1, α, β, FALSE))
        //        08              α := max(α, v)
        //        09              if β ≤ α
        //        10                  break (* β cut-off *)
        //        11          return v
        //        12      else
        //        13          v := +∞
        //        14          for each child of node
        //        15              v := min(v, alphabeta(child, depth – 1, α, β, TRUE))
        //        16              β := min(β, v)
        //        17              if β ≤ α
        //        18                  break (* α cut-off *)
        //        19          return v
        
        if depth == maxDepth || board.empties.isEmpty || board.hasWon || board.hasTied
        {
            // invert maximizing to reflect maximizing state of nodes prior to call
            return generateNodeScore(board: board, maximizing: !maximizing)
        }
       
        var score: NodeScore = maximizing ? .LOSE : .WIN
        var alpha = alpha
        var beta = beta
        
        for position in board.empties
        {
            var childBoard = board
            childBoard[position] = moveState
            let branchScore = scoreSubTree(board: childBoard, depth: depth + 1, alpha: alpha, beta: beta, maximizing: !maximizing, moveState: nextMoveState(board: childBoard))
            if maximizing
            {
                score = max(score, branchScore)
                alpha = max(alpha, score)
            }
            else
            {
                score = min(score, branchScore)
                beta = min(beta, score)
            }
            if beta <= alpha
            {
                break
            }
        }

        return score
    }
    
    private func scoreTree(board: GameBoard, depth: Int, alpha: NodeScore, beta: NodeScore, moveState: GameBoard.State) -> [ScoreData]
    {
        // depth 0 cannot have terminal nodes (i.e. there is always at least one position to play)
        // depth 0 is always maximizing
        
        var score = NodeScore.LOSE
        var alpha = alpha
        var scoresData = [ScoreData]()
        
        for position in board.empties
        {
            var childBoard = board
            childBoard[position] = moveState
            let branchScore = scoreSubTree(board: childBoard, depth: depth + 1, alpha: alpha, beta: beta, maximizing: false, moveState: nextMoveState(board: childBoard))
            score = max(score, branchScore)
            alpha = max(alpha, score)
            scoresData.append(ScoreData(position: position, score: branchScore))
            if beta <= alpha
            {
                break
            }
        }
        
        return scoresData
    }
    
    private func generateNodeScore(board: GameBoard, maximizing: Bool) -> NodeScore
    {
        var score: NodeScore
        
        if board.hasWon
        {
            score = .WIN
        }
        else if board.hasTied
        {
            score = .TIE_MAX
        }
        else
        {
            score = .INDETERMINATE_MAX
        }
        
        if !maximizing
        {
            score = -score
        }
        
        return score
    }
    
    private func nextMoveState(board: GameBoard) -> GameBoard.State
    {
        switch board.lastMoveData.state
        {
        case .EMPTY:
            return .CROSS
        case .CROSS:
            return .NAUGHT
        case .NAUGHT:
            return .CROSS
        }
    }
    
    private func getPosition(board: GameBoard) -> GameBoard.Position
    {
        let state = nextMoveState(board: board)
        let scores = scoreTree(board: board, depth: 0, alpha: .LOSE, beta: .WIN, moveState: state)
        let maxScore = (scores.max { $0.score < $1.score })!.score
        let scoresArray = scores.filter { $0.score == maxScore }
        
        // Check if we have an immediate win or a blocking of the oppenent's win.
        // This does not improve AI play, but does make it appear to play more like a person would.
        for datum in scoresArray
        {
            var testBoard = board
            testBoard[datum.position] = state
            if testBoard.hasWon || testBoard.hasBlockedWin
            {
                return datum.position
            }
        }
        
        let position = scoresArray[Int(arc4random_uniform(UInt32(scoresArray.count)))].position

        return position
    }
    
    private let maxDepth: Int

    init(settings: Settings)
    {
        switch settings.boardSize
        {
        case .SIZE_3x3:
            self.maxDepth = 9
        case .SIZE_4x4:
            self.maxDepth = 7
        case .SIZE_5x5:
            self.maxDepth = 5
        default:
            self.maxDepth = 3
        }
    }
}




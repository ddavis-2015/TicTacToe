//
//  Game.swift
//  TicTacToe
//
//  Created by David Davis on 11/28/17.
//  Copyright © 2017 David Davis. All rights reserved.
//

import Foundation

class Game
{
    static let instance = Game()
    
    private init()
    {
        reset(withState: .IDLE)
    }
    
    private enum State
    {
        case IDLE
        case PLAYING
        case ENDED
    }
    
    private var _board: GameBoard!
    private var _currentPlayer: Player!
    private var _state: State!
    private var _settings: (first: Settings, second: Settings)!
    private var _players: (first: Player, second: Player)!
    
    var isPlaying: Bool
    {
        return _state == .PLAYING
    }
    
    var board: GameBoard
    {
        return _board
    }
    
    var currentPlayer: Player
    {
        return _currentPlayer
    }
    
    private func makeBoard(settings: Settings) -> GameBoard
    {
        switch settings.boardSize
        {
        case .SIZE_3x3:
            return GameBoard(stride: 3, levels: 1)
        case .SIZE_3x3x3:
            return GameBoard(stride: 3, levels: 3)
        case .SIZE_4x4:
            return GameBoard(stride: 4, levels: 1)
        case .SIZE_4x4x4:
            return GameBoard(stride: 4, levels: 4)
        case .SIZE_5x5:
            return GameBoard(stride: 5, levels: 1)
        case .SIZE_5x5x5:
            return GameBoard(stride: 5, levels: 5)
        }
    }
    
    private func reset(withState: State)
    {
        _settings = (Settings.first, Settings.second)
        
        _players = (PlayerFactory.makePlayer(settings: _settings.first), PlayerFactory.makePlayer(settings: _settings.second))
        _currentPlayer = _settings.first.playerMovesFirst ? _players.first : _players.second
        
        _board = makeBoard(settings: _settings.first)
     
        _state = withState
    }
    
    func newGame()
    {
        if _state == .PLAYING
        {
            DispatchQueue.main.async
            {
                [currentPlayer = self._currentPlayer] in
                    
                currentPlayer?.endTurn()
            }
        }
        reset(withState: .PLAYING)
        DispatchQueue.main.async
        {
            [currentPlayer = self._currentPlayer] in
            
            currentPlayer?.beginTurn()
        }
    }
    
    private func nextCurrentPlayer()
    {
        if _currentPlayer === _players.first
        {
            _currentPlayer = _players.second
        }
        else
        {
            _currentPlayer = _players.first
        }
    }
    
    private func processMove(position: GameBoard.Position)
    {
        if _currentPlayer.isFirst
        {
            _board[position] = .CROSS
        }
        else
        {
            _board[position] = .NAUGHT
        }
    }
    
    func submitMove(commit: Bool = false, position: GameBoard.Position)
    {
        guard _state == .PLAYING else
        {
            return
        }
        
        if commit
        {
            assert(_board[position] == .EMPTY)
            
            DispatchQueue.main.async
            {
                [currentPlayer = self._currentPlayer] in
                
                currentPlayer?.endTurn()
            }
            processMove(position: position)
            GameEvents.PLAYER_MOVE_COMMIT(position: position, player: _currentPlayer).postEvent()
            if _board.hasWon
            {
                GameEvents.GAME_WON(winPositions: _board.winPositions, player: _currentPlayer).postEvent()
                _state = .ENDED
            }
            else if _board.hasTied
            {
                GameEvents.GAME_TIE.postEvent()
                _state = .ENDED
            }
            else
            {
                nextCurrentPlayer()
                DispatchQueue.main.async
                {
                    [currentPlayer = self._currentPlayer] in

                    currentPlayer?.beginTurn()
                }
            }
        }
        else
        {
            GameEvents.PLAYER_MOVE(position: position, player: _currentPlayer).postEvent()
        }
    }
}

















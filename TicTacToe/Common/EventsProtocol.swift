//
//  GameEvents.swift
//  TicTacToe
//
//  Created by David Davis on 11/28/17.
//  Copyright © 2017 David Davis. All rights reserved.
//

import Foundation

protocol EventsProtocol
{
    static var EVENT_NAME: Notification.Name { get }
}

extension EventsProtocol
{
    private static var EVENT_KEY: String
    {
        return "Event"
    }
    
    static func getEvent(from: Notification) -> Self?
    {
        guard EVENT_NAME == from.name else
        {
            return nil
        }
        return from.userInfo?[EVENT_KEY] as? Self
    }
    
    private func makeNotification() -> Notification
    {
        return Notification(name: Self.EVENT_NAME, object: nil, userInfo: [Self.EVENT_KEY: self])
    }
    
    func postEvent()
    {
        DispatchQueue.main.async
        {
            NotificationCenter.default.post(self.makeNotification())
        }
    }
    
    typealias EventCallback = (Self) -> Void
    
    static func addObserver(token: inout Any?, callback: @escaping EventCallback)
    {
        token = NotificationCenter.default.addObserver(forName: EVENT_NAME, object: nil, queue: OperationQueue.main)
        {
            notification in
            
            assert(OperationQueue.current == OperationQueue.main)
            
            if let event = Self.getEvent(from: notification)
            {
                callback(event)
            }
        }
    }
    
    static func removeObserver(token: inout Any?)
    {
        guard token != nil else
        {
            return
        }
        NotificationCenter.default.removeObserver(token!)
        token = nil
    }
}

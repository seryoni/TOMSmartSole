//
//  EventsStore.swift
//  Hero
//
//  Created by Nissan Tsafrir on 25.8.2016.
//

import Foundation

class EventsStore {
    private var events: [PressureAlertEvent] = []
    
    var onDidAddEvent: (() -> ())?
    
    func itemAtIndex(index: Int) -> PressureAlertEvent {
        return events[index]
    }
    
    func addItem(event: PressureAlertEvent) {
        events.append(event)
        
        if let onDidAddEvent = onDidAddEvent {
            onDidAddEvent()
        }
    }
    
    
}
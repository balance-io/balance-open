//
//  PreferencesSecurityViewModel.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/18/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

protocol TimeServicesProtocol {
    var currentTime: Date? { get }
    var timeIntervals: [String] { get }
    func createInterval(for key: String) -> (from: Date, to: Date)?
}

extension TimeServicesProtocol {
    
    var intervals: [String: TimeInterval] {
        return [
            "15 Minutes" : TimeInterval.minute * Double(15),
            "30 Minutes" : TimeInterval.minute * Double(30),
            "45 Minutes" : TimeInterval.minute * Double(45),
            "50 Minutes" : TimeInterval.minute * Double(50),
            "1 Hour" : TimeInterval.hour,
            "2 Hour" : TimeInterval.hour * Double(2),
            "3 Hour" : TimeInterval.hour * Double(5)
        ]
    }
    
}

class TimeServices: TimeServicesProtocol {

    var currentTime: Date? {
        return Date()
    }
    
    var timeIntervals: [String] {
        return intervals.sortedByValue.map { $0.0 }
    }

    func createInterval(for key: String) -> (from: Date, to: Date)? {
        guard let timeInterval = intervals[key] else {
            return nil
        }
        
        let fromDate = Date()
        let toDate = fromDate.addingTimeInterval(timeInterval)
        
        return (from: fromDate, to: toDate)
    }
    
}

class PreferencesSecurityViewModel {
    
    let timeServices: TimeServicesProtocol
    
    var timeIntervals: [String] {
        return timeServices.timeIntervals
    }
    
    var currentTimeInterval: String {
        return timeIntervals[selectedTimeInterval]
    }
    
    var selectedTimeInterval: Int {
        return 0
    }
    
    init(timeServices: TimeServicesProtocol? = nil) {
        self.timeServices = timeServices ?? TimeServices()
    }
    
    func selectTimeInterval(at index: Int) {
        guard let selectedInterval = timeIntervals[safe: index],
            let interval = timeServices.createInterval(for: selectedInterval)
            else {
                print("Cant create interval for seleted option")
                return
        }
        
        print("From: \(interval.from)")
        print("To: \(interval.to)")
    }
    
}

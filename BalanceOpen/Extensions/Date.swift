//
//  Date.swift
//  Bal
//
//  Created by Benjamin Baron on 8/11/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

extension Date {
    
    static let dayInterval = 3600.0 * 24.0
    
    static func today(_ fromDate: Date = Date()) -> Date {
        let comps = (Calendar.current as NSCalendar).components([.year, .month, .day], from: fromDate)
        let date = Calendar.current.date(from: comps)!
        return date
    }
    
    static func yesterday(_ fromDate: Date = Date()) -> Date {
        let date = today(fromDate)
        let yesterday = date.addingTimeInterval(-dayInterval)
        return yesterday
    }
    
    static func tomorrow(_ fromDate: Date = Date()) -> Date {
        let date = today(fromDate)
        let tomorrow = date.addingTimeInterval(dayInterval)
        return tomorrow
    }
    
    // Follows system preference for first day of week
    static func firstDayOfWeek(_ fromDate: Date = Date()) -> Date {
        let weekday = Calendar.current.ordinality(of: .weekday, in: .weekOfYear, for: fromDate)!
        let interval = -dayInterval * Double(weekday - 1)
        let firstDayOfWeek = fromDate.addingTimeInterval(interval)
        return today(firstDayOfWeek)
    }
    
    static func firstOfMonth(_ fromDate: Date = Date()) -> Date {
        let comps = (Calendar.current as NSCalendar).components([.month, .year], from: fromDate)
        return Calendar.current.date(from: comps)!
    }
    
    static func endOfMonth(_ firstOfMonth: Date = Date()) -> Date {
        var monthComps = DateComponents()
        monthComps.month = 1
        let firstOfNextMonth = (Calendar.current as NSCalendar).date(byAdding: monthComps, to: firstOfMonth, options: [])!
        let firstOfNextMonthComps = (Calendar.current as NSCalendar).components([.month, .year], from: firstOfNextMonth)
        
        let endOfMonth = Calendar.current.date(from: firstOfNextMonthComps)!.addingTimeInterval(-1)
        
        return endOfMonth
    }
    
    static func firstOfYear(_ fromDate: Date = Date()) -> Date {
        let comps = (Calendar.current as NSCalendar).components([.year], from: fromDate)
        return Calendar.current.date(from: comps)!
    }
    
    var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    var isFirstDayOfWeek: Bool {
        let today = Date.today(self)
        let firstDayOfWeek = Date.firstDayOfWeek(self)
        return today == firstDayOfWeek
    }

    var isThisWeek: Bool {
        let calendar = Calendar.current
        let todayComps = (calendar as NSCalendar).components([.year, .weekOfYear], from: Date())
        let comps = (calendar as NSCalendar).components([.year, .weekOfYear], from: self)
        
        return todayComps.year == comps.year && todayComps.weekOfYear == comps.weekOfYear
    }
    
    var isLastWeek: Bool {
        let calendar = Calendar.current
        let todayComps = (calendar as NSCalendar).components([.year, .weekOfYear], from: Date())
        let comps = (calendar as NSCalendar).components([.year, .weekOfYear], from: self)
        
        return todayComps.year! == comps.year! && todayComps.weekOfYear! - 1 == comps.weekOfYear!
    }
    
    var isFirstDayOfMonth: Bool {
        let today = Date.today(self)
        let firstDayOfMonth = Date.firstOfMonth(self)
        return today == firstDayOfMonth
    }

    var isThisMonth: Bool {
        let calendar = Calendar.current
        let todayComps = (calendar as NSCalendar).components([.year, .month], from: Date())
        let comps = (calendar as NSCalendar).components([.year, .month], from: self)
        
        return todayComps.year == comps.year && todayComps.month == comps.month
    }

    var isLastMonth: Bool {
        let calendar = Calendar.current
        let todayComps = (calendar as NSCalendar).components([.year, .month], from: Date())
        let comps = (calendar as NSCalendar).components([.year, .month], from: self)
        
        return todayComps.year! == comps.year! && todayComps.month! - 1 == comps.month!
    }
    
    var isFirstDayOfYear: Bool {
        let today = Date.today(self)
        let firstDayOfYear = Date.firstOfYear(self)
        return today == firstDayOfYear
    }
    
    var isThisYear: Bool {
        let calendar = Calendar.current
        let todayComps = (calendar as NSCalendar).components([.year], from: Date())
        let comps = (calendar as NSCalendar).components([.year], from: self)
        
        return todayComps.year == comps.year
    }
    
    var isLastYear: Bool {
        let calendar = Calendar.current
        let todayComps = (calendar as NSCalendar).components([.year], from: Date())
        let comps = (calendar as NSCalendar).components([.year], from: self)
        
        return todayComps.year! - 1 == comps.year!
    }
}

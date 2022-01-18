//
//  Date+Ext.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 30.09.2021.
//

import Foundation

extension Date {
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int? {
        Calendar.current.dateComponents([.day], from: date, to: self).day
    }
    
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int? {
        Calendar.current.dateComponents([.hour], from: date, to: self).hour
    }
}

//
//  DateFormatterCache.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 29.09.2021.
//

import Foundation

enum DateFormatterType: String {
    case dateWithYear = "dd MMM yyyy"
    case dateWithYearAndTime = "dd MMM yyyy HH:mm"
    
    case dateWithISO8601TimeZone = "yyyy-MM-dd'T'HH:mm:ssZ"
}

enum DateFormatterCache {
    private static var cache = [String: DateFormatter]()
}

extension DateFormatterCache {
    static func getFormatter(type: DateFormatterType) -> DateFormatter {
        let format = type.rawValue
        
        if let cachedFormatter = cache[format] {
            return cachedFormatter
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        cache[format] = dateFormatter
        
        return dateFormatter
    }
}

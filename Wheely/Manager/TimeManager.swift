//
//  TimeManager.swift
//  Wheely
//
//  Created by 민현규 on 7/12/25.
//

import Foundation

enum TimeError: Error {
    case convertFail
}

class TimeManager {
    
    public static func convertToUTC(_ time: Date = .now) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC Timezone
        return formatter.string(from: time)
    }
    
    public static func convertToLocal(_ time: Date = .now) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = .autoupdatingCurrent // UTC Timezone
        return formatter.string(from: time)
    }
    
    public static func convertToISO(_ time: Date = .now) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: time)
    }
    
    public func convertToISO(_ time: Date = .now) -> String {
        return TimeManager.convertToISO(time)
    }
    /// Convert time expressed by String to Date.
    ///
    /// # Important:
    /// This method can convert String format is ISO8601.
    /// - Throws: Throws TimeError.convertFaild when failed to convert string to date.
    /// - Returns: Converted date.
    public static func convertISOToDate(_ time: String) throws -> Date {
        let formatter = ISO8601DateFormatter()
        let convertedDate = formatter.date(from: time)
        if let convertedDate = convertedDate {
            return convertedDate
        } else {
            throw TimeError.convertFail
        }
    }
    public func convertISOToDate(_ time: String) throws -> Date {
        return try TimeManager.convertISOToDate(time)
    }
}

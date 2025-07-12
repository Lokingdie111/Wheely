//
//  TimeManager.swift
//  Wheely
//
//  Created by 민현규 on 7/12/25.
//

import Foundation


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
    
}

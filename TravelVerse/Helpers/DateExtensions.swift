//
//  DateExtensions.swift
//  TravelVerse
//
//  Created by Bingbing Ma on 10/25/25.
//

import Foundation

extension Date {
    /// 格式化日期为字符串
    func formatted(style: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = style
        return formatter.string(from: self)
    }
    
    /// 获取日期范围字符串
    static func dateRangeString(from startDate: Date, to endDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)
        return "\(start) - \(end)"
    }
}

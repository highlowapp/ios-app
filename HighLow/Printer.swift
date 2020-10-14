//
//  Printer.swift
//  HighLow
//
//  Created by Caleb Hester on 7/29/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation

enum PrinterType {
    case normal
    case warning
    case error
}

func printer(_ item: Any, _ type: PrinterType = .normal) {
    switch type {
    case .warning:
        print("⚠️ ", terminator: "")
        break
    case .error:
        print("🛑 ", terminator: "")
        break
    default:
        print("🟢 ", terminator: "")
        break
    }
    
    print(item)
}

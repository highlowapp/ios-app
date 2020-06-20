//
//  Receiver.swift
//  HighLow
//
//  Created by Caleb Hester on 6/20/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation
import UIKit

class Receiver<T> {
    var resource: T?
    var onDataUpdate: (_ data: T) -> Void = { data in }
    
    init(_ onDataUpdate: @escaping (_ data: T) -> Void) {
        self.onDataUpdate = onDataUpdate
    }
}

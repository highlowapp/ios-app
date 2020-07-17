//
//  Resource.swift
//  HighLow
//
//  Created by Caleb Hester on 6/20/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation
import UIKit

class Resource<ValueType: DataObject> {
    private var value: ValueType
    private var receivers: [UUID : (ValueType) -> Void] = [:]
    
    init(_ value: ValueType) {
        self.value = value
    }
    
    func set(item: ValueType) {
        self.value.updateData(with: item)
        
        for receiver in receivers {
            receiver.value(self.value)
        }
    }
    
    func getItem() -> ValueType {
        return value
    }
 
    func registerReceiver<Obj: AnyObject>(_ receiver: Obj, onDataUpdate: @escaping (Obj, ValueType) -> Void) {
        let id = UUID()
        receivers[id] = { [weak self, weak receiver] value in
            guard let receiver = receiver else {
                self?.receivers[id] = nil
                return
            }
            
            onDataUpdate(receiver,  value)
        }
        
        guard let receiver = receivers[id] else {
            return
        }
        
        receiver(self.value)
    }
}


protocol DataObject: AnyObject {
    func updateData(with data: Self)
}

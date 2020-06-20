//
//  Resource.swift
//  HighLow
//
//  Created by Caleb Hester on 6/20/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation

class Resource<T: DataObject> {
    let item: T?
    var associatedRecievers: [Receiver<T>] = []
    
    init(_ item: T) {
        self.item = item
    }
    
    @discardableResult func set(item: T) -> T {
        self.item!.updateData(with: item)
        
        for receiver in associatedRecievers {
            receiver.onDataUpdate(withData: self.item!)
        }
        
        return self.item!
    }
    
    func getItem() -> T {
        return item!
    }
    
    func registerReceiver(_ receiver: Receiver<T>) {
        if !associatedRecievers.contains(receiver) {
            associatedRecievers.append(receiver)
        }
        receiver.onDataUpdate(withData: self.item!)
    }
    
    func deregisterReceiver(_ receiver: Receiver<T>) {
        if let index = associatedRecievers.firstIndex(of: receiver) {
            associatedRecievers.remove(at: index)
        }
    }
}

protocol DataObject: AnyObject {
    func updateData(with data: Self)
}

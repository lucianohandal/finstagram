//
//  Scheduling.swift
//  finstagram
//
//  Created by Luciano Handal on 2/23/21.
//

import Foundation
import UIKit
import Dispatch

class Scheduling{
    let queue = DispatchQueue(label: "com.example.queue")

    func now(_ closure: () -> Void) {
        closure()
    }

    func later(_ closure: @escaping () -> Void) {
        queue.asyncAfter(deadline: .now() + 2) {
            closure()
        }
    }
    
    
    let semaphore = DispatchSemaphore(value: 0).wait(timeout: .now() + 10)
}

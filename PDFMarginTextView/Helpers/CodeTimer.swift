//
//  KosTimer.swift
//  WKID
//
//  Created by JC Nolan on 11/21/17.
//  Copyright © 2017 Warnock-Becker. All rights reserved.
//

import Cocoa

class KosTimer: NSObject {
    
    static var foo: [String:Int] = [:]
    static var runSilent = false;
    
    static func timerC(name: String = "code", timedCode: () -> Void) -> Int {
        
        // cumulative Timer
        
        self.runSilent = true
        let foo2: Int = self.timer(name:name, timedCode:timedCode)
        if self.foo[name] == nil {foo[name] = 0;}
        self.foo[name] = foo[name]! + foo2
        self.runSilent = false
        return foo2
    }
    
    static func closeCTimers(name: String? = nil) {
        
        if (name == nil) {
            
            for (nname, nval) in self.foo {
                print("Runnning cumulative \( nname ) took \( String(describing: nval) ) milliseconds. ")
                self.foo.removeValue(forKey:nname)
            }
            
        } else {
            print("Runnning cumulative \(String(describing:  name )) took \( String(describing: self.foo[name!]) ) milliseconds. ")
            self.foo.removeValue(forKey:name!)
        }
    }
    
    static func timer(name: String = "code", timedCode: () -> Void) -> Int {
        
        let start = NSDate().timeIntervalSince1970
        // let start = Date()
        
        timedCode()
        
        // KosDebugManager.log.debug("Runnning \( name ) took \( Int(Date().timeIntervalSince(start)) ) seconds. ")
        
        let finish = NSDate().timeIntervalSince1970
        let duration = Int((finish-start)*1000)
        if self.runSilent == false {print("Runnning \( name ) took \( duration ) milliseconds. ")}
        return duration
    }
    
}

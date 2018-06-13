//
//  Utilities.swift
//  NoBurns
//
//  Created by Armin Spahic on 27/05/2018.
//  Copyright © 2018 Armin Spahic. All rights reserved.
//

import Foundation

class Utilities {
    
    func getStorage() -> UserDefaults {
        return UserDefaults.standard
    }
    
    func setSkinType(value: String) {
        let def = getStorage()
        def.set(value, forKey: DefaultKeys.skinTypeKey)
    }
    
    func getSkinType() -> String {
        let def = getStorage()
        if let result = def.string(forKey: DefaultKeys.skinTypeKey) {
        return result
        }
        return SkinType().type1
    }
    
}



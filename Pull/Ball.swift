//
//  Ball.swift
//  Pull
//
//  Created by Sunny Ouyang on 4/17/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import Foundation

enum side {
    case left
    case right
}

struct Ball {
    var timer: CFTimeInterval
    var side: side
}

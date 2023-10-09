//
//  File.swift
//  
//
//  Created by Vadim Zhuk on 24/09/2023.
//

import Foundation

extension CGPoint {
    func integral(withScaleFactor scaleFactor: CGFloat) -> CGPoint {
        guard scaleFactor > 0.0 else {
            return self
        }

        return CGPoint(x: round(self.x * scaleFactor) / scaleFactor,
                       y: round(self.y * scaleFactor) / scaleFactor)
    }
}

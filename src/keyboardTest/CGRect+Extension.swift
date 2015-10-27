// For License please refer to LICENSE file in the root of Persei project

import Foundation
import CoreGraphics

extension CGRect {
    init(boundingCenter center: CGPoint, radius: CGFloat) {
        assert(0 <= radius, "radius must be a positive value")
        
        self = CGRectInset(CGRect(origin: center, size: CGSizeZero), -radius, -radius)
    }
    
    var x: CGFloat {
        get {
            return self.origin.x
        }
        set {
            self = CGRectMake(newValue, self.minY, self.width, self.height)
        }
    }
    
    var y: CGFloat {
        get {
            return self.origin.y
        }
        set {
            self = CGRectMake(self.x, newValue, self.width, self.height)
        }
    }
    
    var width: CGFloat {
        get {
            return self.size.width
        }
        set {
            self = CGRectMake(self.x, self.width, newValue, self.height)
        }
    }
    
    var height: CGFloat {
        get {
            return self.size.height
        }
        set {
            self = CGRectMake(self.x, self.minY, self.width, newValue)
        }
    }
    
    
    var top: CGFloat {
        get {
            return self.origin.y
        }
        set {
            y = newValue
        }
    }
    
    var bottom: CGFloat {
        get {
            return self.origin.y + self.size.height
        }
        set {
            self = CGRectMake(x, newValue - height, width, height)
        }
    }
    
    var left: CGFloat {
        get {
            return self.origin.x
        }
        set {
            self.x = newValue
        }
    }
    
    var right: CGFloat {
        get {
            return x + width
        }
        set {
            self = CGRectMake(newValue - width, y, width, height)
        }
    }
    
    
    var midX: CGFloat {
        get {
            return self.x + self.width / 2
        }
        set {
            self = CGRectMake(newValue - width / 2, y, width, height)
        }
    }
    
    var midY: CGFloat {
        get {
            return self.y + self.height / 2
        }
        set {
            self = CGRectMake(x, newValue - height / 2, width, height)
        }
    }
}
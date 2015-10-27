import WatchKit

//
// Updatable WatchKit interface objects
//

extension WKInterfaceImage {
    func updateImageName(from old: String?, to new: String) {
        if old != new {
            setImageNamed(new)
        }
    }
    func updateImageData(from old: NSData?, to new: NSData) {
        if old != new {
            setImageData(new)
        }
    }
}

extension WKInterfaceLabel {
    func updateText(from old: String?, to new: String) {
        if old != new {
            setText(new)
        }
    }
    func updateTextColor(from old: UIColor?, to new: UIColor) {
        if old != new {
            setTextColor(new)
        }
    }
}

extension WKInterfaceGroup {
    func updateBGColor(from old: UIColor?, to new: UIColor) {
        if old != new {
            setBackgroundColor(new)
        }
    }
}

class WKUpdatableButton {
    private(set) var button: WKInterfaceButton
    private(set) var hidden: Bool
    
    init(_ button: WKInterfaceButton, defaultHidden: Bool) {
        self.button = button
        self.hidden = defaultHidden
    }
    
    func updateHidden(hidden: Bool) {
        if hidden != self.hidden {
            button.setHidden(hidden)
            self.hidden = hidden
        }
    }
}
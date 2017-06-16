import Cocoa

class PaintCodeButton: Button {
    
    var textDrawingFunction: TextButtonDrawingFunction? {
        didSet {
            self.needsDisplay = true
        }
    }
    
    var drawingFunction: ButtonDrawingFunction? {
        didSet {
            self.needsDisplay = true
        }
    }

    var buttonText = ""
    var buttonTextColor = NSColor.black
    var pressed = false
    var allowAction = true
    
//    private var pressed = false
    
    //
    // MARK: - Drawing -
    //
        
    override var isFlipped: Bool {
        return false
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if let textDrawingFunction = textDrawingFunction {
            textDrawingFunction(self.bounds, buttonText, !pressed, pressed, buttonTextColor)
        } else if let drawingFunction = drawingFunction {
            drawingFunction(self.bounds, !pressed, pressed)
        }
    }
    
    //
    // MARK: - User Interaction -
    //
    
    override func touchesBegan(with event: NSEvent) {
        if #available(OSX 10.12.2, *) {
            interactionBegan()
        }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        interactionBegan()
    }
    
    fileprivate func interactionBegan() {
        pressed = true
        self.needsDisplay = true
    }
    
    override func touchesEnded(with event: NSEvent) {
        if #available(OSX 10.12.2, *) {
            if let touch = event.touches(matching: .ended, in: self).first {
                let location = touch.location(in: self)
                interactionEnded(location: location)
            }
        }
    }
    
    override func touchesCancelled(with event: NSEvent) {
        if #available(OSX 10.12.2, *) {
            if let touch = event.touches(matching: .cancelled, in: self).first {
                let location = touch.location(in: self)
                interactionEnded(location: location, canceled: true)
            }
        }
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        let location = self.convert(theEvent.locationInWindow, from: nil)
        interactionEnded(location: location)
    }
    
    fileprivate func interactionEnded(location: NSPoint, canceled: Bool = false) {
        pressed = false
        self.needsDisplay = true
        
        // Click handling
        let isInsideButton = NSPointInRect(location, self.bounds)
        if isInsideButton && allowAction && !canceled, let target = self.target {
            NSApp.sendAction(action!, to: target, from: self)
        }
    }
}


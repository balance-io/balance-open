import Cocoa

class HoverButton: NSButton {
    
    typealias DrawingBlock = (Void) -> (Void)
    
    fileprivate enum State {
        case original
        case hover
        case pressed
    }
    
    //
    // MARK: - Properties -
    //
    
    fileprivate var currentState = State.original
    
    fileprivate var currentBlock: DrawingBlock? {
        var block: DrawingBlock?
        switch currentState {
        case .original: block = originalBlock
        case .hover:    block = hoverBlock
        case .pressed:  block = pressedBlock
        }
        return block ?? originalBlock
    }
    
    fileprivate var trackingArea: NSTrackingArea!
    
    var originalBlock: DrawingBlock? {
        didSet {
            self.needsDisplay = true
        }
    }
    var hoverBlock: DrawingBlock?
    var pressedBlock : DrawingBlock?
    
    //
    // MARK: - Lifecycle -
    //
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        // set tracking area
        let opts: NSTrackingAreaOptions = ([.mouseEnteredAndExited, .activeAlways])
        trackingArea = NSTrackingArea(rect: bounds, options: opts, owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
    }
    
    //
    // MARK: - Drawing -
    //
    
    override var isFlipped: Bool {
        return false
    }
    
    override func draw(_ dirtyRect: NSRect) {
        currentBlock?()
    }
    
    //
    // MARK: - Mouse Events -
    //
    
    override func mouseEntered(with theEvent: NSEvent) {
        if self.isEnabled {
            currentState = .hover
            self.needsDisplay = true
        }
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        if self.isEnabled {
            currentState = .original
            self.needsDisplay = true
        }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        if self.isEnabled {
            currentState = .pressed
            self.needsDisplay = true
        }
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        if self.isEnabled {
            let pointInButton = self.convert(theEvent.locationInWindow, from: nil)
            let isInsideButton = NSPointInRect(pointInButton, self.bounds)
            currentState = isInsideButton ? .hover : .original
            self.needsDisplay = true
            
            // Click handling
            if isInsideButton, let target = self.target {
                NSApp.sendAction(action!, to: target, from: self)
            }
        }
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        // Set the correct button state when we get added to a window
        if let window = self.window {
            let locationInScreen = NSEvent.mouseLocation()
            let locationInWindow = window.convertFromScreen(NSRect(origin: locationInScreen, size: CGSize(width: 1, height: 1))).origin
            let pointInButton = self.convert(locationInWindow, from: nil)
            let isInsideButton = NSPointInRect(pointInButton, self.bounds)
            currentState = isInsideButton ? .hover : .original
            self.needsDisplay = true
        }
    }
}

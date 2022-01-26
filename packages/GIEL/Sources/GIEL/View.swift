//
//  File.swift
//  
//
//  Created by Anton on 23.02.2021.
//

import UIKit
import GLKit

public protocol ViewDelegate: NSObjectProtocol {
    
    func viewWillPrepare(_ view: View)
    func viewWillDestroy(_ view: View)
    
    func view(_ view: View, willCompileProgram program: GLuint)
    func view(_ view: View, didCompileProgram program: GLuint)
    
    func view(_ view: View, didRequireDrawIn rect: CGRect, program: GLuint)
}

@propertyWrapper
public final class ViewAnimatable<T: Animatable> {
    
    public weak var view: View?
    
    var value: T
    let duration: TimeInterval
    let key: String
    
    public init(_ value: T, duration: TimeInterval, key: String) {
        self.value = value
        self.duration = duration
        self.key = key
    }

    public var wrappedValue: T {
        get { value }
        set {
            guard value != newValue
            else {
                return
            }
            view?.run(animation(to: newValue), for: key)
        }
    }
    
    private func animation(to: T) -> Animation<T> {
        return Animation(from: value, to: to, duration: duration, block: { [weak self] in self?.value = $0 })
    }
}

open class View: UIView {
    
    enum ViewError: Error, LocalizedError, CustomStringConvertible {
        
        case createContextError
        
        var errorDescription: String? {
            switch self {
            case .createContextError: return "Can't create EAGLContext"
            }
        }
        
        var description: String { errorDescription ?? "\(self)" }
    }
    
    let display: Display
    var animations: [String : AnimationProtocol] = [:]
    let view: GLKView
    
    public var shaders: [Shader] { program.shaders }
    public let program: Program
    
    public private(set) weak var delegate: ViewDelegate? = nil
    
    public var renderTime: TimeInterval { display.time }
    public var isPaused: Bool { display.isPaused }
    
    public func play() {
        display.play()
    }
    
    public func pause() {
        display.pause()
    }
    
    public init(with frame: CGRect, shaders: [Shader], delegate aDelegate: ViewDelegate? = nil, renderOffset: TimeInterval = 0) throws {
        guard let context = EAGLContext(api: .openGLES2) else {
            throw ViewError.createContextError
        }
        
        display = Display(timeOffset: renderOffset)
        program = Program(shaders: shaders)
        view = GLKView(frame: frame, context: context)
        delegate = aDelegate
        
        super.init(frame: frame)
        
        view.drawableColorFormat = .RGBA8888
        view.drawableStencilFormat = .format8
        view.delegate = self
        view.drawableMultisample = .multisample4X
        view.drawableDepthFormat = .formatNone
        view.enableSetNeedsDisplay = false
        
        view.layer.isOpaque = true
        view.layer.masksToBounds = true
        
        display.delegate = self
        program.delegate = self
        
        isUserInteractionEnabled = false
        
        layer.masksToBounds = false
        layer.isOpaque = false
        
        addSubview(view)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        destroy()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        view.frame = bounds
    }
    
    public final func run<T>(_ animation: Animation<T>, for key: String) where T: Animatable {
        animation.prepare(with: display.time)
        animations[key] = animation
    }
    
    public final func load() throws {
        EAGLContext.setCurrent(view.context)
        delegate?.viewWillPrepare(self)
        try program.compile()
    }
    
    private func destroy() {
        delegate?.viewWillDestroy(self)
        program.deleteIfNeeded()
        display.invalidate()
        EAGLContext.setCurrent(nil)
    }
}

extension View: GLKViewDelegate {
    
    public func glkView(_ view: GLKView, drawIn rect: CGRect) {
        guard let glProgram = program.handle else {
            return
        }
        
        delegate?.view(self, didRequireDrawIn: rect, program: glProgram)
    }
}

extension View: DisplayDelegate {
    
    func displayDidRequireDraw(_ display: Display) {
        animations = animations.filter({ !$0.value.isFinished })
        animations.forEach({ $0.value.update(with: display.time) })
        view.display()
    }
}

extension View: ProgramDelegate {
    
    func program(_ program: Program, willCompileProgram handle: GLuint) {
        delegate?.view(self, willCompileProgram: handle)
    }
    
    func program(_ program: Program, didCompileProgram handle: GLuint) {
        delegate?.view(self, didCompileProgram: handle)
    }
}

//
//  Program.swift
//
//
//  Created by Anton on 22.02.2021.
//

import UIKit
import GLKit

protocol ProgramDelegate: NSObjectProtocol {
    
    func program(_ program: Program, willCompileProgram handle: GLuint)
    func program(_ program: Program, didCompileProgram handle: GLuint)
}

public final class Program {
    
    enum ProgramError: Error, LocalizedError, CustomStringConvertible {
        
        case createProgramError
        case validationError(log: String?)
        case linkError(log: String?)
        
        var errorDescription: String? {
            switch self {
            case .createProgramError: return "Can't create program"
            case .linkError(let log): return "Can't link program: \(log ?? "Empty log")"
            case .validationError(let log): return "Can't validate program: \(log ?? "Empty log")"
            }
        }
        
        var description: String { errorDescription ?? "\(self)" }
    }
    
    public private(set) var handle: GLuint? = nil
    
    let shaders: [Shader]
    
    weak var delegate: ProgramDelegate?
    
    init(shaders: [Shader]) {
        self.shaders = shaders
    }
    
    deinit {
        deleteIfNeeded()
    }
    
    func compile() throws {
        defer {
            shaders.forEach({ $0.deleteIfNeeded() })
        }
        
        handle = glCreateProgram()
        guard let handle = handle, handle > 0 else {
            throw ProgramError.createProgramError
        }
        
        for shader in shaders {
            try shader.attach(to: handle)
        }
        
        delegate?.program(self, willCompileProgram: handle)
        
        try link(handle)
        try? validate(handle)
        
        delegate?.program(self, didCompileProgram: handle)
        
        shaders.filter({ $0.handle != nil }).forEach({
            $0.detachIfNeeded(from: self)
            $0.deleteIfNeeded()
        })
    }
    
    func deleteIfNeeded() {
        guard let handle = handle else { return }
        glDeleteProgram(handle)
    }
    
    private func link(_ handle: GLuint) throws {
        glLinkProgram(handle)
        
        var length: GLsizei = 0
        glGetProgramiv(handle, GLenum(GL_INFO_LOG_LENGTH), &length)
        
        var log: String? = nil
        if length > 0 {
            var _log: [GLchar] = [GLchar](repeating: 0, count: Int(length))
            glGetProgramInfoLog(handle, length, &length, &_log)
            
            log = String(cString: _log)
        }
        
        var status: GLint = 0
        glGetProgramiv(handle, GLenum(GL_LINK_STATUS), &status)
        guard status == GL_TRUE else {
            throw ProgramError.linkError(log: log)
        }
        
        if let log = log {
            print("Shader validate log: \n\(log)")
        }
    }
    
    private func validate(_ handle: GLuint) throws {
        glValidateProgram(handle)
        
        var length: GLsizei = 0
        glGetProgramiv(handle, GLenum(GL_INFO_LOG_LENGTH), &length)
        
        var log: String? = nil
        if length > 0 {
            var _log: [GLchar] = [GLchar](repeating: 0, count: Int(length))
            glGetProgramInfoLog(handle, length, &length, &_log)
            
            log = String(cString: _log)
        }
        
        var status: GLint = 0
        glGetProgramiv(handle, GLenum(GL_VALIDATE_STATUS), &status)
        guard status == GL_TRUE else {
            throw ProgramError.validationError(log: log)
        }
        
        if let log = log {
            NSLog("Shader validation log: \(log)")
        }
    }
}

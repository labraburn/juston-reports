//
//  File.swift
//  
//
//  Created by Anton on 22.02.2021.
//

import UIKit
import GLKit

fileprivate extension URL {
    
    enum ShaderURLError: Error, LocalizedError, CustomStringConvertible {
        
        case unsupportedExtension(pathExtension: String)
        
        var errorDescription: String? {
            switch self {
            case .unsupportedExtension(let pathExtension): return "Shader with type \(pathExtension) is not supported yet. Should be .vsh or .fsh"
            }
        }
        
        var description: String { errorDescription ?? "\(self)" }
    }
    
    func shaderKind() throws -> Shader.ShaderKind {
        switch pathExtension {
        case "vsh": return .vertex
        case "fsh": return .fragment
        default: throw ShaderURLError.unsupportedExtension(pathExtension: pathExtension)
        }
    }
}

public final class Shader {
    
    public enum ShaderKind: Equatable {
        
        case fragment
        case vertex
        
        var GLint: GLint {
            switch self {
            case .fragment: return GL_FRAGMENT_SHADER
            case .vertex: return GL_VERTEX_SHADER
            }
        }
    }
    
    public enum ShaderError: Error, LocalizedError, CustomStringConvertible {
        
        case compilationError(log: String)
        case createShaderError
        
        public var errorDescription: String? {
            switch self {
            case .compilationError(let log): return "Can't compile shader: \(log)"
            case .createShaderError: return "Can't create shader"
            }
        }
        
        public var description: String { errorDescription ?? "\(self)" }
    }
    
    public private(set) var handle: GLuint? = nil
    
    let fileURL: URL
    let kind: ShaderKind
    
    public init(fileURL url: URL) throws {
        fileURL = url
        kind = try fileURL.shaderKind()
    }
    
    func compile() throws -> GLuint {
        handle = glCreateShader(GLenum(kind.GLint))
        guard let handle = handle, handle > 0 else {
            throw ShaderError.createShaderError
        }
        
        let source = try NSString(contentsOf: fileURL, encoding: String.Encoding.utf8.rawValue)
        
        let shaderStringUTF8 = source.utf8String
        var shaderStringUTF8Pointer: UnsafePointer<GLchar>? = UnsafePointer<GLchar>(shaderStringUTF8)
        var shaderStringLength = GLint(source.length)
        
        glShaderSource(handle, 1, &shaderStringUTF8Pointer, &shaderStringLength)
        glCompileShader(handle)
        
        var shaderCompilationDidSuccess: GLint = GLint()
        glGetShaderiv(handle, GLenum(GL_COMPILE_STATUS), &shaderCompilationDidSuccess)
        
        guard shaderCompilationDidSuccess == GL_TRUE else {
            var log = [GLchar](repeating: 0, count: 512)
            glGetShaderInfoLog(handle, GLsizei(log.count), nil, &log)
            throw ShaderError.compilationError(log: String(cString: log))
        }
        
        return handle
    }
    
    func attach(to program: GLuint) throws {
        let handle = try compile()
        glAttachShader(program, handle)
    }
    
    func detachIfNeeded(from program: Program) {
        guard
            let handle = handle,
            let program = program.handle
        else {
            return
        }
        
        glDetachShader(program, handle)
    }
    
    func deleteIfNeeded() {
        guard let handle = handle else {
            return
        }
        
        glDeleteShader(handle)
        self.handle = nil
    }
    
    deinit {
        deleteIfNeeded()
    }
}

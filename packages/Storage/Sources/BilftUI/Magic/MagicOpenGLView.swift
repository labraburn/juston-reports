//
//  Created by Anton Spivak.
//  

import UIKit
import GIEL
import GLKit

fileprivate extension Key {
    
    // glAttributes
    static let position = Key(rawValue: "u_position")
    
    // glUniforms
    static let resolution = Key(rawValue: "u_resolution")
    static let time = Key(rawValue: "u_time")
    static let tint_color = Key(rawValue: "u_tint_color")
}

class MagicOpenGLView: UIView {

    private lazy var glView: View = {
        guard let fsh = Bundle.module.url(forResource: "Magic", withExtension: "fsh"),
              let vsh = Bundle.module.url(forResource: "Magic", withExtension: "vsh")
        else {
            fatalError("Can' find MagicOpenGLView shaders.")
        }
        
        do {
            let offset = TimeInterval(Int.random(in: 2...2048))
            let shaders = try [Shader(fileURL: fsh), Shader(fileURL: vsh)]
            let view = try View(with: frame, shaders: shaders, delegate: self, renderOffset: offset)
            try view.load()
            
            return view
        } catch {
            fatalError(error.localizedDescription)
        }
    }()
    
    private var glUniforms: Values<Int32> = Values([.time : 0, .resolution : 0, .tint_color: 0])
    private var glAttributes: Values<Int32> = Values([.position : 0])
    private let glVertices: [GLfloat] = [0, 0, -1, 1, 1, 1, 1, -1, -1, -1, -1, 1]
    
    @ViewAnimatable(.white, duration: 0.32, key: "u_tint_color")
    var color: UIColor

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        glView.clipsToBounds = true
        addSubview(glView)
        _color.view = glView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        glView.frame = bounds
    }
}

extension MagicOpenGLView: ViewDelegate {
    
    func viewWillPrepare(_ view: View) {
        
    }
    
    func viewWillDestroy(_ view: View) {
        
    }
    
    func view(_ view: View, willCompileProgram program: GLuint) {
        
    }
    
    func view(_ view: View, didCompileProgram program: GLuint) {
        for (key, _) in glUniforms.allValues {
            glUniforms[key] = glGetUniformLocation(program, key.rawValue)
        }
        
        for (key, _) in glAttributes.allValues {
            glAttributes[key] = glGetAttribLocation(program, key.rawValue)
        }
        
        glVertexAttribPointer(GLuint(glAttributes[.position]), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, glVertices)
        glEnableVertexAttribArray(GLuint(glAttributes[.position]))
    }
    
    public func view(_ view: View, didRequireDrawIn rect: CGRect, program: GLuint) {
        glClearColor(1.0, 1.0, 1.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        glUseProgram(program)

        let scale = UIScreen.main.nativeScale
        glUniform2f(glUniforms[.resolution], Float(bounds.size.width * scale), Float(bounds.size.height * scale))
        glUniform1f(glUniforms[.time], GLfloat(view.renderTime))
        
        let colorRGB: (CGFloat, CGFloat, CGFloat) = color.rgb()
        glUniform3f(glUniforms[.tint_color], GLfloat(colorRGB.0), GLfloat(colorRGB.1), GLfloat(colorRGB.2))
        
        glDrawArrays(GLenum(GL_TRIANGLE_FAN), GLint(0), GLsizei(glVertices.count))
    }
}

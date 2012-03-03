//
//  ViewController.m
//  VideoCube
//
//  Created by John Brewer on 2/22/12.
//  Copyright (c) 2012 Jera Design LLC. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

// three xyz coordinates, three normal coordinates, two texture coordinates *
// four bytes per coordinate *
// six vertices per face *
// six faces per cube
GLfloat gCubeVertexData[(3 + 3 + 2) * 4 * 6 * 6] = 
{
// Data layout for each line below is:
//         position                    normal            texCoord0
//      X,     Y,     Z,           X,     Y,     Z,       S.     T,
     0.5f, -0.5f, -0.5f,        1.0f,  0.0f,  0.0f,     0.875, 1.0,
     0.5f,  0.5f, -0.5f,        1.0f,  0.0f,  0.0f,     0.125, 1.0,
     0.5f, -0.5f,  0.5f,        1.0f,  0.0f,  0.0f,     0.875, 0.0,
     0.5f, -0.5f,  0.5f,        1.0f,  0.0f,  0.0f,     0.875, 0.0,
     0.5f,  0.5f,  0.5f,        1.0f,  0.0f,  0.0f,     0.125, 0.0,
     0.5f,  0.5f, -0.5f,        1.0f,  0.0f,  0.0f,     0.125, 1.0,
    
     0.5f,  0.5f, -0.5f,        0.0f,  1.0f,  0.0f,     0.125, 1.0,
    -0.5f,  0.5f, -0.5f,        0.0f,  1.0f,  0.0f,     0.125, 0.0,
     0.5f,  0.5f,  0.5f,        0.0f,  1.0f,  0.0f,     0.875, 1.0,
     0.5f,  0.5f,  0.5f,        0.0f,  1.0f,  0.0f,     0.875, 1.0,
    -0.5f,  0.5f, -0.5f,        0.0f,  1.0f,  0.0f,     0.125, 0.0,
    -0.5f,  0.5f,  0.5f,        0.0f,  1.0f,  0.0f,     0.875, 0.0,
    
    -0.5f,  0.5f, -0.5f,       -1.0f,  0.0f,  0.0f,     0.125, 0.0,
    -0.5f, -0.5f, -0.5f,       -1.0f,  0.0f,  0.0f,     0.875, 0.0,
    -0.5f,  0.5f,  0.5f,       -1.0f,  0.0f,  0.0f,     0.125, 1.0,
    -0.5f,  0.5f,  0.5f,       -1.0f,  0.0f,  0.0f,     0.125, 1.0,
    -0.5f, -0.5f, -0.5f,       -1.0f,  0.0f,  0.0f,     0.875, 0.0,
    -0.5f, -0.5f,  0.5f,       -1.0f,  0.0f,  0.0f,     0.875, 1.0,
    
    -0.5f, -0.5f, -0.5f,        0.0f, -1.0f,  0.0f,     0.875, 0.0,
     0.5f, -0.5f, -0.5f,        0.0f, -1.0f,  0.0f,     0.875, 1.0,
    -0.5f, -0.5f,  0.5f,        0.0f, -1.0f,  0.0f,     0.125, 0.0,
    -0.5f, -0.5f,  0.5f,        0.0f, -1.0f,  0.0f,     0.125, 0.0,
     0.5f, -0.5f, -0.5f,        0.0f, -1.0f,  0.0f,     0.875, 1.0,
     0.5f, -0.5f,  0.5f,        0.0f, -1.0f,  0.0f,     0.125, 1.0,
    
     0.5f,  0.5f,  0.5f,        0.0f,  0.0f,  1.0f,     0.125, 1.0,
    -0.5f,  0.5f,  0.5f,        0.0f,  0.0f,  1.0f,     0.125, 0.0,
     0.5f, -0.5f,  0.5f,        0.0f,  0.0f,  1.0f,     0.875, 1.0,
     0.5f, -0.5f,  0.5f,        0.0f,  0.0f,  1.0f,     0.875, 1.0,
    -0.5f,  0.5f,  0.5f,        0.0f,  0.0f,  1.0f,     0.125, 0.0,
    -0.5f, -0.5f,  0.5f,        0.0f,  0.0f,  1.0f,     0.875, 0.0,
    
     0.5f, -0.5f, -0.5f,        0.0f,  0.0f, -1.0f,     0.875, 0.0,
    -0.5f, -0.5f, -0.5f,        0.0f,  0.0f, -1.0f,     0.875, 1.0,
     0.5f,  0.5f, -0.5f,        0.0f,  0.0f, -1.0f,     0.125, 0.0,
     0.5f,  0.5f, -0.5f,        0.0f,  0.0f, -1.0f,     0.125, 0.0,
    -0.5f, -0.5f, -0.5f,        0.0f,  0.0f, -1.0f,     0.875, 1.0,
    -0.5f,  0.5f, -0.5f,        0.0f,  0.0f, -1.0f,     0.125, 1.0,
};

@interface ViewController () {
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    AVCaptureDevice *_cameraDevice;
    AVCaptureSession *_session;
    
    CVOpenGLESTextureCacheRef _textureCache;
    CVOpenGLESTextureRef    _cvTexture;

    GLuint _textureId;
}
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

- (void)setupSimpleTexture;
@end

@implementation ViewController

@synthesize context = _context;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupCamera];
    [self turnCameraOn];
    [self setupGL];
}

- (void)viewDidUnload
{    
    [super viewDidUnload];
    
    [self tearDownGL];
    [self turnCameraOff];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
    
    glEnable(GL_DEPTH_TEST);
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);
    
//    glActiveTexture(GL_TEXTURE0);

//    [self setupSimpleTexture];

    CVReturn error = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault,
                                                  NULL,
                                                  (__bridge void*) self.context,
                                                  NULL,
                                                  &_textureCache);
    if (error != kCVReturnSuccess) {
        NSLog(@"CVOpenGLESTextureCacheCreate returned %d", error);
    }
}

- (void)setupSimpleTexture 
{
    // 2 x 2 Image, 3 bytes per pixel(R, G, B)
    static GLubyte pixels[4 * 3] = 
    {
        255, 0, 0, // red
        0, 255, 0, // green
        0, 0, 255, // blue
        255, 255, 0, // yellow
    };
    
    // Use tightly packed data
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

    // Generate a texture object
    glGenTextures(1, &_textureId);
    
    //Bind the texture object
    glBindTexture(GL_TEXTURE_2D, _textureId);
    
    // Load the texture
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 2, 2, 0, GL_RGB, GL_UNSIGNED_BYTE, pixels);
    
    // Set the filtering mode
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
        
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -2.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    
//    // Compute the model view matrix for the object rendered with ES2
//    GLKMatrix4 modelViewMatrix;
//    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
//    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
//    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    _rotation += self.timeSinceLastUpdate * 2.0f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArrayOES(_vertexArray);
        
    // Render the object again with ES2
    glUseProgram(_program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);

    glEnable(GL_TEXTURE_2D);
    glEnable(GL_TEXTURE0);
    glActiveTexture(GL_TEXTURE0);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); 
    glBindTexture(CVOpenGLESTextureGetTarget(_cvTexture), CVOpenGLESTextureGetName(_cvTexture));
    // Set the filtering mode
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glFlush();
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(_program, ATTRIB_NORMAL, "normal");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord0, "texCoord0");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_program, "texture");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Camera support

- (void)setupCamera {
    _cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices) {
        if (device.position == AVCaptureDevicePositionFront) {
            _cameraDevice = device;
            break;
        }
    }
    
}

- (void)turnCameraOn {
    NSError *error;
    _session = [[AVCaptureSession alloc] init];
    [_session beginConfiguration];
    [_session setSessionPreset:AVCaptureSessionPresetMedium];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:_cameraDevice
                                                                        error:&error];
    if (input == nil) {
        NSLog(@"%@", error);
    }
    
    [_session addInput:input];
    
    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    
    // Configure your output.
    //  dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:dispatch_get_main_queue() /* queue */];
    //  dispatch_release(queue);
    
    [output setAlwaysDiscardsLateVideoFrames:YES];

    // Specify the pixel format
    output.videoSettings = 
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] 
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];

    [_session addOutput:output];
    
    // Start the session running to start the flow of data
    [_session commitConfiguration];
    [_session startRunning];
}

- (void)turnCameraOff {
    [_session stopRunning];
    _session = nil;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    CVReturn error;
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    if (_cvTexture) {
        CFRelease(_cvTexture);
        _cvTexture = nil;
        CVOpenGLESTextureCacheFlush(_textureCache, 0);
    }
    glActiveTexture(GL_TEXTURE0);
    error = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                         _textureCache,
                                                         imageBuffer,
                                                         NULL,
                                                         GL_TEXTURE_2D,
                                                         GL_RGBA,
                                                         width,
                                                         height,
                                                         GL_BGRA,
                                                         GL_UNSIGNED_BYTE,
                                                         0,
                                                         &_cvTexture);
    if (error != kCVReturnSuccess) {
        NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage returned %d", error);
    }
    
    // Bind texture immediately, or you'll get occasional flicker.
    glBindTexture(CVOpenGLESTextureGetTarget(_cvTexture), CVOpenGLESTextureGetName(_cvTexture));
}


@end









































//
//  Shader.fsh
//  VideoCube
//
//  Created by John Brewer on 2/22/12.
//  Copyright (c) 2012 Jera Design LLC. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}

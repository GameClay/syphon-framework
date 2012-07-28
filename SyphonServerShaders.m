#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/CGLMacro.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

GLuint shader_compile(CGLContextObj cgl_ctx, const char* shader_src,
                      GLenum shader_type, GLuint version);
GLuint program_link(CGLContextObj cgl_ctx, GLuint vertShader, GLuint fragShader);

GLuint shader_compile(CGLContextObj cgl_ctx, const char* shader_src,
                      GLenum shader_type, GLuint version)
{
   GLuint ret = 0;
   if(shader_src != NULL)
   {
      int compile_success;
      GLuint gl_shader;
      GLchar* sourceString = NULL;
      GLsizei versionStringSize;

      versionStringSize = sizeof("#version 123\n");
      
      sourceString = malloc(strlen(shader_src) + versionStringSize);
      sprintf(sourceString, "#version %d\n%s", version, shader_src);
      
      gl_shader = glCreateShader(shader_type);
      glShaderSource(gl_shader, 1, (const GLchar**)&sourceString, 0);
      glCompileShader(gl_shader);
      glGetShaderiv(gl_shader, GL_COMPILE_STATUS, &compile_success);
      if(compile_success == GL_FALSE)
      {
         char* vertexInfoLog;
         int maxLength;
         glGetShaderiv(gl_shader, GL_INFO_LOG_LENGTH, &maxLength);
         vertexInfoLog = malloc(maxLength);
         
         glGetShaderInfoLog(gl_shader, maxLength, &maxLength, vertexInfoLog);
         NSLog(@"Error compiling shader: %s", vertexInfoLog);
         free(vertexInfoLog);
         
         glDeleteShader(gl_shader);
      }
      else
      {
         ret = gl_shader;
      }
      free(sourceString);
   }
   return ret;
}

GLuint program_link(CGLContextObj cgl_ctx, GLuint vertShader, GLuint fragShader)
{
   GLint link_success;
   GLuint program, ret = 0;
   
   program = glCreateProgram();
   glAttachShader(program, vertShader);
   glAttachShader(program, fragShader);
   
   /* Bind mesh attribute locations */
   glBindAttribLocation(program, 0, "InPosition");
   glBindAttribLocation(program, 1, "InTex0");
   
   glLinkProgram(program);
   
   /* Check link status */
   glGetProgramiv(program, GL_LINK_STATUS, &link_success);
   if(link_success == GL_TRUE)
   {
      ret = program;
   }
   else
   {
      char* linkInfoLog;
      int maxLength;
      
      glGetProgramiv(program, GL_INFO_LOG_LENGTH, &maxLength);
      linkInfoLog = malloc(maxLength);
      
      glGetProgramInfoLog(program, maxLength, &maxLength, linkInfoLog);
      NSLog(@"Error linking shaders: %s", linkInfoLog);
      free(linkInfoLog);
      
      glDeleteProgram(program);
   }
   return ret;
}


const char* syphonServerVertSrc =
"#line 96\n"
"\n"
"#if __VERSION__ >= 140\n"
"in vec2 InPosition;\n"
"in vec2 InTex0;\n"
"\n"
"out vec2 texCoord0;\n"
"#else\n"
"attribute vec2 InPosition;\n"
"attribute vec2 InTex0;\n"
"\n"
"varying vec2 texCoord0;\n"
"#endif\n"
"\n"
"void main() {\n"
"   gl_Position = vec4(InPosition, 0, 1);\n"
"   texCoord0 = InTex0;\n"
"}\n";

const char* syphonServer2DFragSrc =
"#line 116\n"
"\n"
"#if __VERSION__ >= 140\n"
"in vec2 texCoord0;\n"
"\n"
"out vec4 fragout0;\n"
"#else\n"
"varying vec2 texCoord0;\n"
"#endif\n"
"\n"
"uniform sampler2D tex0;"
"\n"
"void main() {\n"
"#if __VERSION__ >= 140\n"
"   fragout0 = texture(tex0, texCoord0);\n"
"#else\n"
"   gl_FragColor = texture2D(tex0, texCoord0);\n"
"#endif\n"
"}\n";


const char* syphonServerRectFragSrc =
"#line 138\n"
"\n"
"#if __VERSION__ >= 140\n"
"in vec2 texCoord0;\n"
"\n"
"out vec4 fragout0;\n"
"#else\n"
"varying vec2 texCoord0;\n"
"#endif\n"
"\n"
"uniform sampler2DRect tex0;"
"\n"
"void main() {\n"
"#if __VERSION__ >= 140\n"
"   fragout0 = texture(tex0, texCoord0);\n"
"#else\n"
"   gl_FragColor = texture2DRect(tex0, texCoord0);\n"
"#endif\n"
"}\n";
// End Hax


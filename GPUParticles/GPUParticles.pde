import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;

import com.jogamp.opengl.GL;
import com.jogamp.opengl.GL2ES2;

// MODE:
//   0, POINTS
//   1, LINES
//   2, TRIANGLES
int MODE = 0;
int nOfP = 10000;

PShader shader;
float angle;

float[] positions;
float[] colors;
int[] indices;

// Buffers
FloatBuffer posBuffer;
FloatBuffer colorBuffer;
IntBuffer indexBuffer;

//
int posVboId;
int colorVboId;
int indexVboId;

int posLoc;
int colorLoc;

PJOGL pgl;
GL2ES2 gl;

void setup() {
  size(800, 600, P3D);

  // shaders initialization
  shader = loadShader("frag.glsl", "vert.glsl");

  positions = new float[nOfP * 4];
  colors = new float[nOfP * 4];
  indices = new int[nOfP];

  posBuffer = allocateDirectFloatBuffer(nOfP * 4);
  colorBuffer = allocateDirectFloatBuffer(nOfP * 4);
  indexBuffer = allocateDirectIntBuffer(nOfP);

  pgl = (PJOGL) beginPGL();
  gl = pgl.gl.getGL2ES2();

  // Get GL ids for all the buffers
  IntBuffer intBuffer = IntBuffer.allocate(3);
  gl.glGenBuffers(3, intBuffer);
  posVboId = intBuffer.get(0);
  colorVboId = intBuffer.get(1);
  indexVboId = intBuffer.get(2);

  // Get the location of the attribute variables.
  shader.bind();
  posLoc = gl.glGetAttribLocation(shader.glProgram, "position");
  colorLoc = gl.glGetAttribLocation(shader.glProgram, "color");
  shader.unbind();

  endPGL();
  initGeometry();
}
void draw() {
  showFrameRate();
  background(0);

  translate(width / 2, height / 2);
  angle += 0.01;
  // rotateX(angle);
  // rotateY(0.2 * PI * cos(angle));
  // rotateZ(0.5 * PI * sin(angle));
  updateGeometry();
  glDraw();
}

void glDraw() {
  // Geometry transformations from Processing
  // are automatically passed to the shader
  // as long as the uniforms in the shader
  // have the right names.

  pgl = (PJOGL) beginPGL();
  gl = pgl.gl.getGL2ES2();

  shader.bind();
  gl.glEnableVertexAttribArray(posLoc);
  gl.glEnableVertexAttribArray(colorLoc);

  // Copy vertex data to VBOs
  gl.glBindBuffer(GL.GL_ARRAY_BUFFER, posVboId);
  gl.glBufferData(GL.GL_ARRAY_BUFFER, Float.BYTES * positions.length, posBuffer, GL.GL_DYNAMIC_DRAW);
  gl.glVertexAttribPointer(posLoc, 4, GL.GL_FLOAT, false, 4 * Float.BYTES, 0);

  gl.glBindBuffer(GL.GL_ARRAY_BUFFER, colorVboId);
  gl.glBufferData(GL.GL_ARRAY_BUFFER, Float.BYTES * colors.length, colorBuffer, GL.GL_DYNAMIC_DRAW);
  gl.glVertexAttribPointer(colorLoc, 4, GL.GL_FLOAT, false, 4 * Float.BYTES, 0);

  gl.glBindBuffer(GL.GL_ARRAY_BUFFER, 0);

  // Draw the triangle elements
  gl.glBindBuffer(PGL.ELEMENT_ARRAY_BUFFER, indexVboId);
  pgl.bufferData(PGL.ELEMENT_ARRAY_BUFFER, Integer.BYTES * indices.length, indexBuffer, GL.GL_DYNAMIC_DRAW);
  switch(MODE) {
    case 0:
      gl.glDrawElements(PGL.POINTS, colors.length / 4, GL.GL_UNSIGNED_INT, 0);
      break;
    case 1:
      gl.glDrawElements(PGL.LINES, colors.length / 4, GL.GL_UNSIGNED_INT, 0);
      break;
    case 2:
      gl.glDrawElements(PGL.TRIANGLES, indices.length, GL.GL_UNSIGNED_INT, 0);
      break;
    default:
      break;
  }
  gl.glBindBuffer(PGL.ELEMENT_ARRAY_BUFFER, 0);

  gl.glDisableVertexAttribArray(posLoc);
  gl.glDisableVertexAttribArray(colorLoc);
  shader.unbind();

  endPGL();
}
void initGeometry() {
  for (int i = 0; i < nOfP; i++) {
    int j = 4 * i;
    positions[j] = random(-300, 300);
    positions[j + 1] = random(-300, 300);
    positions[j + 2] = random(-300, 300);
    positions[j + 3] = 1;
    colors[j] = 1;
    colors[j + 1] = 1;
    colors[j + 2] = 1;
    colors[j + 3] = 1;
    indices[i] = i;
  }
}
void updateGeometry() {
  posBuffer.rewind();
  posBuffer.put(positions);
  posBuffer.rewind();

  colorBuffer.rewind();
  colorBuffer.put(colors);
  colorBuffer.rewind();

  indexBuffer.rewind();
  indexBuffer.put(indices);
  indexBuffer.rewind();
}
void keyPressed() {
  if (key == '1') {
    MODE = 0;
  } else if (key == '2') {
    MODE = 1;
  } else if (key == '3') {
    MODE = 2;
  }

  if (key == ' ') {
    initGeometry();
  }
}

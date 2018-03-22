
import processing.video.*;
import processing.opengl.*;

/*
COLOR DETECTION
Jeff Thompson | 2017 | jeffreythompson.org
So far, we've done a lot of processing to images, but
we haven't been extracting much information from them
(ie the "vision" part of "computer vision"). Detecting
things like faces is very complex and is the result of
decades of research. 
We'll start much more simply: detecing if a single color
is present in an image. This is useful if you want to track
a blue object in a space you know contains nothing else
blue, or know if someone is wearing the color green.
The main challenge to this approach is that light and
cameras in the real world are extremely variable. If we
wanted to use color detection in a more robust way, we'd
need to ensure our camera was calibrated for the task and
that we could control, or measure, the light temperature.
CHALLENGES:
+ You'll notice that our tracking is quite jumpy. One way to
  fix that is to perform a running average of the location, a
  process called "smoothing". Can you implement this in the code
  below? (Hint: you'll need an array of points, which is constantly
  shifted and averaged.)
+ In the BlobTracking example, we use brightness to create a
  binary image, from which blobs can be extracted. But we could
  also isolate color regions this way, and then run the blob
  tracking algorithm to find areas of color. Can you extend
  the code below to create a binary image, where the desired
  color is white and everything else black?
+ We can also find the very approximate center of this color
  blob by averaging the x/y location of all pixels with that 
  color – can you add that to our function below, returning
  the center instead of the first match? (Hint: create an
  ArrayList of PVectors to store all matches, then average them.)
*/

int colorToChange = -1;
color colorToMatch = color(255,0,0);
color colorToMatch2 = color(0,255,0);    // color to look for
float tolerance = 12;                   // how much wiggle-room is 
                                        // allowed in matching the color?
int calibrate = 1;  //show video or projection
//float con1,con2;  //attempt to make conditions

PVector T1, T2, T3, T4, B1, B2, B3, B4;
    
Capture webcam;

void setup() {
  //size(640,480,OPENGL);
  size(1280,960,P3D);

  // start the webcam
  String[] inputs = Capture.list();
  if (inputs.length == 0) {
    println("Couldn't detect any webcams connected!");
    exit();
  }
 
  webcam = new Capture(this, inputs[0]);
  webcam.start();

  //PVectors for the points that make up the box
  T1 = new PVector(0, 0, 75);
  T2 = new PVector(0, 0, 0);
  T3 = new PVector(75, 0, 0);
  T4 = new PVector(75, 0, 75);
  
  B1 = new PVector(0, 75, 75);
  B2 = new PVector(0, 75, 0);
  B3 = new PVector(75, 75, 0);
  B4 = new PVector(75, 75, 75);
}


void draw() {
  if (webcam.available()) {
    
    // read from the webcam
    webcam.read();
    if (calibrate == 1) {
      image(webcam, 0, 0);
    }
    
    PVector first = findColor(webcam, colorToMatch, tolerance);
    PVector second = findColor(webcam, colorToMatch2, tolerance);
    
    if (calibrate == 1) {
      fill(colorToMatch);
      stroke(255);
      strokeWeight(2);
      ellipse(first.x, first.y, 30,30);
      println(first);
      
      fill(colorToMatch2);
      stroke(255);
      strokeWeight(2);
      ellipse(second.x, second.y, 30,30);
      println(second);
    }


    if (calibrate == -1)  {  //show the projection/sketch 
      background(0);
      lights();
      //translate(width/2, height/2);
      translate((map(first.y,0, height,-160, width))+80,(first.x)-160);
      // first marker
      if (first.y < height/2) {
        //Top half
        //rotate towards
        rotateX( radians( first.x/2 ) );
      } else {
        //Bottom Half
        //rotate away
        rotateX(-radians( first.x/2 ) );
      }
      
      if (first.x < width/2) {
        rotateY( radians( first.y/2 ) );
      } else {
        rotateY( -radians( first.y/2) );
      }
      
      // second marker
            
      B3.x = map(second.x, 0, width, 0, 100);
      B3.y = map(second.y, 0, height, 0, 75);
      
      T1.y = map(second.y, 0, height, -50, 0);
      T1.x = map(second.x, 0, width, -45, 0);
      
      T4.y = map(second.y, 0, height, 0, 30);
      T4.x = map(second.x, 0, width, 0, 30);
      
      B2.x = map(second.y, 0, height, 0, 50);
      B2.y = map(second.x, 0, width, 0, 45);
      
          
      
      //////////////////////////////////////////////
      //Build the Cube                           //
      /////////////////////////////////////////////
      
      fill(129, 196, 177);
      noStroke();
      //stroke(100);
      //strokeWeight(1);
      
      pushMatrix();
 
      //////////////////////////////////////////BACK
      //////////////////////////////////////RED
      //fill(255,0,0);
      beginShape();
      vertex(T2.x, T2.y, T2.z);  //T2
      vertex(T3.x, T3.y, T3.z);  //T3
      vertex(B2.x, B2.y, B2.z);  //B2
      endShape(CLOSE); 
      
      //////////////////////////////////////////BACK
      //////////////////////////////////////WHITE
      //fill(255);
      beginShape();
      vertex(T3.x, T3.y, T3.z);  //T3
      vertex(B3.x, B3.y, B3.z);  //B3
      vertex(B2.x, B2.y, B2.z);  //B2
      endShape(CLOSE);
      
      /////////////////////////////////////////FRONT
      ////////////////////////////////////MAGENTA
      //fill(255,0,255);
      beginShape();
      vertex(T1.x, T1.y, T1.z);  //T1
      vertex(B4.x, B4.y, B4.z);  //B4
      vertex(B1.x, B1.y, B1.z);  //B1
      endShape(CLOSE);
      
      //////////////////////////////////////////FRONT
      //////////////////////////////////////PINK
      //fill(255,102,255);
      beginShape();
      vertex(T1.x, T1.y, T1.z);  //T1
      vertex(T4.x, T4.y, T4.z);  //T4
      vertex(B4.x, B4.y, B4.z);  //B4
      endShape(CLOSE);
      
      ///////////////////////////////////////BOTTOM
      ////////////////////////////////LIME GREEN 
      //fill(0,255,0);
      beginShape();
      vertex(B1.x, B1.y, B1.z);  //B1
      vertex(B2.x, B2.y, B2.z);  //B2
      vertex(B4.x, B4.y, B4.z);  //B4
      endShape(CLOSE);
      
      ///////////////////////////////////////BOTTOM
      ///////////////////////////////DARK GREEN
      //fill(102,102,0);
      beginShape();  
      vertex(B2.x, B2.y, B2.z);  //B2
      vertex(B3.x, B3.y, B3.z);  //B3
      vertex(B4.x, B4.y, B4.z);  //B4
      endShape(CLOSE);
      
      /////////////////////////////////////////// TOP
      //////////////////////////////////////CYAN
      //fill(0,255,255);
      beginShape(); 
      vertex(T1.x, T1.y, T1.z);  //T1
      vertex(T3.x, T3.y, T3.z);  //T3
      vertex(T4.x, T4.y, T4.z);  //T4
      endShape(CLOSE);
      ///////////////////////////////////////////TOP
      /////////////////////////////////CYAN/GREY
      //fill(0,102,102);
      beginShape();
      vertex(T1.x, T1.y, T1.z);  //T1
      vertex(T2.x, T2.y, T2.z);  //T2
      vertex(T3.x, T3.y, T3.z);  //T3
      endShape(CLOSE);
      
      ////////////////////////////////////////LEFT
      ////////////////////////////////////BLUE
      //fill(0,0,255);
      beginShape();
      vertex(B1.x, B1.y, B1.z);  //B1
      vertex(B2.x, B2.y, B2.z);  //B2
      vertex(T1.x, T1.y, T1.z);  //T1
      endShape(CLOSE);
      ////////////////////////////////////////LEFT
      ///////////////////////////////////YELLOW
      //fill(255,255,0);
      beginShape();
      vertex(B2.x, B2.y, B2.z);  //B2
      vertex(T2.x, T2.y, T2.z);  //T2
      vertex(T1.x, T1.y, T1.z);  //T1
      endShape(CLOSE);
      
      ///////////////////////////////////////RIGHT
      //////////////////////////////////BLACK
      //fill(0);
      beginShape();
      vertex(B4.x, B4.y, B4.z);  //B4
      vertex(B3.x, B3.y, B3.z);  //B3
      vertex(T3.x, T3.y, T3.z);  //T3
      endShape(CLOSE);
      
      ///////////////////////////////////////RIGHT
      /////////////////////////////////ORANGE
      //fill(255,128,0);
      beginShape();
      vertex(B4.x, B4.y, B4.z);  //B4
      vertex(T3.x, T3.y, T3.z);  //T3
      vertex(T4.x, T4.y, T4.z);  //T4
      endShape(CLOSE);
       
      popMatrix();
      }
  } 
}

////////////////////////////////////////////////////////////////////////
//calibrate color markers, set colors 
//to be tracked and change from defaults
///////////////////////////////////////////////////////////////////////
void mousePressed() {
  //calibrate color markers, set colors to be tracked and change from defaults  
  if (colorToChange > -1 && colorToChange == 1) {
    loadPixels();
    color c = get(mouseX, mouseY);
    colorToMatch = c;
    println("Calibrating Target 1 - R: " + red(c) + " G: " + green(c) + " B: " + blue(c));
  }
  if (colorToChange > -1 && colorToChange == 2) {
    loadPixels();
    color c = get(mouseX, mouseY);
    colorToMatch2 = c;
    println("Calibrating Target 2 - R: " + red(c) + " g: " + green(c) + " b: " + blue(c));    
  }
}

void keyPressed() {
  if (key == '1') {
    colorToChange = 1;
  } 
  else if (key == '2') {
    colorToChange = 2; 
  }
  
  if (key == 'c') {
    calibrate *= -1;
  }
}
void keyReleased() {
  if (key == '1' || key == '2'){
  colorToChange = -1; 
  }
}



///////////////////////////////////////////////////////////////////////
// find the first instance of a color and return the location
// by: Jeff Thompson
///////////////////////////////////////////////////////////////////////
PVector findColor(PImage in, color c, float tolerance) {
  
  // extract the rgb values for the color we want
  // to match
  float matchR = c >> 16 & 0xFF;
  float matchG = c >> 8 & 0xFF;
  float matchB = c & 0xFF;
  
  // in this case, we look across each row working
  // our way down the image – depending on your project,
  // you might want to scan across instead
  in.loadPixels();
  for (int y=0; y<in.height; y++) {
    for (int x=0; x<in.width; x++) {
      
      // get rgb values for the current pixel
      color current = in.pixels[y*in.width+x];
      float r = current >> 16 & 0xFF;
      float g = current >> 8 & 0xFF;
      float b = current & 0xFF;
      
      // if our color detection has no wiggle-room (it
      // either the color perfectly or isn't seen at all)
      // then it won't work very well in real-world conditions
      // to overcome this, we check if the RGB values are within
      // a certain range – if they are, we consider it a match
      if (r >= matchR-tolerance && r <=matchR+tolerance &&
          g >= matchG-tolerance && g <=matchG+tolerance &&
          b >= matchB-tolerance && b <=matchB+tolerance) {
          
            // if any match was detected, return the location
            // immediately (to avoid iterating the rest of 
            // the pixels unecessarily)
            
            // Normalize x by the window width
            float x_norm = float(in.width - x)/float(in.width) * width;
            // Normailze y by the window height
            float y_norm = float(in.height - y)/float(in.height) * height;
            // Return x_normalize (it's flipped) and reverse y coordinates for up/down
            return new PVector(x_norm, height - y_norm);
      }
    }
  }
  
  // if the color wasn't found, return "null" which
  // is like a blank value but not 0 (in some cases, like
  // this, we could return a location of -1,-1 which
  // would be offscreen, but this is better
  println("Object not found!");
  return new PVector (0.5 * width, 0.5 * height);
}
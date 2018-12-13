 import java.util.ArrayList;
import java.util.Collections;
import ketai.sensors.*;

KetaiSensor sensor;

float cursorX, cursorY;
PVector accelerometer;
boolean correct = false;

// LIGHT VARIABLES
boolean pressedDown = false;
boolean longTapped = false;
int lastTap = 0;
float light = 0; 
float proximity;
float proxSensorThreshold = 10; //you will need to change this per your device. //you will need to change this per your device.

private class Target
{
  int target = 0;
  int action = 0;
}

int trialCount = 5; //this will be set higher for the bakeoff
int trialIndex = 0;
ArrayList<Target> targets = new ArrayList<Target>();

int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
int countDownTimerWait = 0;

void setup() {
  size(880, 540); //you can change this to be fullscreen
  frameRate(1000);
  sensor = new KetaiSensor(this);
  sensor.start();
  accelerometer = new PVector();
  orientation(LANDSCAPE);

  rectMode(CENTER);
  textFont(createFont("Arial", 20)); //sets the font to Arial size 20
  textAlign(CENTER);

  for (int i=0; i<trialCount; i++)  //don't change this!
  {
    Target t = new Target();
    t.target = ((int)random(1000))%4;
    t.action = ((int)random(1000))%2;
    targets.add(t);
    println("created target with " + t.target + "," + t.action);
  }

  Collections.shuffle(targets); // randomize the order of the button;
}

void draw() {
  int index = trialIndex;

  //uncomment line below to see if sensors are updating
  //println("light val: " + light +", cursor accel vals: " + cursorX +"/" + cursorY);
  background(80); //background is light grey
  noStroke(); //no stroke

  countDownTimerWait--;

  //if (startTime == 0)
  //  rect(width/2, height/2, 150, 150);

  if (index>=targets.size() && !userDone)
  {
    userDone=true;
    finishTime = millis();
  }

  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, 50);
    text("User took " + nfc((finishTime-startTime)/1000f/trialCount, 1) + " sec per target", width/2, 150);
    return;
  }
  
  if (startTime > 0) {
    // Draw Rectangles
    for (int i=0; i<4; i++)
      drawTriangles(i);
    drawCurrent();
  
    fill(255);//white
    text("Trial " + (index+1) + " of " +trialCount, width/2, 540/2-50);
    text("Target #" + (targets.get(index).target)+1, width/2, 540/2);
  
    if (targets.get(index).action==0)
      text("SHORT", width/2, 150);
    else
      text("LONG", width/2, 150);
      
   
    // totally not drawing anything but oh well
    //lightTapping();
  } else {
    text("Tap to begin", width/2, 540/2-50);
  }
}

void mousePressed() {
  if (startTime == 0)
   startTime = millis(); 
}

void drawCurrent()
{
  fill(75, 229, 134);
  if (accelerometer.x < -2)
    triangle(width/2, 70, width/2+50, 120, width/2-50, 120);
  else if (accelerometer.y > 2)
    triangle(880-50, 500/2, 880-100, 500/2+50, 880-100, 500/2-50);
  else if (accelerometer.x > 2)
    triangle(width/2, 500-70, width/2+50, 500-120, width/2-50, 500-120);
  else{
    triangle(20, 500/2, 70, 500/2+50, 70, 500/2-50);
  }   
}

void drawTriangles(int i)
{
  int index = trialIndex;
  if (targets.get(index).target==i)
    fill(255, 255, 255);
  else
    fill(0, 0, 0);
  
  if (i==0){
    triangle(width/2, 70, width/2+50, 120, width/2-50, 120);
  }
  else if (i==1){
    triangle(880-50, 500/2, 880-100, 500/2+50, 880-100, 500/2-50);
  }
  else if (i==2){
    triangle(width/2, 500-70, width/2+50, 500-120, width/2-50, 500-120);
  }
  else{
    triangle(20, 500/2, 70, 500/2+50, 70, 500/2-50);
  }
}


void onAccelerometerEvent(float x, float y, float z)
{
  int index = trialIndex;
  // set accelerometer
  accelerometer.set(x, y, z);
  
  if (userDone || index>=targets.size())
    return;

  Target t = targets.get(index);

  if (t==null)
    return;
   if (countDownTimerWait<0)
   {
     // first target correct
     if (hitTest()==t.target)
     {
       correct = true;
       //println("First Target Hit");
       lightTapping();
     } else {
       correct = false;
       //print("current: " + hitTest());
       //print("supposed to be: " + t.target);
     }
   }
}

// light function
void lightTapping() {  
  Target t = targets.get(trialIndex);
  print(proximity);
  if (longTapped == true && proximity>0) {
    longTapped = false;
  } else if (!longTapped && !pressedDown && proximity==0) {
    println("pressed down");
    pressedDown = true;
    lastTap = millis();
  } else if (!longTapped && pressedDown && proximity>0) {
      println("lifted up - this is a short tap");
      if (!correct) {
        println("WRONG FIRST ROUND");
        if (trialIndex > 0)
          trialIndex--;
      } else if (t.action == 0) {
        println("SHORT TAP COMPLETE");
        trialIndex++;
      } else {
        println("TAPPED SHORT INSTEAD OF LONG");
        if (trialIndex > 0)
          trialIndex--;
      }
      pressedDown = false;
      lastTap = 0;
    } else if (!longTapped && pressedDown && millis() - lastTap > 500) {
      if (!correct) {
        println("WRONG FIRST ROUND");
        if (trialIndex > 0)
          trialIndex--;
      } else if (t.action == 1) {
        println("LONG TAP COMPLETE");
        trialIndex++;
      } else {
        println("TAPPED LONG INSTEAD OF SHORT");
        if (trialIndex > 0)
          trialIndex--;
      }
      lastTap = 0;
      longTapped = true;
      pressedDown = false;
  }
}  

// Check if target choose 4 hit
int hitTest() 
{
  if (accelerometer.x < -2)
    return 0;
  else if (accelerometer.y > 2)
    return 1;
  else if (accelerometer.x > 2)
    return 2;
  else if (accelerometer.y < -2)
    return 3;
  else   
    return -1;
}

void onProximityEvent(float v) // updates the proximity value
{
  proximity = v;
}

void onLightEvent(float v) //this just updates the light value
{
  light = v;
}

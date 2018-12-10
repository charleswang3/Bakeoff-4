 import java.util.ArrayList;
import java.util.Collections;
import ketai.sensors.*;

KetaiSensor sensor;

float cursorX, cursorY;
float light = 0; 
float proxSensorThreshold = 20; //you will need to change this per your device.
PVector accelerometer;

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
  frameRate(60);
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

  if (startTime == 0)
    startTime = millis();

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
  
  // Draw Rectangles
  for (int i=0; i<4; i++)
    drawTriangles(i);


  fill(255);//white
  text("Trial " + (index+1) + " of " +trialCount, width/2, 540/2-50);
  text("Target #" + (targets.get(index).target)+1, width/2, 540/2);

  if (targets.get(index).action==0)
    text("UP", width/2, 150);
  else
    text("DOWN", width/2, 150);
}

void drawTriangles(int i)
{
  int index = trialIndex;
  if (targets.get(index).target==i)
    fill(255, 255, 255);
  else
    fill(0, 0, 0);
  
  if (i==0){
    if (accelerometer.x < 0 && accelerometer.y >= -1 && accelerometer.y <= 1)
      fill(75, 229, 134);
    triangle(width/2, 70, width/2+50, 120, width/2-50, 120);
  }
  else if (i==1){
    if (accelerometer.y > 0 && accelerometer.x >= -1 && accelerometer.x <= 1)
      fill(75, 229, 134);
    triangle(880-50, 500/2, 880-100, 500/2+50, 880-100, 500/2-50);
  }
  else if (i==2){
    if (accelerometer.x > 0 && accelerometer.y >= -1 && accelerometer.y <= 1)
      fill(75, 229, 134);
    triangle(width/2, 500-70, width/2+50, 500-120, width/2-50, 500-120);
  }
  else{
    if (accelerometer.y < 0 && accelerometer.x >= -1 && accelerometer.x <= 1)
      fill(75, 229, 134);
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
       println("First Target Hit");
       /////////////////////////////
       /////////////////////////////
       /////////////////////////////
       // Add Choose 2 Conditionals here
       /////////////////////////////
       /////////////////////////////
       
       countDownTimerWait=30; //wait roughly 0.5 sec before allowing next trial
     }
     
   }
   
  
  //if (light<=proxSensorThreshold && abs(z-9.8)>4 && countDownTimerWait<0) //possible hit event
  //{
  //  if (hitTest()==t.target)//check if it is the right target
  //  {
  //    //println(z-9.8); use this to check z output!
  //    if (((z-9.8)>4 && t.action==0) || ((z-9.8)<-4 && t.action==1))
  //    {
  //      println("Right target, right z direction!");
  //      trialIndex++; //next trial!
  //    } else
  //    {
  //      if (trialIndex>0)
  //        trialIndex--; //move back one trial as penalty!
  //      println("right target, WRONG z direction!");
  //    }
  //    countDownTimerWait=30; //wait roughly 0.5 sec before allowing next trial
  //  } 
  //} else if (light<=proxSensorThreshold && countDownTimerWait<0 && hitTest()!=t.target)
  //{ 
  //  println("wrong round 1 action!"); 

  //  if (trialIndex>0)
  //    trialIndex--; //move back one trial as penalty!

  //  countDownTimerWait=30; //wait roughly 0.5 sec before allowing next trial
  //}
}
// Check if target choose 4 hit
int hitTest() 
{
  if (accelerometer.x < 0 && accelerometer.y >= -1 && accelerometer.y <= 1)
    return 0;
  else if (accelerometer.y > 0 && accelerometer.x >= -1 && accelerometer.x <= 1)
    return 1;
  else if (accelerometer.x > 0 && accelerometer.y >= -1 && accelerometer.y <= 1)
    return 2;
  else if (accelerometer.y < 0 && accelerometer.x >= -1 && accelerometer.x <= 1)
    return 3;
  else   
    return -1;
}


void onLightEvent(float v) //this just updates the light value
{
  light = v;
}

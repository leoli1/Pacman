int xDim = 32;
int yDim = 32;
int TILESIZE = 28;

final int WALLTILE = 1;
final int DOTTILE = 2;
final int PORTALTILE = 3;
final int GHOSTEXIT = 4;
final int GHOSTHOUSE = 5;
final int POWERPELLET = 6;

int startXGlobal;
int startX;
int startYGlobal;
int startY;

int[] spawnPoint;

int[][] levelMatrix = new int[yDim][xDim];
int[][] workMatrix;

void setTile(int x, int y,int type){
    
  if (workMatrix == null || x<0 || x>=xDim || y<0 || y>=yDim){
    println("Invalid x-y-coords/worldMatrix not setup");
    return;
  }
  workMatrix[y][x] = type;
}
public int getTile(int[][] matrix, int x, int y){
    
  if (matrix == null || x<0 || x>=xDim || y<0 || y>=yDim){
    println("Invalid x-y-coords/worldMatrix not setup");
    return 0;
  }
  return matrix[y][x];
}

void setup(){
  surface.setSize(TILESIZE*xDim,TILESIZE*yDim);
  workMatrix = getMatrixCopy(levelMatrix);
  for (int x=0;x<xDim;x++){
    setTile(x,0,WALLTILE);
    setTile(x,yDim-1,WALLTILE);
  }
  for (int y=0;y<yDim;y++){
    setTile(0,y,WALLTILE);
    setTile(xDim-1,y,WALLTILE);
  }
  
  apply();
}
void draw(){
  background(0);
  strokeWeight(1);
  for (int x=0;x<xDim;x++){
    for (int y=0;y<yDim;y++){
      color c = color(255);
      switch(getTile(workMatrix,x,y)){
        case (WALLTILE):
          c = color(0,0,150);
          break;
         case (PORTALTILE):
          c = color(150,50,150);
          break;
         case (GHOSTHOUSE):
           c = color(255,0,0);
           break;
         case (GHOSTEXIT):
           c = color(255,0,255);
           break;
         case (POWERPELLET):
           c = color(255,255,0);
           break;
      }
      fill(c);
      rect(x*TILESIZE,y*TILESIZE,TILESIZE,TILESIZE);
    }
  }
  if (spawnPoint!=null){
    fill(color(0,255,0));
    rect(spawnPoint[0]*TILESIZE,spawnPoint[1]*TILESIZE,TILESIZE,TILESIZE);
  }
  strokeWeight(3);
  line(width/2,0,width/2,height);
  line(0,height/2,width,height/2);
}
void keyPressed(){
  if (key=='s'){
    if (spawnPoint==null){
      println("No SpawnPoint");
      return;
    }
    selectOutput("Select a file", "save");
  }
}
void save(File selection){
  if (selection==null)return;
  int lines = xDim +2;
  String[] data = new String[lines];
  data[0] = xDim+","+yDim;
  data[1] = spawnPoint[0]+","+spawnPoint[1];
  
  for (int y =2;y<yDim+2;y++){
    String line = "";
    for (int x=0;x<xDim;x++){
      line+= getTile(levelMatrix,x,y-2);
      if (x<xDim-1)line+=";";
    }
    data[y] = line;
  }
  
  
  saveStrings(selection.getAbsolutePath(),data);
  
}

int getTile(){
  if (keyPressed){
    if (key=='g') return GHOSTHOUSE;
    if (key=='e') return GHOSTEXIT;
    if (key=='p') return POWERPELLET;
  }
  return WALLTILE;
  
}
void mousePressed(){
  workMatrix = getMatrixCopy(levelMatrix);
  int x = int(mouseX/TILESIZE);
  int y = int(mouseY/TILESIZE);
  
  startX = x;
  startXGlobal = mouseX;
  startY = y;
  startYGlobal = mouseY;
  
  if (mouseButton == LEFT){
    setTile(x,y,getTile(levelMatrix,x,y)==getTile()?0:getTile());
  }
  if (mouseButton == RIGHT){
    spawnPoint = new int[]{x,y};
  }
}
void mouseReleased(){
  apply();
}
void mouseDragged(){
  if (mouseX<startXGlobal || mouseY<startYGlobal)return;
  int endX = int(mouseX/TILESIZE);
  int endY = int(mouseY/TILESIZE);
  
  
  for (int x = startX;x<=endX;x++){
    for (int y=startY;y<=endY;y++){
      setTile(x,y,getTile(levelMatrix,x,y)==getTile()?0:getTile());
    }
  }
  for (int x=0;x<xDim;x++){
    for (int y=0;y<yDim;y++){
      if (x>=startX && x<=endX && y>=startY && y<=endY) continue;
      setTile(x,y,getTile(levelMatrix,x,y));
    }
  }
}

void apply(){
  levelMatrix = getMatrixCopy(workMatrix);
}

int[][] getMatrixCopy(int[][] matrix){
  int[][] newMatrix = new int[matrix.length][matrix[0].length];
  for (int x=0;x<matrix[0].length;x++){
    for (int y = 0; y<matrix.length;y++){
      newMatrix[y][x] = matrix[y][x];
    }
  }
  return newMatrix;
}
final int WALLTILE = 1;
final int DOTTILE = 2;
final int PORTALTILE = 3;
final int GHOSTEXIT = 4;
final int GHOSTHOUSE = 5;
final int POWERPELLET = 6;

boolean testDot = false;

int[][] directions = new int[][]{getDirectionVector(0),getDirectionVector(1),getDirectionVector(2),getDirectionVector(3)};
class Level extends GameObject{
  private int[][] worldMatrix;
  public int xDim;
  public int yDim;
  public int[] spawnPoint;
  public ArrayList<int[]> powerPellets;
  public ArrayList<int[]> fruitPositions;
  
  public ArrayList<int[]> ghostHouse = new ArrayList<int[]>();
  public ArrayList<int[]> ghostExits = new ArrayList<int[]>();
  
  public int totalDots;
  public int dots;
  
  public GhostMode ghostMode = GhostMode.Scatter;
  public int ghostModePhase = 0;
  public long ghostModePhaseStart = 0;
  public long ghostModePhaseDuration = 25000;
  
  public boolean energizedMode = false;
  public long energizeStart;
  public long energizeDuration = 10000;
  public int ghostsKilled = 0;
  
  public Level(int[][] _worldMatrix){
    setMatrix(_worldMatrix);
  }
  
  void setupLevel(){
    dots = 0;
    fruitPositions = new ArrayList<int[]>();
    for(int x=0;x<xDim;x++){
      for (int y=0;y<yDim;y++){
        if ((dots<10 || !testDot) && getTile(x,y)==0 && (x!=spawnPoint[0] || y!=spawnPoint[1])){
          setTile(x,y,DOTTILE);
          dots += 1;
          
        }
        if (getTile(x,y)==GHOSTHOUSE){
          ghostHouse.add(new int[]{x,y});
          if (getTile(x,y+1)==WALLTILE && getTile(x,y+2)!=WALLTILE){
            fruitPositions.add(new int[]{x,y+2});
          }
        } else if (getTile(x,y)==GHOSTEXIT){
          ghostExits.add(new int[]{x,y});
        }
      }
    }
    totalDots = dots;
  }
  
  public int getTile(int x, int y){
    
    if (worldMatrix == null || x<0 || x>=xDim || y<0 || y>=yDim){
      //println("Invalid x-y-coords/worldMatrix not setup");
      return 0;
    }
    return worldMatrix[y][x];
  }
  public int getTile(int[] pos){
    return getTile(pos[0],pos[1]);
  }
  public void setTile(int x, int y,int type){
    
    if (worldMatrix == null || x<0 || x>=xDim || y<0 || y>=yDim){
      return;
    }
    if (getTile(x,y)==DOTTILE && type == 0){
      dots -= 1;
      
      for (int i = 1;i<3;i++){
        int d = totalDots*i/3;
        if (dots== d){
          if (activeFruits.size()==0) SpawnFruit();
        }
      }
      if (dots==0) NextLevel();
    }
    worldMatrix[y][x] = type;
  }
  public void setMatrix(int[][] _worldMatrix){
    worldMatrix = _worldMatrix;
    xDim = worldMatrix[0].length;
    yDim = worldMatrix.length;
  }
  
  public boolean isWalkable(int x, int y){
    int t = getTile(x,y);
    return t!=WALLTILE && t!=GHOSTEXIT && t!=GHOSTHOUSE;
  }
  public boolean isWalkableGhost(int x, int y){
    int t = getTile(x,y);
    return t!=WALLTILE;
  }
  public boolean isWalkableGhost(int[] pos){
    int t = getTile(pos);
    return t!=WALLTILE;
  }
  public boolean isWalkable(int[] pos){
    return isWalkable(pos[0],pos[1]);
  }
  public float[] getGlobalCoordinates(int[] pos){ // Center
    return new float[]{
      (pos[0]+0.5)*TILESIZE,(pos[1]+0.5)*TILESIZE+LEVEL_Y_OFFSET
    };
  }
  public float[] getGlobalCoordinates(int x, int y){ // Center
    return new float[]{
      (x+0.5)*TILESIZE,(y+0.5)*TILESIZE+LEVEL_Y_OFFSET
    };
  }
  public int[] getLevelCoordinates(float[] pos){
    return new int[]{
      int(pos[0]/TILESIZE),
      int((pos[1]-LEVEL_Y_OFFSET)/TILESIZE)
    };
  }
  public int[] getLevelCoordinates(float x, float y){
    return new int[]{
      int(x/TILESIZE),
      int((y-LEVEL_Y_OFFSET)/TILESIZE)
    };
  }
  public ArrayList<int[]> getNearFields(int[] pos){
    ArrayList<int[]> fields = new ArrayList<int[]>();
    for (int[] dir : directions){
      int[] newPos = new int[]{pos[0]+dir[0],pos[1]+dir[1]};
      if (newPos[0]<0 || newPos[1]<0 || newPos[0]>=xDim || newPos[1]>=yDim) continue;
      if (isWalkable(newPos)) fields.add(newPos);
    }
    return fields;
  }
  public ArrayList<int[]> getNearFieldsGhost(int[] pos){
    ArrayList<int[]> fields = new ArrayList<int[]>();
    for (int[] dir : directions){
      int[] newPos = new int[]{pos[0]+dir[0],pos[1]+dir[1]};
      if (newPos[0]<0 || newPos[1]<0 || newPos[0]>=xDim || newPos[1]>=yDim) continue;
      if (isWalkableGhost(newPos)) fields.add(newPos);
    }
    return fields;
  }
  
  public boolean pointInLevel(int[] pos){
    return !(pos[0]<0 || pos[1]<0 || pos[0]>=xDim || pos[1]>=yDim);
  }
  
  public void ActivateEnergizedMode(){
    if (!energizedMode)
      ghostsKilled = 0;
    energizedMode = true;
    energizeStart = millis();
    ghostModePhaseStart += energizeDuration;
  }
  public void EndEnergizedMode(){
    energizedMode = false;
      
    for (Ghost g : ghosts){
      if (g.inHouse) g.LeaveHouse();
      g.isDead = false;
    }
  }
  
  public void NextLevel(){
    currentLevelIndex += 1;
    gameActive = false;
    thread("LoadNextLevel");
  }
  
  public void SpawnFruit(){
    float[] fpos = getGlobalCoordinates(fruitPositions.get(int(random(fruitPositions.size()))));
    activeFruits.add(findFruitForLevel(currentLevelIndex).newFruit(fpos));
  }
  
  public void EndGame(){
    gameActive = false;
    Text t = new Text("Game Over", width/2,height/2);
    NewHighscore();
    t.textSize = 50;
    t.textColor = color(255,255,3);
  }
  
  public void Update(){
    if (ghostModePhaseStart!=0 && millis()-ghostModePhaseStart>ghostModePhaseDuration){
      ghostModePhase += 1;
      if (ghostMode==GhostMode.Scatter){
        ghostModePhaseDuration = ghostModePhase<5 ? 20000 : 1000000000000000L;
        ghostMode = GhostMode.Chase;
      } else{
        ghostModePhaseDuration = 10000;
        ghostMode = GhostMode.Scatter;
      }
      ghostModePhaseStart = millis();
    }
    
    for (Ghost g : ghosts){
      int[] gpos = getLevelCoordinates(g.xPos,g.yPos);
      int[] ppos = getLevelCoordinates(player.xPos,player.yPos);
      if (gpos[0]==ppos[0] && gpos[1]==ppos[1] && !playerDead){
        if (energizedMode && !g.isDead){
          addScore(int(GHOSTKILLBASEPOINTS * pow(2,ghostsKilled)));
          ghostsKilled += 1;
          g.isDead = true;
        } else if (!energizedMode){
          lives -= 1;
          playerDead = true;
          if (lives == 0) EndGame();
        }
      }
    }
    if (energizedMode && millis()-energizeStart>energizeDuration){
      EndEnergizedMode();
    }
  }
  
  public void RespawnPlayer(){
    for (Ghost g: ghosts){
      gameObjects.remove(g);
    }
    float[] pos = currentLevel.getGlobalCoordinates(spawnPoint);
    player.xPos = pos[0];
    player.yPos = pos[1];
    playerDead = false;
    player.diam = player.startDiam;
    spawnGhosts();
    ghostMode = GhostMode.Scatter;
    ghostModePhase = 0;
    ghostModePhaseStart = GAMESTART = millis();
    GAMESTART = 0;
    ghostModePhaseStart = 0;
    ghostModePhaseDuration = 10000;
    player.direction=2;
  }
  
  public void Render(){
    for(int x=0;x<xDim;x++){
      for (int y=0;y<yDim;y++){
        int xPos = x*TILESIZE;
        int yPos = y*TILESIZE+LEVEL_Y_OFFSET;
        stroke(color(0,255,0));
        switch (getTile(x,y)){
          case (GHOSTEXIT):
            stroke(color(255,100,255));
          case (GHOSTHOUSE):
          case (WALLTILE):
            for (int[] dir: directions){
              int[][] neighbors = new int[2][2];
              /*int i = 0;
              for (int[]dir2:directions){
                if (dir==dir2)continue;
                if (abs(dir[0]+dir2[0])==1 && abs(dir[1]+dir2[1])==1){
                  neighbors[i] = dir2;
                  i+=1;
                }
              }*/
              int newX = x+dir[0];
              int newY = y+dir[1];
              
              if (isWalkable(newX,newY)){
                float startX = dir[0]==0 ? xPos : xPos+0.5*TILESIZE*(1+dir[0]);
                float endX = dir[0]==0 ? xPos+TILESIZE : xPos+0.5*TILESIZE*(1+dir[0]);
                float startY = dir[1]==0 ? yPos : yPos+0.5*TILESIZE*(1+dir[1]);
                float endY = dir[1]==0 ? yPos+TILESIZE : yPos+0.5*TILESIZE*(1+dir[1]);
                line(startX,startY,endX,endY);
              }
            }
            break;
          case (DOTTILE):
            fill(color(200,200,0));
            stroke(color(200,200,0));
            ellipse(xPos+0.5*TILESIZE,yPos+0.5*TILESIZE,7,7);
            break;
         case POWERPELLET:
           fill(color(255,255,200));
           noStroke();
           float waveEffect = 2*sin(millis()/100.0);
           ellipse(xPos+0.5*TILESIZE,yPos+0.5*TILESIZE,14+waveEffect,14+waveEffect);
        }
      }
    }
    stroke(0);
  }
}

void NewHighscore(){
  menuButton.isActive = true;
  if (highscores.size()<10 || score>highscores.get(9).points){
    highscores.add(new Highscore("x",score));
    SortHighscores();
    if (highscores.size()>10){
      highscores.remove(10);
    }
    SaveHighscores();
    Text t = new Text("New Highscore", width/2,height/2-100);
    t.textSize = 50;
    t.textColor = color(255,255,3);
  }
}
void LoadNextLevel(){
  try {
    Level nextLevel = LoadLevel("Level/"+levelNames[currentLevelIndex]);
    if (nextLevel!=null){
      gameObjects = new ArrayList<GameObject>();
      activeFruits = new ArrayList<Fruit>();
      currentLevel = nextLevel;
      currentLevel.RespawnPlayer();
      gameObjects.add(player);
      gameObjects.add(currentLevel);
      delay(1000);
      gameActive = false;
      startTimerStart = millis();
      intro=true;
      //sound.introSound.play();
    }
  } catch (Exception e){
    println("gewonnen");
    NewHighscore();
    
  }
}

Level LoadLevel(String fileName){
  String[] input = loadStrings(fileName);
  
  int[] dims = new int[2];
  String[] dimsIn = split(input[0],",");
  dims[0] = int(dimsIn[0]);
  dims[1] = int(dimsIn[1]);
  
  int[] spawnPoint = new int[2];
  String[] spawnPointIn = split(input[1],",");
  spawnPoint[0] = int(spawnPointIn[0]);
  spawnPoint[1] = int(spawnPointIn[1]);
  
  int[][] levelMatrix = new int[dims[1]][dims[0]];
  for (int i = 2;i<dims[1]+2;i++){
    String[] row = split(input[i],";");
    for (int x=0;x<dims[0];x++){
      levelMatrix[i-2][x] = int(row[x]);
    }
  }
  Level l = new Level(levelMatrix);
  l.spawnPoint = spawnPoint;
  l.setupLevel();
  
  return l;
}
class Player extends GameObject {
  
  int direction = 2; // 0 right, 1 down, 2 left, 3 top
  
  float speed=TILESIZE*5;
  
  int inputQueue = -1;
  
  float startDiam = TILESIZE-4; // Startdurchmesser
  float diam; // Durchmesser
  float mouthAngle = 0; // Mundwinkel

  int animationIndex = 0;
  int animationLength = 18;
  
  Player(){
    diam = startDiam;
  }
  public void Update() {
    animationIndex ++;
  
    int x = currentLevel.getLevelCoordinates(xPos,yPos)[0];
    int y = currentLevel.getLevelCoordinates(xPos,yPos)[1];
    if (canMove()) {
      int[] dirVec = getDirectionVector(direction);
      if (dirVec[0]==0){
        xPos = (x+0.5)*TILESIZE;
        yPos += dirVec[1]*speed*deltaTime;
      } else if (dirVec[1]==0){
        yPos = (y+0.5)*TILESIZE+LEVEL_Y_OFFSET;
        xPos += dirVec[0]*speed*deltaTime;
      }
    }
    
    TryToTurn();
    
    if (currentLevel.getTile(x,y)==DOTTILE){
      currentLevel.setTile(x,y,0);
      addScore(DOTPOINTS);
     // if (!sound.wakkaSoundPlaying())
    //    sound.playWakkaSound();
    } else if (currentLevel.getTile(x,y)==POWERPELLET){
      currentLevel.ActivateEnergizedMode();
      addScore(POWERPELLETPOINTS);
      currentLevel.setTile(x,y,0);
    }
    
    if (xPos<=-TILESIZE/2){
      xPos = (currentLevel.xDim+0.5)*TILESIZE-1;
    }
    if (xPos>=(currentLevel.xDim+0.5)*TILESIZE){
      xPos = -TILESIZE/2+1;
    }
    if (yPos<=LEVEL_Y_OFFSET-TILESIZE/2){
      yPos = LEVEL_Y_OFFSET+(currentLevel.yDim+0.5)*TILESIZE-1;
    }
    if (yPos>=LEVEL_Y_OFFSET+(currentLevel.yDim+0.5)*TILESIZE){
      yPos = LEVEL_Y_OFFSET-TILESIZE/2+1;
    }
  }
  void TryToTurn(){ // Kann sich Pacman in die Richtung, die durch den Spieler-Input vorgegeben wurde, bewegen?
    if (inputQueue==-1) return;
    int newDir = getDirection(inputQueue);
    if (newDir==-1)return;
    
    if (xPos<0 || xPos> currentLevel.xDim*TILESIZE)return;
    if (yPos<LEVEL_Y_OFFSET || yPos> currentLevel.yDim*TILESIZE+LEVEL_Y_OFFSET)return;
    
    int x = int(xPos/TILESIZE);
    int y = int((yPos-LEVEL_Y_OFFSET)/TILESIZE);
    
    float[] tileCenter = currentLevel.getGlobalCoordinates(new int[]{x, y});
    
    int[] dirVec = getDirectionVector(newDir);
    int nextX = x+dirVec[0];
    int nextY = y+dirVec[1];
    
    int nextNormalX = x+getDirectionVector(direction)[0];
    int nextNormalY = y+getDirectionVector(direction)[1];
    if (!currentLevel.isWalkable(nextNormalX,nextNormalY)){
      switch(direction){
        case 0:
          if (xPos>tileCenter[0]) xPos=tileCenter[0];
          break;
        case 1:
          if (yPos>tileCenter[1]) yPos=tileCenter[1];
          break;
        case 2:
          if (xPos<tileCenter[0]) xPos=tileCenter[0];
          break;
        case 3:
          if (yPos<tileCenter[1]) yPos=tileCenter[1];
          break;
      }
    }
    
    if (currentLevel.isWalkable(nextX,nextY)){
      float distToCenterSQD = dirVec[0]==0 ? abs(tileCenter[0]-xPos) : abs(tileCenter[1]-yPos);//(tileCenter[0]-xPos)*(tileCenter[0]-xPos)+(tileCenter[1]-yPos)*(tileCenter[1]-yPos);
      if (distToCenterSQD<4){
         direction = newDir;
         inputQueue = -1;
      }
    }
  }

  boolean canMove() { // kann sich der Spieler weiter in die aktuelle Richtung bewegen?
    int x = int(xPos/TILESIZE);
    int y = int((yPos-LEVEL_Y_OFFSET)/TILESIZE);

    int[] dirVec = getDirectionVector(direction);
    int nextX = x+dirVec[0];
    int nextY = y+dirVec[1];
    if (currentLevel.isWalkable(nextX, nextY)) {
      return true;
    } else {
      float[] tileCenter = currentLevel.getGlobalCoordinates(new int[]{x, y});
      switch (direction) {
      case 0:
        return xPos<tileCenter[0];
      case 1:
        return yPos<tileCenter[1];
      case 2:
        return xPos>tileCenter[0];
      case 3:
        return yPos>tileCenter[1];
      }
    }
    return false;
  }

  public void Render() {
    if (inMenu) {
      animationIndex ++;
      int[] dirVec = getDirectionVector(direction);  
      xPos += dirVec[0]*speed*deltaTime*1.5;
      yPos += dirVec[1]*speed*deltaTime*1.5;
    }
    noStroke();
    fill(color(255, 255, 3));
    float angleOffset = direction*HALF_PI;
    int index = animationIndex%animationLength;
    float rat = (2*index)/float(animationLength);
    if (index>animationLength/2)
      rat = 2-rat;
    if (direction==-1)rat=0;
    float openAngle = QUARTER_PI * rat*0.75;
    if (!playerDead) mouthAngle = openAngle;
    //arc(xPos, yPos, diam, diam, openAngle+angleOffset, TWO_PI-openAngle+angleOffset, PIE);
    arc(xPos, yPos, startDiam, startDiam, mouthAngle+angleOffset, TWO_PI-mouthAngle+angleOffset, PIE);
    if (playerDead) mouthAngle += deltaTime*2.5;//diam -= deltaTime*30;
  }
}

int getDirection(int input){
  switch(input){
    case RIGHT:
      return 0;
    case DOWN:
      return 1;
    case LEFT:
      return 2;
    case UP:
      return 3;
  }
  return -1;
}
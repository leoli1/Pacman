class PinkGhost extends Ghost{
  
  public PinkGhost(){
    ghostColor = color(255, 176, 255);
    timeToLeaveHouse = 2000;
    scatterTargetPoint = new int[]{0,0};
  }
  
  int[] findTargetPoint(){
    int[] playerpos = currentLevel.getLevelCoordinates(new float[]{player.xPos,player.yPos});
    int[] playerDir = getDirectionVector(player.direction);
    
    int[] newPos = new int[]{playerpos[0]+4*playerDir[0],playerpos[1]+4*playerDir[1]};
    return newPos;
   /* if (currentLevel.pointInLevel(newPos) && currentLevel.isWalkable(newPos)) return newPos;
    else{
      for (int i = -1;i<=1;i++){
        newPos = new int[]{playerpos[0]+4*playerDir[0]+(playerDir[0]==0?i:0),playerpos[1]+4*playerDir[1]+(playerDir[1]==0?i:0)};
        if (currentLevel.pointInLevel(newPos) && currentLevel.isWalkable(newPos)) return newPos;
      }
      for (int i = 3;i>=0;i--){
        newPos = new int[]{playerpos[0]+i*playerDir[0],playerpos[1]+i*playerDir[1]};
        if (currentLevel.pointInLevel(newPos) && currentLevel.isWalkable(newPos)) return newPos;
      }
    }
    return new int[]{0,0};*/
  }
}
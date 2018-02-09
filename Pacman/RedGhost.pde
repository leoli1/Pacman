class RedGhost extends Ghost{
  
  public RedGhost(){
    ghostColor = color(255, 0, 1);
    timeToLeaveHouse = 500;
    scatterTargetPoint = new int[]{currentLevel.xDim-1,0};
  }
  int[] findTargetPoint(){
     return currentLevel.getLevelCoordinates(player.xPos,player.yPos);
  }
}
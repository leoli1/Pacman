class OrangeGhost extends Ghost{
  
  public OrangeGhost(){
    ghostColor = color(254, 175, 72);
    timeToLeaveHouse = 7500;
    scatterTargetPoint = new int[]{0,currentLevel.yDim-1};
  }
  
  int[] findTargetPoint(){
    float distToPacSQD = (xPos-player.xPos)*(xPos-player.xPos)+(yPos-player.yPos)*(yPos-player.yPos);
    if (distToPacSQD>64){
      return currentLevel.getLevelCoordinates(player.xPos,player.yPos);
    } else {
      return scatterTargetPoint;
    }
  }
}
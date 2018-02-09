class BlueGhost extends Ghost{
  
  public BlueGhost(){
    ghostColor = color(0, 255, 255);
    timeToLeaveHouse = 6000;
    scatterTargetPoint = new int[]{currentLevel.xDim-1,currentLevel.yDim-1};
  }
  
  int[] findTargetPoint(){
    int[] playerpos = currentLevel.getLevelCoordinates(new float[]{player.xPos,player.yPos});
    int[] playerDir = getDirectionVector(player.direction);
    
    int[] newPos2 = new int[]{playerpos[0]+2*playerDir[0],playerpos[1]+2*playerDir[1]}; // 2 Felder vor Pacman in seiner Ausrichtung
    Ghost red = getGhost(GhostColor.Red);
    int[] redPos = currentLevel.getLevelCoordinates(red.xPos,red.yPos);
    int[] red_dir = new int []{newPos2[0]-redPos[0],newPos2[1]-redPos[1]}; // Richtung des roten Geistes zu newPos2
    return new int[]{redPos[0]+2*red_dir[0],redPos[1]+2*red_dir[1]}; // Der Zielpunkt ist der Punkt, der in dieser Richtung doppelt so weit entfernt liegt.
    
  }  
}
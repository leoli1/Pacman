enum GhostMode {
  Scatter, 
    Chase
}
enum GhostMovement {
  Pathfinding, 
  Distance
}
enum GhostColor{
  Pink,
  Red,
  Orange,
  Blue
}

abstract class Ghost extends GameObject { // Ghostklasse, beinhaltet: Bewegung/Rendering, die Zielsetzung der Bewegung geschieht in den Subklassen der für die verschiedenen Geister

  color ghostColor = color(255, 176, 255);
  color energizedColor = color(0,29,143);
  int timeToLeaveHouse = -1; // Zeit bis zum Verlassen des Hauses

  private float normalSpeed = TILESIZE*4.5; // Normale Geschwindigkeit, tatsächliche Geschwindigkeit wird in getSpeed() ermittlet
  GhostMovement ghostMovement; // Art der Bewegung: Pathfinding mithilfe einer Entfernungskarte oder einfach immer das Feld mit dem kürzesten (Luflinien) Abstand zum Zielpunkt

  float animationSpeed = 15; // Geschwindigkeit der Geister-Sinus-Kurven-Animation
  float animationOffset = random(0, 5)/5.0;

  boolean inHouse = true; // im Geisterhaus
  boolean isLeavingHouse = false; // beim Verlassen des Hauses

  private float[] targetPoint; // Zielpunkt

  int[] scatterTargetPoint; // zielpunkt in der Scatter-Phase: Eine Ecke des Spielfeldes abhängig vom Ghost

  long updateTargetPointDelay = 50; // Abstand zwischen zwei Updates des Zielpunktes
  long lastTargetUpdate = 0;

  public int[][] distanceMatrix;

  int[] direction = new int[]{0, 0};
  int[] newDirection = new int[]{0,0};
  
  GhostMode lastTileMode = GhostMode.Scatter; // Der Geistermodus zu dem Zeitpunkt, als der Geist auf dem letzten Feld war
  boolean lastTileEnergized = false; // War der Spieler im Energized-Mode, als der Geist auf dem letzten Feld war
  
  boolean isDead = false;

  Ghost() {
    ghostMovement = GhostMovement.Distance;
    findTargetPointInHouse();
  }

  void LeaveHouse() { // anfangen, das Haus zu verlassen
    targetPoint = currentLevel.getGlobalCoordinates(currentLevel.ghostExits.get(int(random(0, currentLevel.ghostExits.size()))));
    isLeavingHouse = true;
  }

  public float getSpeed(){ // ermittelt tatsächliche Geschwindigkeit
    float mul = 1;
    if (currentLevel.energizedMode){
      if (isDead) mul *= 3;
      else mul *= 0.5;
      if (inHouse) mul=1;
    }
    return mul*normalSpeed;
  }
  public color getColor(){ // farbe 
    if ((currentLevel.energizeStart+currentLevel.energizeDuration)-millis()<3000 && currentLevel.energizedMode && !isDead){
      int par = int(((currentLevel.energizeStart+currentLevel.energizeDuration)-millis()) / 300 % 2);
      return par==0 ? color(255) : energizedColor;
    }
    return currentLevel.energizedMode ? energizedColor : ghostColor;
  }
  void Update() {
    if (GAMESTART!=0 && millis()-GAMESTART>timeToLeaveHouse && !isLeavingHouse && inHouse && !isDead)
      LeaveHouse();

    int[] pos = currentLevel.getLevelCoordinates(xPos, yPos);
    int x = pos[0];
    int y = pos[1]; // Level-Koordinaten
    float[] houseDirection = new float[2]; // Richtungskoordinaten, falls der Geist noch im Haus ist

    int[] targetPointLevelCoord = currentLevel.getLevelCoordinates(targetPoint);
    if (inHouse) {
      float[] diff = new float[]{targetPoint[0]-xPos, targetPoint[1]-yPos};
      float dist = sqrt(diff[0]*diff[0]+diff[1]*diff[1]);
      if (abs(dist)<=3) { // beim Zielpunkt?
        if (!isLeavingHouse) { // Weiterhin im Haus bewegen oder rausgehen?
          findTargetPointInHouse();
        } else if (currentLevel.getTile(targetPointLevelCoord[0], targetPointLevelCoord[1])==GHOSTEXIT) { // erste Stufe des Rausgehens: beim Hauseingang
          targetPoint[1] -= TILESIZE;
        } else { // zweite Stufe: aus dem Haus draußen
          inHouse = false;
          isLeavingHouse = false;
          xPos = targetPoint[0];
          yPos = targetPoint[1]; // zur richtigen Position snapen
          UpdateTargetPoint();
          direction = new int[]{1, 0};
          newDirection = getDirection(); // Richtungsupdate
        }
      } else {
        houseDirection = new float[]{diff[0]/dist, diff[1]/dist}; // Normierte Richtung zum Zielpunkt im Haus
      }  
    } else { // nicht mehr im Haus
      if (millis()-lastTargetUpdate>updateTargetPointDelay) { // immer in bestimmten Abständen die Zielpunkte erneuern
        int[] target = currentLevel.getLevelCoordinates(targetPoint);
        if (currentLevel.getTile(target)!=GHOSTEXIT){
          UpdateTargetPoint();
        }
      }
      TryToTurn(newDirection);
    }
    if (inHouse) {
      xPos += houseDirection[0]*getSpeed()*deltaTime;
      yPos += houseDirection[1]*getSpeed()*deltaTime; // im Haus die Hausrichtung benutzen
    } else {
      if (canMove(direction)) { // sonst die normale Richtung "direction"
        if (direction[0]==0) {
          xPos = (x+0.5)*TILESIZE; // Ghost auf die Mitte der Spur bringen
          yPos += direction[1]*getSpeed()*deltaTime;
        } else if (direction[1]==0) {
          yPos = (y+0.5)*TILESIZE+LEVEL_Y_OFFSET;// Ghost auf die Mitte der Spur bringen
          xPos += direction[0]*getSpeed()*deltaTime;
        }
        int[] neuePos = currentLevel.getLevelCoordinates(xPos,yPos);
        if (x!=neuePos[0] || y!=neuePos[1]){ // Ein neues Tile betreten
          if (currentLevel.ghostMode!= lastTileMode || currentLevel.energizedMode!=lastTileEnergized){
            newDirection = new int[]{-direction[0],-direction[1]};  // Bei einem neuen Modus die Richtung umkehren
          } else {
            newDirection = getDirection(); // sonst nach neuer Richtung suchen (z.B. bei einer Kreuzung)
          }
          lastTileMode = currentLevel.ghostMode;
          lastTileEnergized = currentLevel.energizedMode;
        }
      }
    }
    if (isDead && currentLevel.getTile(targetPointLevelCoord[0], targetPointLevelCoord[1])==GHOSTEXIT && currentLevel.getTile(pos)==GHOSTEXIT){ // falls Ghost tot ist und inHouse=false
      inHouse = true;
      findTargetPointInHouse();
    }
  }
  int[] getDirection() { // gibt die Richtung zurück, in die sich der Ghost bewegen sollte, um den targetPoint zu erreichen
    int[] pos = currentLevel.getLevelCoordinates(xPos, yPos);
    switch (ghostMovement) {
    case Pathfinding: // nicht mehr benutzt, da dies noch nicht an nicht begehbare targetPoints angepasst ist.
      int[] bestPos = new int[]{0, 0};
      for (int[] dir : directions) {
        int[] npos = new int[]{pos[0]+dir[0], pos[1]+dir[1]};
        if (!currentLevel.pointInLevel(npos))continue;
        if (((bestPos[0]==0&&bestPos[1]==0) || distanceMatrix[npos[1]][npos[0]] < distanceMatrix[bestPos[1]][bestPos[0]]) && distanceMatrix[npos[1]][npos[0]]!=0) {
          bestPos = npos;
        }
      }
      return new int[]{bestPos[0]-pos[0], bestPos[1]-pos[1]}; 
    case Distance: // Das Feld auswählen, das am nächsten zum targetPoint ist
      ArrayList<int[]> nearFields = isDead ? currentLevel.getNearFieldsGhost(pos) : currentLevel.getNearFields(pos);
      if (currentLevel.energizedMode && !isDead){ // im energized mode einfach zufällig eine Richtung auswählen, sofern es mehr als zwei mögliche gibt.
        int[] f = nearFields.get(int(random(0,nearFields.size())));
        if (nearFields.size()==2){
          for (int[] field : nearFields) {
            if (field[0]==pos[0]-direction[0] && field[1]==pos[1]-direction[1])
              continue;
            f = field;
          }
        }
        return new int[]{f[0]-pos[0],f[1]-pos[1]};
      }
      if (nearFields.size()==1) {
        return new int[]{-direction[0], -direction[1]};
      } else {
        int[] target = currentLevel.getLevelCoordinates(targetPoint);
        int[] bestField = new int[]{0, 0};
        float bestDistSQD = 1000000000;
        for (int[] field : nearFields) {
          if (field[0]==pos[0]-direction[0] && field[1]==pos[1]-direction[1]) {
            continue;
          }
          float distSQD = (field[0]-target[0])*(field[0]-target[0])+(field[1]-target[1])*(field[1]-target[1]);
          if (distSQD < bestDistSQD) {
            bestField = field;
            bestDistSQD = distSQD;
          }
        }
        return new int[]{bestField[0]-pos[0], bestField[1]-pos[1]};
      }
    default:
      return new int[]{0, 0};
    }
  }
  void TryToTurn(int[] dirVec) {

    if (xPos<0 || xPos> currentLevel.xDim*TILESIZE)return;

    int x = int(xPos/TILESIZE);
    int y = int((yPos-LEVEL_Y_OFFSET)/TILESIZE);

    float[] tileCenter = currentLevel.getGlobalCoordinates(new int[]{x, y});

    int nextX = x+dirVec[0];
    int nextY = y+dirVec[1];
    boolean isWalkable = isDead ? currentLevel.isWalkableGhost(nextX,nextY) : currentLevel.isWalkable(nextX,nextY);
    if (isWalkable) {
      float distToCenterSQD = dirVec[0]==0 ? abs(tileCenter[0]-xPos) : abs(tileCenter[1]-yPos);
      //float distToCenterSQD = (tileCenter[0]-xPos)*(tileCenter[0]-xPos)+(tileCenter[1]-yPos)*(tileCenter[1]-yPos);
      if (distToCenterSQD<4) {
        direction = dirVec;
      }
    }
  }
  boolean canMove(int[] dir) {
    int x = int(xPos/TILESIZE);
    int y = int((yPos-LEVEL_Y_OFFSET)/TILESIZE);

    int nextX = x+dir[0];
    int nextY = y+dir[1];
    if (currentLevel.isWalkableGhost(nextX, nextY)) {
      return true;
    } else {
      float[] tileCenter = currentLevel.getGlobalCoordinates(new int[]{x, y});
      switch (getDirectionFromVector(dir)) {
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

  void UpdateTargetPoint() {
    if (isDead){
      setTargetPoint(currentLevel.getGlobalCoordinates(currentLevel.ghostExits.get(int(random(0, currentLevel.ghostExits.size())))));
      return;
    }
    switch(currentLevel.ghostMode) {
    case Chase:
      setTargetPoint(currentLevel.getGlobalCoordinates(findTargetPoint()));
      break;
    case Scatter:
      setTargetPoint(currentLevel.getGlobalCoordinates(scatterTargetPoint));
      break;
    }
    lastTargetUpdate = millis();
  }

  void CalculateDistanceMatrix() {
    if (!currentLevel.pointInLevel(currentLevel.getLevelCoordinates(new float[]{player.xPos, player.yPos}))) return;
    int[] target = currentLevel.getLevelCoordinates(targetPoint);
    if (currentLevel.getTile(target)==WALLTILE) {
      println("Ziel ist wand");
      return;
    }
    distanceMatrix = new int[currentLevel.yDim][currentLevel.xDim];
    distanceMatrix[target[1]][target[0]] = 1;
    ArrayList<int[]> outerFields = currentLevel.getNearFields(target);
    if (outerFields.size()==0) {
      println("Keine mgl nachbarfelder");
      return;
    }
    int distance = 2;
    while (outerFields.size()>0) {
      ArrayList<int[]> newOuterFields = new ArrayList<int[]>();
      for (int[] f : outerFields) {
        distanceMatrix[f[1]][f[0]] = distance;
      }
      for (int[] f : outerFields) {
        ArrayList<int[]> nearFields = currentLevel.getNearFields(f);
        for (int[] nearField : nearFields) {
          if (!posListContain(newOuterFields, nearField) && distanceMatrix[nearField[1]][nearField[0]]==0) newOuterFields.add(nearField);
        }
      }

      outerFields = newOuterFields;
      distance += 1;
    }
  }

  void setTargetPoint(float[] point) {
    targetPoint = point;
    if (ghostMovement == GhostMovement.Pathfinding)
      CalculateDistanceMatrix();
  }

  abstract int[] findTargetPoint();

  void findTargetPointInHouse() {
    targetPoint = currentLevel.getGlobalCoordinates(currentLevel.ghostHouse.get(int(random(0, currentLevel.ghostHouse.size()))));
  }
  void Render() {
    if (!isDead){
      fill(getColor());
      stroke(getColor());
      for (int x=int(xPos)-TILESIZE/2+4; x<int(xPos)+TILESIZE/2-4; x++) {
        line(x, yPos-5, x, yPos+TILESIZE/3+2*sin((x-int(xPos))/3+millis()/1000.0 * animationSpeed + animationOffset));
      }
      noStroke();
      arc(xPos, yPos-5, TILESIZE-8, TILESIZE-8, PI, TWO_PI, PIE);
    }
    fill(getColor()==color(255) ? color(255,0,0) : color(255));
    noStroke();
    ellipse(xPos-5, yPos-8, 6, 8);//eyes
    ellipse(xPos+5, yPos-8, 6, 8);
    if (!currentLevel.energizedMode || isDead){
      fill(color(28, 32, 255));
      ellipse(xPos-5, yPos-8, 3, 3);
      ellipse(xPos+5, yPos-8, 3, 3);
    } else {
      stroke(getColor()==color(255) ? color(255,0,0) : color(255));
      int dist = 3;
      float upY = yPos;
      float downY = yPos+dist;
      for (int i = -1;i<=1;i++){
        float left1 = xPos+(2*i-1)*dist;
        float left2 = xPos+2*i*dist;
        line(left1,downY,left1+dist,upY);
        line(left2,upY,left2+dist, downY);
      }
    }
    if (debugView){
      fill(getColor());
      ellipse(targetPoint[0],targetPoint[1],5*(sin(millis()/75.0)+2),5*(sin(millis()/75.0)+2));
    }
  }
}

Ghost getGhost(GhostColor gcolor){
  for (Ghost g : ghosts){
    switch (gcolor){
      case Red:
      if (g instanceof RedGhost) return g;
      break;
      case Orange:
      if (g instanceof OrangeGhost) return g;
      break;
      case Blue:
      if (g instanceof BlueGhost) return g;
      break;
      case Pink:
      if (g instanceof PinkGhost) return g;
      break;
    }
  }
  return null;
}

void spawnGhosts() {
  ghosts = new ArrayList<Ghost>();
  ghosts.add(new OrangeGhost());
  ghosts.add(new BlueGhost());
  ghosts.add(new PinkGhost());
  ghosts.add(new RedGhost());
  for (Ghost g : ghosts) {
    float[] pos = currentLevel.getGlobalCoordinates(currentLevel.ghostHouse.get(int(random(0, currentLevel.ghostHouse.size()))));
    g.xPos = pos[0];
    g.yPos = pos[1];
  }
}

boolean posListContain(ArrayList<int[]> list, int[] pos) {
  for (int[] p : list) {
    if (p[0]==pos[0] && p[1]==pos[1]) return true;
  }
  return false;
}
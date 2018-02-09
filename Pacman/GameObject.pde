abstract class GameObject{ // Klasse für ein ein Spielobjekt
  float xPos;
  float yPos;
  
  boolean isActive = true;
  
  public GameObject(){
    try{
    //gameObjects.add(this);
    } catch(Exception e){
    }
    addGameObjects.add(this);
  }
  abstract void Render();
  abstract void Update();
}

int[] getDirectionVector(int dir){ // gibt den Richtungsvektor nach dir (0,1,2,3) zurück
  switch (dir){
  case 0:
    return new int[]{1,0};
  case 1:
    return new int[]{0,1};
  case 2:
    return new int[]{-1,0};
  case 3:
    return new int[]{0,-1};
  }
  return new int[]{0,0};
}
int getDirectionFromVector(int[] vec){ // gibt dir (0,1,2,3) nach Richtungsvektor zurück
  if (vec[0]==1 && vec[1]==0){
    return 0;
  } else if (vec[0]==0&&vec[1]==1){
    return 1;
  } else if (vec[0]==-1&&vec[1]==0){
    return 2;
  } else if (vec[0]==0&&vec[1]==-1){
    return 3;
  } else{
    return -1;
  }
}
class Fruit extends GameObject{
  public int points;
  public PImage img;
  int level; // Das Level, ab dem die Frucht das erste Mal auftritt
  
  long spawnTime = 0;
  
  long lifeTime;
  
  public Fruit(int _points, PImage _image, int _level){
    points = _points;
    img = _image;
    img.resize(TILESIZE,TILESIZE);
    xPos = -100;
    yPos = -100;
    level = _level;
    spawnTime = millis();
    lifeTime = int(random(12000,14000)); // zufällige lebensdauer zwischen 12s und 14s
  }
  
  public void Update(){
    int[] playerPos = currentLevel.getLevelCoordinates(player.xPos,player.yPos);
    int[] pos = currentLevel.getLevelCoordinates(xPos,yPos);
    if (playerPos[0]==pos[0] && playerPos[1]==pos[1]){
      addScore(points);
      removeGameObjects.add(this);
      activeFruits.remove(this);
    }
    if (millis()-spawnTime>lifeTime){
      removeGameObjects.add(this);
      activeFruits.remove(this);
    }
  }
  public void Render(){
    image(img,xPos-TILESIZE/2,yPos-TILESIZE/2);
  }
  
  public Fruit newFruit(float[] pos){
    Fruit f = new Fruit(points,img,level);
    f.xPos = pos[0];
    f.yPos = pos[1];
    return f;
  }
}

Fruit findFruitForLevel(int level){
  for (int i = 0;i<allFruits.size();i++){
    if (allFruits.get(i).level>level){
      return i==0 ? allFruits.get(i) : allFruits.get(i-1);
    }
  }
  return allFruits.get(allFruits.size()-1);
}

void SetupFruits() {
  LoadFruits();

  allFruits.add(new Fruit(100, fruits.get("kirsche"), 0));
  allFruits.add(new Fruit(300, fruits.get("erdbeere"), 1));
  allFruits.add(new Fruit(500, fruits.get("orange"), 2));
  allFruits.add(new Fruit(700, fruits.get("apple"), 4));
  allFruits.add(new Fruit(1000, fruits.get("ananas"), 6));
  allFruits.add(new Fruit(2000, fruits.get("raumschiff"), 8));
  allFruits.add(new Fruit(3000, fruits.get("glocke"), 10));
  allFruits.add(new Fruit(5000, fruits.get("schluessel"), 12));

  for (Fruit f : allFruits) {
    gameObjects.remove(f);
  }
}
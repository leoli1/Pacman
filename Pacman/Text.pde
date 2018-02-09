class Text extends GameObject {
  String label = "";
  
  long spawnTime = 0;
  long lifeTime = 1000;
  
  int textSize = 15;
  color textColor = color(255);
  
  public Text (String text, float _xPos, float _yPos){
    xPos = _xPos;
    yPos = _yPos;
    label = text;
    spawnTime = millis();
  }
  public void Update(){
    yPos-= TILESIZE*deltaTime;
    if (millis()-spawnTime>lifeTime){
      removeGameObjects.add(this);
    }
  }
  public void Render() {
    textAlign(CENTER);
    fill(textColor);
    textSize(textSize);
    text(label, xPos,yPos);
    textSize(15);
  }
}
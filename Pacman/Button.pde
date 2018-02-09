class Button extends GameObject {
  int btnWidth;
  int btnHeight;

  String label;
  public Button(int xPos, int yPos, int btnWidth, int btnHeight, String label) {
    this.xPos = xPos;
    this.yPos = yPos;
    this.btnWidth = btnWidth;
    this.btnHeight = btnHeight;
    this.label = label;
  }
  public void Render() {
    fill(0);
    stroke(255);
    rect(xPos-btnWidth/2, yPos-btnHeight/2, btnWidth, btnHeight, 4);
    fill(color(255, 255, 0));
    textSize(15);
    textAlign(CENTER, CENTER);
    text(label, xPos, yPos);
  }
  public void Update() {}

  public boolean MouseOverBtn() { // Mauszeiger über dem Button
    return xPos-btnWidth/2<=mouseX && xPos+btnWidth/2>=mouseX && yPos-btnHeight/2<=mouseY && yPos+btnHeight/2>=mouseY;
  }
}

Button startGameButton;
Button highscoresButton;
Button quitButton;
Button menuButton;
ArrayList<Button> pauseMenuButtons = new ArrayList<Button>(); 

void SetupButtons(){
  startGameButton = new Button(width/2, height/2-200, 150, 30, "Start Game");
  highscoresButton = new Button(width/2, height/2-150, 150, 30, "Highscores");
  pauseMenuButtons.add(highscoresButton);
  quitButton = new Button(width/2, height/2-100, 150, 30, "Quit");
  pauseMenuButtons.add(quitButton);
  menuButton = new Button(width/2,height/2+50,150,30,"Menu");
  menuButton.isActive = false;
}


void TestButtons(){ // Mausklick vorausgesetzt. Die verschiedenen Buttons werden daraufhin überprüft, ob sie gedrückt wurden
  if (inPauseMenu || inMenu){
    if (startGameButton.MouseOverBtn() && inMenu)
      StartGame();
      
    if (highscoresButton.MouseOverBtn())
      displayHighscores = !displayHighscores;
      
    if (quitButton.MouseOverBtn()) exit();
    
  } else if (!gameActive){
    if (menuButton.MouseOverBtn()){ // zurück zum Menu
      inMenu = true;
      player.xPos = 0;
      player.yPos = 0;
      currentLevel.isActive = false;
      menuButton.isActive = false;
      ArrayList<GameObject> r = new ArrayList<GameObject>();
      for (GameObject g : gameObjects){
        if (g instanceof Text || g instanceof Ghost){ // Text und Geister entfernen
          r.add(g);
        }
      }
      for (GameObject g : r){
        gameObjects.remove(g);
      }
      startGameButton.isActive = true;
      highscoresButton.isActive = true;
      quitButton.isActive = true;
    }
  }
}
//import processing.sound.*;
int TILESIZE = 28;
int LEVEL_Y_OFFSET = 28; // abstand des oberen/unteren teils des levels zum oberen/unteren rand des fensters

int DOTPOINTS = 10; // punkte für einen eingesammelten punkt
int POWERPELLETPOINTS = 50; // Punkte für eine Superpille
int GHOSTKILLBASEPOINTS = 200; // Punkte für den ersten getöteten Geist, für den zweiten gibt es 2mal für den dritten 4mal und für den vierten 8mal so viel Punkte

long GAMESTART; // Zeitpunkt des Spielstarts, nach Ende des Countdowns

int score = 0; // Punkte des Spieler
int newLifeScore = 0; // Counter für die Punkte, die der Spieler für ein Extraleben benötigt
int lives = 3; // Die Anzahl an Leben, die dem Spieler zu Verfügung stehen

boolean playerDead = false; // Spieler tot oder nicht

ArrayList<GameObject> gameObjects = new ArrayList<GameObject>(); // alle Objekte vom Typ GameObject, die dann in der draw()-Methode gerendert bzw. geupdatet werden.
ArrayList<Ghost> ghosts = new ArrayList<Ghost>(); // Alle Ghosts im Level

HashMap<String, PImage> fruits = new HashMap<String, PImage>(); // Dictionary für die Früchte bzw. einsammelbaren Items. <name>, <Bilddatei>
ArrayList<Fruit> allFruits = new ArrayList<Fruit>(); // alle verschiedenen Früchte mit Punkten
ArrayList<Fruit> activeFruits = new ArrayList<Fruit>(); // alle aktiven Früchte im Level (im Normalfall nur eine)
ArrayList<GameObject> addGameObjects = new ArrayList<GameObject>(); // Damit die Liste gameObjects nicht während der Schleife modifiziert wird, erstellen wir die Liste addGameObjects, zu der in der Schleife mögliche GameObjects hinzugefügt werden, die dann nach der Schleife hinzugefügt werden
ArrayList<GameObject> removeGameObjects = new ArrayList<GameObject>(); // das gleiche für die GameObjects, die entfernt werden sollen

Player player;

ArrayList<Highscore> highscores = new ArrayList<Highscore>(); // Liste mit maximal 10 Highscore

Level currentLevel; // zurzeitiges Level
int currentLevelIndex= 0;
String[] levelNames = new String[]{"level1.txt", // die Namen der level Dateien. Da ich (vielleicht) noch die Reihenfolge der Level verändere, wird die Reihenfolge der Level in dem Array festgelegt.
  "level3.txt", 
  "level4.txt", 
  "level5.txt", 
  "level6.txt", 
  "level7.txt"};

float deltaTime; // Zeit zwischen zwei Frames
long lastTime = 0; // Zeitpunkt des letzten Frames

boolean debugView = false; // Debug-View: Gitter, Ghost-Target-Points

boolean gameActive = false; // Spiel zuende oder nicht

boolean displayHighscores = false; // Highscores anzeigen
boolean inMenu = true; // im Hauptmenu
boolean inPauseMenu = false; // Pause aktiv

PFont font; // font type

long startTimerStart; // Starttimer für den Countdown
boolean intro = true; // im intro: Countdown

//Sound sound;


void setup() {
  lastTime = millis();  
  //sound = new Sound();

  player = new Player();
  //player.isActive = false;
  currentLevel = LoadLevel("Level/"+levelNames[currentLevelIndex]);
  currentLevel.isActive = false;
  surface.setSize(TILESIZE*currentLevel.xDim, 2*LEVEL_Y_OFFSET+TILESIZE*currentLevel.yDim);

  frameRate(60);

  SetupFont();

  //sound.introSound.play();

  SetupButtons();
  LoadHighscores();
}

void StartGame() { // Spiel starten, nach dem Countdown
  spawnPlayer();
  spawnGhosts();

  player.isActive = true;
  currentLevel.isActive = true;

  SetupFruits();
  startTimerStart = millis();

  inMenu = false;
  inPauseMenu = false;
  startGameButton.isActive = false;
  for (Button b : pauseMenuButtons) {
    b.isActive = false;
  }
  println("start game");
  displayHighscores = false;
}

void SetupFont() {
  try {
    font = loadFont("pacfont.vlw");
    textFont(font);
  } 
  catch (Exception e) {
    println("Font not found");
  }
}

void spawnPlayer() { // Spieler richtig positionieren.
  float[] coords = currentLevel.getGlobalCoordinates(currentLevel.spawnPoint);
  player.xPos = coords[0];
  player.yPos = coords[1];
}

void draw() {
  background(color(0, 0, 0));
  deltaTime = (millis()-lastTime)/1000.0; // delta-time in Sekunden berechnen
  lastTime = millis();

  for (GameObject gameObject : gameObjects) {
    if (gameObject.isActive) {
      gameObject.Render();
      if (!playerDead && gameActive && !inPauseMenu)
        gameObject.Update();
    }
  }
  for (GameObject g : addGameObjects) { // GameObjects hinzufügen bzw. entfernen
    gameObjects.add(g);
  }
  for (GameObject g : removeGameObjects) {
    gameObjects.remove(g);
  }
  addGameObjects = new ArrayList<GameObject>();
  removeGameObjects = new ArrayList<GameObject>();

  if (inMenu) {
    Menu(); // Menu ui
  } else {
    Game(); // Game ui
    if (inPauseMenu) {
      for (Button b : pauseMenuButtons) { // Pause ui
        b.Render();
      }
    }
  }
  if (displayHighscores)
    DrawHighscores();
}
void Menu() {
  textSize(100);
  fill(color(255, 255, 3));
  textAlign(CENTER, CENTER);
  text("PACMAN", width/2, height/4-50);

  int f = 10; // Multiplikator für den Abstand von Pacman vom Rand

  if (player.xPos<player.diam/2*f) { // Pacman Animation
    player.xPos = player.diam/2*f; 
    player.direction=3;
  };
  if (player.xPos>width-player.diam/2*f) {
    player.xPos = width-player.diam/2*f; 
    player.direction=1;
  };
  if (player.yPos<player.diam/2*f) {
    player.yPos = player.diam/2*f; 
    player.direction=0;
  };
  if (player.yPos>height-player.diam/2*f*4.4) {
    player.yPos = height-player.diam/2*f*4.4;
    player.direction=2;
  };
}
void Game() {
  if (player.mouthAngle>=4)
    currentLevel.RespawnPlayer();

  if (debugView) {
    DebugView();
  }
  GameInfoDisplay();

  if (intro)
    IntroAnimation();
}

void DrawHighscores() {
  int size = highscores.size();
  if (size==0) {
    textSize(30);
    fill(color(255, 255, 3));
    textAlign(CENTER, CENTER);
    text("no highscores", width/2, height/2);
    return;
  }
  int h = 15+size*35;
  int rectWidth = 300;
  fill(0);
  stroke(255);
  int leftX = (width-rectWidth)/2;
  rect(leftX, height/2, rectWidth, h, 4);

  for (int i = 0; i<size; i++) {
    textAlign(LEFT, TOP);
    fill(color(255, 255, 3));
    textSize(20);
    int y = height/2+15+i*35;
    text(i+1+":", leftX+10, y);
    text(highscores.get(i).points, leftX+60, y);
    //text(highscores.get(i).name, leftX+170,y);
  }
}
void GameInfoDisplay() {
  noStroke();
  fill(0);
  rect(0, 0, width, LEVEL_Y_OFFSET);
  rect(0, height-LEVEL_Y_OFFSET, width, LEVEL_Y_OFFSET);

  textSize(15);
  textAlign(LEFT);
  fill(color(255));
  text(score+" Pts.", 5, 20);
  text("Lvl: "+(currentLevelIndex+1), 300, 20);
  text(currentLevel.dots + " dots left", 400, 20);
  fill(color(255, 255, 3));

  for (int i = 0; i<lives; i++) {
    arc(50+i*50, height-LEVEL_Y_OFFSET/2, TILESIZE-4, TILESIZE-4, PI/6, TWO_PI-PI/6, PIE);
  }  
  for (int i = 0; i<activeFruits.size(); i++) {
    image(activeFruits.get(i).img, width-TILESIZE*(i+1)-5, height-LEVEL_Y_OFFSET);
  }
}
void DebugView() {
  stroke(255);
  noFill();
  for (int x=0; x<currentLevel.xDim; x++) {
    for (int y=0; y<currentLevel.yDim; y++) {
      rect(x*TILESIZE, LEVEL_Y_OFFSET+y*TILESIZE, TILESIZE, TILESIZE);
      if (ghosts.get(0).distanceMatrix!=null)
        text(ghosts.get(0).distanceMatrix[y][x], x*TILESIZE+5, y*TILESIZE+LEVEL_Y_OFFSET+10);
    }
  }
}
void IntroAnimation() {
  if (millis()-startTimerStart<500)return; // 0.5 secs offset
  int secsg = int((millis()-500-startTimerStart)/1000);
  float size = (secsg-(millis()-500-startTimerStart)/1000.0 + 1) * 80+90;
  int secs = 3-secsg;
  if (secs<0) {
    gameActive = true;
    intro = false;
    //GAMESTART = millis();
    //currentLevel.ghostModePhaseStart = millis();
    return;
  }
  textSize(size);
  textAlign(CENTER, CENTER);
  String t = (secs>0) ? ""+secs : "GO";
  text(t, width/2, height/2);
}

void addScore(int points) {
  score += points;
  newLifeScore += points;
  if (newLifeScore>=10000) { // alle 10k Punkte ein neues Leben
    lives += 1;
    newLifeScore -= 10000;
  }
  if (points>POWERPELLETPOINTS) {
    new Text("+"+points, player.xPos, player.yPos);
  }
}

void keyPressed() {
  if (GAMESTART==0)GAMESTART=millis();
  if (currentLevel.ghostModePhaseStart==0)currentLevel.ghostModePhaseStart=GAMESTART;
  player.inputQueue = keyCode;
  if (key=='p' && !inMenu && gameActive) {
    inPauseMenu = !inPauseMenu;
    for (Button b : pauseMenuButtons) {
      b.isActive = inPauseMenu;
    }
  }
}
void mousePressed() {
  TestButtons();
}
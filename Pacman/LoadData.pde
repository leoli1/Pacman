void LoadFruits(){
  fruits = new HashMap<String, PImage>();
  try{
    fruits.put("kirsche", loadImage("Fruits/kirsche.png"));
    fruits.put("erdbeere", loadImage("Fruits/erdbeere.png"));
    fruits.put("orange", loadImage("Fruits/orange.png"));
    fruits.put("apple", loadImage("Fruits/apple.png"));
    fruits.put("ananas", loadImage("Fruits/ananas.png"));
    fruits.put("raumschiff", loadImage("Fruits/raumschiff.png"));
    fruits.put("glocke", loadImage("Fruits/glocke.png"));
    fruits.put("schluessel", loadImage("Fruits/schluessel.png"));
  } catch (NullPointerException e){
    println("Couldn't load file");
    println(e);
  }
}

void LoadHighscores(){
  String[] highscoreData = loadStrings("highscores.txt"); 
  if (highscoreData==null)return;
  for (int i=0;i<highscoreData.length;i++){
    String[] dat = highscoreData[i].split(";");
    highscores.add(new Highscore(dat[1],int(dat[0])));
  }
  SortHighscores();
}
void SaveHighscores(){
  String[] lines = new String[highscores.size()];
  int i = 0;
  for (Highscore h : highscores){
    lines[i] = h.points+";"+h.name;
    i++;
  }
  saveStrings("highscores.txt", lines);
}
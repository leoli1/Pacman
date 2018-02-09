class Highscore implements Comparable{
  String name;
  int points;
  public Highscore(String name, int points){
    this.name = name;
    this.points = points;
  }
  
  @Override
  public int compareTo(Object h) {
    return ((Highscore)h).points-points;
  }
}

void SortHighscores(){
  java.util.Collections.sort(highscores);
  /*highscores.sort(new Comparator<Highscore>(){
    @Override
    public int compare(Highscore h1, Highscore h2) {
        return h1.points>h2.points;
    }});*/    
}
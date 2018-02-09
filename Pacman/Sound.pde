/*class Sound{
  SoundFile introSound;
  SoundFile wakkaSound;
  
  long lastWakkaSoundPlayed;
  
  
  public Sound(){
    SetupSound();
  }
  
  public boolean wakkaSoundPlaying(){
    return false;//(millis()-lastWakkaSoundPlayed)<wakkaSound.duration()*1000;
  }
  void SetupSound(){
    introSound = new SoundFile(Pacman.this, "sound/intro.mp3");
    wakkaSound = new SoundFile(Pacman.this,"sound/wakkasound.mp3");
  }
  void playWakkaSound(){
    //wakkaSound.stop();
    wakkaSound.rate(2);
    wakkaSound.play();
    lastWakkaSoundPlayed = millis();
  }
}*/
// functions
List<int> calculateLevel(int expGained, int currentExp, int currentLevel) {
  int levelTotal = currentLevel * 150; // the total amount of exp needed to level up
  currentExp += expGained;
  if (currentExp >= levelTotal) {
    currentLevel ++;
    currentExp -= levelTotal; // sets currentExp to the remainder
  }
  return [currentExp, currentLevel];
}

int getGrowthStage(int plantExp) {
  if (plantExp % 10 == 0) {
    return (plantExp / 10).toInt();
  } else if (plantExp - 5 == 0) {
    return 1;
  }
  plantExp -= 5;
  return (plantExp / 10).toInt();
}
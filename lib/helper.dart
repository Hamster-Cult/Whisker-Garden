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
  return (plantExp / 10).round(); // fix the math
}
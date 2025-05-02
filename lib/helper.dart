// functions

List<int> calculateLevel(int expGained, int currentExp, int currentLevel) {
  int level_total = currentLevel * 150; // the total amount of exp needed to level up
  currentExp += expGained;
  if (currentExp >= level_total) {
    currentLevel ++;
    currentExp -= level_total; // sets currentExp to the remainder
  }
  return [currentExp, currentLevel];
}
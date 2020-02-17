require 'test-unit'
require_relative '../setup'

module DigYukko
  class LevelManagerTest < Test::Unit::TestCase
    def setup
      LevelManager.init
    end

    test '.calc_level returns the level number according to scores' do
      assert { 1 == LevelManager.calc_level(0) }
      assert { 1 == LevelManager.calc_level(1) }
      next_score = LevelManager::LEVEL_TO_SCORE[2]
      assert { 1 == LevelManager.calc_level(next_score - 1) }
      assert { 2 == LevelManager.calc_level(next_score) }
      assert { 2 == LevelManager.calc_level(next_score + 1) }
    end

    test 'calc_level returns max level number for too high scores' do
      max_level = LevelManager::LEVEL_TO_SCORE.keys.max
      max_score = LevelManager::LEVEL_TO_SCORE.values.max
      assert { max_level == LevelManager.calc_level(max_score + 1) }
    end
  end
end

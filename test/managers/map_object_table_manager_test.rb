require 'test-unit'
require_relative '../setup'

module DigYukko
  class MapObjectTableManagerTest < Test::Unit::TestCase
    def setup
      LevelManager.init
    end

    test '.fetch returns the Hash according to scores' do
      level1_score = LevelManager::LEVEL_TO_SCORE[1]
      level2_score = LevelManager::LEVEL_TO_SCORE[2]
      level3_score = LevelManager::LEVEL_TO_SCORE[3]
      level1_hash = MapObjectTableManager::LEVEL_TO_ADDITIONAL_TABLE[1]
      level2_hash = MapObjectTableManager::LEVEL_TO_ADDITIONAL_TABLE[2]
      level3_hash = MapObjectTableManager::LEVEL_TO_ADDITIONAL_TABLE[3]

      assert { level1_hash == MapObjectTableManager.fetch(level1_score) }
      assert { level1_hash == MapObjectTableManager.fetch(level2_score - 1) }
      assert { level2_hash == MapObjectTableManager.fetch(level2_score) }
      assert { level2_hash == MapObjectTableManager.fetch(level2_score + 1) }
      assert { level2_hash == MapObjectTableManager.fetch(level3_score - 1) }
      assert { level3_hash == MapObjectTableManager.fetch(level3_score) }
      assert { level3_hash == MapObjectTableManager.fetch(level3_score + 1) }
    end
  end
end

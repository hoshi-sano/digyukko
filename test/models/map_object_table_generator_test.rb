require 'test-unit'
require_relative '../setup'

module DigYukko
  class MapObjectTableGeneratorTest < Test::Unit::TestCase
    test '.calc_level returns the level number according to scores' do
      assert { 1 == MapObjectTableGenerator.calc_level(0) }
      assert { 1 == MapObjectTableGenerator.calc_level(1) }
      next_score = MapObjectTableGenerator::LEVEL_TO_SCORE[2]
      assert { 1 == MapObjectTableGenerator.calc_level(next_score - 1) }
      assert { 2 == MapObjectTableGenerator.calc_level(next_score) }
      assert { 2 == MapObjectTableGenerator.calc_level(next_score + 1) }
    end

    test 'calc_level returns max level number for too high scores' do
      max_level = MapObjectTableGenerator::LEVEL_TO_SCORE.keys.max
      max_score = MapObjectTableGenerator::LEVEL_TO_SCORE.values.max
      assert { max_level == MapObjectTableGenerator.calc_level(max_score + 1) }
    end
  end
end

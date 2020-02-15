require 'test-unit'
require_relative '../setup'

module DigYukko
  class MapObjectGeneratorTest < Test::Unit::TestCase
    test 'assert default score' do
      generator = MapObjectGenerator.new(Yukko.new, 0)
      assert { 80 == generator.breakable_object_table[BreakableBlock] }
      assert { 0 == generator.breakable_object_table[HardBreakableBlock] }
      assert { 0 == generator.breakable_object_table[ProjectileCostumeItem] }
      assert { 2 == generator.item_table[ProjectileCostumeItem] }
      assert { 2 == generator.item_table[LowRecoverItem] }
      assert { 0 == generator.item_table[FullRecoverItem] }
    end

    test 'add score' do
      generator = MapObjectGenerator.new(Yukko.new, 0)
      assert { 80 == generator.breakable_object_table[BreakableBlock] }
      assert { 0 == generator.breakable_object_table[HardBreakableBlock] }
      assert { 0 == generator.breakable_object_table[ProjectileCostumeItem] }

      generator.breakable_object_table.add({
        BreakableBlock => :zero,
        HardBreakableBlock => 5,
        ProjectileCostumeItem => 0
      })
      assert { 0 == generator.breakable_object_table[BreakableBlock] }
      assert { 5 == generator.breakable_object_table[HardBreakableBlock] }
      assert { 0 == generator.breakable_object_table[ProjectileCostumeItem] }
    end

    test 'add score temporary' do
      generator = MapObjectGenerator.new(Yukko.new, 0)
      assert { 80 == generator.breakable_object_table[BreakableBlock] }
      assert { 0 == generator.breakable_object_table[HardBreakableBlock] }
      assert { 0 == generator.breakable_object_table[ProjectileCostumeItem] }

      additional_score = {
        BreakableBlock => :zero,
        HardBreakableBlock => 5,
        ProjectileCostumeItem => 10
      }
      generator.breakable_object_table.temp_add(additional_score) do |table|
        assert { 0 == table[BreakableBlock] }
        assert { 5 == table[HardBreakableBlock] }
        assert { 10 == table[ProjectileCostumeItem] }
      end

      assert { 80 == generator.breakable_object_table[BreakableBlock] }
      assert { 0 == generator.breakable_object_table[HardBreakableBlock] }
      assert { 0 == generator.breakable_object_table[ProjectileCostumeItem] }
    end
  end
end

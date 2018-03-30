module DigYukko
  # 最奥部のマップを表現するクラス
  class BottomMap < Map
    def initialize
      super
      clear_item = ClearItem.new(self, 16, 16)
      clear_item.target = @field
      @field_objects << clear_item
      @items << clear_item
    end

    # ランダムではなく固定マップを生成する
    def generate_line_code(line_length)
      line_codes = []
      (DEPTH - 12).times do
        line = Array.new(3, UnbreakableBlock::CODE)
        line += Array.new(line_length - 6, FieldObject::EMPTY_CODE)
        line += Array.new(3, UnbreakableBlock::CODE)
        line_codes << line
      end
      2.times do
        line = Array.new(3, UnbreakableBlock::CODE)
        line += Array.new(line_length - 11, FieldObject::EMPTY_CODE)
        line += Array.new(2, UnbreakableBlock::CODE)
        line += Array.new(3, FieldObject::EMPTY_CODE)
        line += Array.new(3, UnbreakableBlock::CODE)
        line_codes << line
      end
      10.times { line_codes << Array.new(line_length, 1) }
      line_codes
    end
  end
end

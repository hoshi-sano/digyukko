module DigYukko
  # 最奥部のマップを表現するクラス
  class BottomMap < Map
    def initialize(yukko)
      super
      clear_item = ClearItem.new(self, 16, 16)
      clear_item.target = @field
      @field_objects << clear_item
      @items << clear_item
    end

    # ランダムではなく固定マップを生成する
    def generate_lines(line_length)
      res = []
      (DEPTH - 12).times do
        line = Array.new(3, UnbreakableBlock)
        line += Array.new(line_length - 6, nil)
        line += Array.new(3, UnbreakableBlock)
        res << line
      end
      2.times do
        line = Array.new(3, UnbreakableBlock)
        line += Array.new(line_length - 11, nil)
        line += Array.new(2, UnbreakableBlock)
        line += Array.new(3, nil)
        line += Array.new(3, UnbreakableBlock)
        res << line
      end
      10.times { res << Array.new(line_length, UnbreakableBlock) }
      res
    end
  end
end

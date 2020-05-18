module DigYukko
  # 最奥部のマップを表現するクラス
  class BottomMap < Map
    def initialize(yukko, score)
      UnbreakableBlock.reset_color
      super(yukko, score)
      clear_item = ClearItem.new(self, 16, 16)
      @field_objects << clear_item
      @items << clear_item
    end

    # ランダムではなく固定マップを生成する
    def generate_lines(line_length)
      res = []
      (DEPTH - 27).times do
        line = Array.new(3, UnbreakableBlock)
        line += Array.new(line_length - 6, nil)
        line += Array.new(3, UnbreakableBlock)
        res << line
      end
      2.times do
        res << (Array.new(3, UnbreakableBlock) +
                Array.new(line_length - 6, BreakableBlock) +
                Array.new(3, UnbreakableBlock))
      end
      res << (Array.new(3, UnbreakableBlock) +
              Array.new(2, BreakableBlock) +
              Array.new(line_length - 5, UnbreakableBlock))
      res << (Array.new(3, UnbreakableBlock) +
              Array.new(line_length - 6, BreakableBlock) +
              Array.new(3, UnbreakableBlock))
      res << (Array.new(line_length - 5, UnbreakableBlock) +
              Array.new(2, BreakableBlock) +
              Array.new(3, UnbreakableBlock))
      res << (Array.new(3, UnbreakableBlock) +
              Array.new(line_length - 6, BreakableBlock) +
              Array.new(3, UnbreakableBlock))
      res << (Array.new(3, UnbreakableBlock) +
              Array.new(2, BreakableBlock) +
              Array.new(line_length - 5, UnbreakableBlock))
      8.times do
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

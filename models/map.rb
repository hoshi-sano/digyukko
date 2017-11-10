module DigYukko
  class Map
    attr_reader :blocks

    def initialize
      @blocks = generate_blocks
    end

    def draw
      Sprite.draw(@blocks)
    end

    def generate_blocks
      (0..8).map do |num|
        line = (2..21).map { |i| Block.new(i, num, true) }
        line.unshift(Block.new(1, num, false))
        line.unshift(Block.new(0, num, false))
        line.push(Block.new(22, num, false))
        line.push(Block.new(23, num, false))
        line
      end
    end
  end
end

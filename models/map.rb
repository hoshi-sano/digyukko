module DigYukko
  class Map
    attr_reader :blocks

    def initialize
      @blocks = generate_blocks
      @fragments = []
    end

    def draw
      ::DXRuby::Sprite.draw(@blocks)
      ::DXRuby::Sprite.draw(@fragments)
    end

    def update
      ::DXRuby::Sprite.update(@fragments)
      @fragments.delete_if { |f| f.vanished? }
    end

    def has_block?(x, y, dx, height)
      # TODO: 不可視化
      img = ::DXRuby::Image.new(dx.abs, height, ::DXRuby::C_GREEN)
      obj_x = (dx < 0) ? (x + dx) : x
      obj = ::DXRuby::Sprite.new(obj_x, y, img)
      ::DXRuby::Sprite.check(obj, @blocks)
    end

    def push_fragments(ary)
      @fragments = @fragments + ary
    end

    def generate_blocks
      block_x_num = Config['window.width'] / BreakableBlock.image.width
      (0..8).map do |num|
        line = (2..(block_x_num - 3)).map { |i| BreakableBlock.new(self, i, num) }
        line.unshift(UnbreakableBlock.new(self, 1, num))
        line.unshift(UnbreakableBlock.new(self, 0, num))
        line.push(UnbreakableBlock.new(self, block_x_num - 2, num))
        line.push(UnbreakableBlock.new(self, block_x_num - 1, num))
        line
      end
    end
  end
end

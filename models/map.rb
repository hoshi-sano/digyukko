module DigYukko
  class Map
    attr_reader :blocks, :field
    attr_writer :yukko

    def initialize
      @field = ::DXRuby::RenderTarget.new(Config['window.width'],
                                          Config['window.height'] * 2)
      @field_y = 0
      @blocks = generate_blocks
      @fragments = []
    end

    def draw
      ::DXRuby::Sprite.draw(@blocks)
      ::DXRuby::Sprite.draw(@fragments)
      ::DXRuby::Window.draw(0, @field_y, @field)
    end

    def update
      # プレイヤーキャラが画面の縦半分より下に移動した場合は画面を追従させる
      dy = @yukko.y + @field_y - (Config['window.height'] / 2)
      @field_y -= dy if dy > 0

      ::DXRuby::Sprite.update(@fragments)
      @fragments.each { |f| f.vanish if f.y > Config['window.height'] - @field_y }
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
      ary.each { |b| b.target = @field }
      @fragments = @fragments + ary
    end

    def generate_blocks
      block_x_num = Config['window.width'] / BreakableBlock.image.width
      (0..16).map do |num|
        line = (2..(block_x_num - 3)).map { |i| BreakableBlock.new(self, i, num) }
        line.unshift(UnbreakableBlock.new(self, 1, num))
        line.unshift(UnbreakableBlock.new(self, 0, num))
        line.push(UnbreakableBlock.new(self, block_x_num - 2, num))
        line.push(UnbreakableBlock.new(self, block_x_num - 1, num))
        line.each { |b| b.target = @field }
      end
    end
  end
end

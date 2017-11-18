module DigYukko
  class Map
    attr_reader :blocks, :field
    attr_writer :yukko

    class BlockChecker < ::DXRuby::Sprite
      attr_reader :block

      def reset
        @block = nil
      end

      def shot(block)
        @block = block
      end
    end

    BLOCK_CHECKER =
      BlockChecker.new(0, 0, ::DXRuby::Image.new(Yukko::X_MOVE_UNIT, Yukko::HEIGHT))

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
      if @yukko.y < field_lower_end
        dy = @yukko.y + @field_y - window_half_height
        @field_y -= dy if dy > 0
      end

      ::DXRuby::Sprite.update(@fragments)
      @fragments.each { |f| f.vanish if f.y > Config['window.height'] - @field_y }
      @fragments.delete_if { |f| f.vanished? }
    end

    # 画面の半分の高さを返す
    def window_half_height
      @window_half_height ||= Config['window.height'] / 2
    end

    # @fieldの高さ - 画面の半分の高さを返す
    def field_lower_end
      @field_lower_end ||= @field.height - window_half_height
    end

    def find_block(x, y, dx)
      BLOCK_CHECKER.reset
      BLOCK_CHECKER.x = (dx < 0) ? (x + dx) : x
      BLOCK_CHECKER.y = y
      if ::DXRuby::Sprite.check(BLOCK_CHECKER, @blocks)
        BLOCK_CHECKER.block
      else
        nil
      end
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

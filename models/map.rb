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

    # ステージの両端の破壊不能ブロック数
    SIDE_WALL_LENGTH = 2

    # 1ステージの深さ(ブロック数)
    DEPTH = 30

    # ブロック当たり判定用オブジェクト
    BLOCK_CHECKER =
      BlockChecker.new(0, 0, ::DXRuby::Image.new(Yukko::X_MOVE_UNIT, Yukko::HEIGHT))

    def initialize
      @field = ::DXRuby::RenderTarget
               .new(Config['window.width'],
                    Config['window.height'] + BreakableBlock.image.width * DEPTH)
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

    # ステージのブロックをランダム生成する
    def generate_blocks
      line_length = Config['window.width'] / BreakableBlock.image.width
      DigYukko.log(:debug, "start generate_blocks, line_length: #{line_length}", self.class)
      line_codes = generate_line_code(line_length)

      # ブロックコードから各ブロックのインスタンスへ変換する
      line_codes.map.with_index do |line_code, line_num|
        line = line_code.map.with_index do |code, block_num|
          if code == BreakableBlock::CODE
            BreakableBlock.new(self, block_num, line_num)
          else
            UnbreakableBlock.new(self, block_num, line_num)
          end
        end
        line.each { |b| b.target = @field }
      end
    end

    private

    # 1ステージ分のブロックラインをブロックコード値で生成する
    def generate_line_code(line_length)
      line_codes = []
      line_dat = generate_initial_line_code(line_length)
      line_codes << line_dat[:line]
      (DEPTH - 1).times do
        DigYukko.log(:debug, line_dat, self.class)
        line_dat =
          generate_single_line_code(line_length, line_dat[:x_offset], line_dat[:b_length])
        line_codes << line_dat[:line]
      end
      line_codes
    end

    # 一番最初のブロックコード値のブロックラインを固定で生成する
    def generate_initial_line_code(length)
      res = Array.new(SIDE_WALL_LENGTH, UnbreakableBlock::CODE)
      res += Array.new(length - SIDE_WALL_LENGTH * 2, BreakableBlock::CODE)
      res += Array.new(SIDE_WALL_LENGTH, UnbreakableBlock::CODE)
      { line: res, x_offset: SIDE_WALL_LENGTH - 1, b_length: length - SIDE_WALL_LENGTH * 2 }
    end

    # 1行分のブロックラインをブロックコード値でランダム生成する
    # 直前の行の情報を元に進行不可なブロックラインを生成しないようにする
    def generate_single_line_code(length, prev_offset, prev_length)
      new_offset, new_length = nil, nil
      while invalid_offset_and_length?(length, new_offset, new_length,
                                       prev_offset, prev_length)
        new_offset = rand(length - SIDE_WALL_LENGTH * 2) + SIDE_WALL_LENGTH
        new_length = rand(length - (SIDE_WALL_LENGTH * 2) - new_offset) + 1
      end

      res = Array.new(new_offset, UnbreakableBlock::CODE)
      breakable_end = new_offset + new_length
      while res.length < length
        code = (res.length < breakable_end) ? BreakableBlock::CODE : UnbreakableBlock::CODE
        res << code
      end
      { line: res, x_offset: new_offset, b_length: new_length }
    end

    def invalid_offset_and_length?(block_length,
                                   new_offset, new_length,
                                   prev_offset, prev_length)
      new_offset.nil? ||
        new_length.nil? ||
        (new_offset >= prev_offset + prev_length) ||
        (new_offset + new_length) < prev_offset ||
        (block_length / new_length) > 2
    end
  end
end

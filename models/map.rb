module DigYukko
  class Map
    attr_reader :blocks, :field, :field_objects, :last_block, :items, :object_generator
    attr_accessor :yukko

    class BlockChecker < ::DXRuby::Sprite
      attr_reader :block

      def reset
        @block = nil
      end

      def shot(obj)
        @block = obj if obj.block?
      end
    end

    # ステージの両端の破壊不能ブロック数
    SIDE_WALL_LENGTH = 2

    # 1ステージの深さ(ブロック数)
    DEPTH = 30

    # 被ダメージ時などの画面揺れの振幅
    AMPLITUDE = 30

    # 揺れが継続するフレーム数
    SHAKING_FRAME = 15

    # ブロック当たり判定用オブジェクト
    BLOCK_CHECKER =
      BlockChecker.new(0, 0, ::DXRuby::Image.new(Yukko::X_MOVE_UNIT, Yukko::HEIGHT / 2))

    def initialize(yukko)
      @yukko = yukko
      @field = ::DXRuby::RenderTarget
               .new(Config['window.width'],
                    Config['window.height'] + BreakableBlock.image.width * DEPTH)
      create_field_bg
      @field_x = 0
      @field_y = 0
      @shake_x = 0
      @object_generator = MapObjectGenerator.new(@yukko)
      @field_objects = generate_field_objects
      @blocks = @field_objects.flatten.compact.select(&:block?)
      @last_block = @blocks.compact.sort { |b| b.foot_y }.first
      @items = @field_objects.flatten.compact.select(&:item?)
      @fragments = []
      @yukko.map = self
    end

    def draw
      @field.draw(0, 0, @field_bg, -1)
      ::DXRuby::Sprite.draw(@field_objects)
      ::DXRuby::Sprite.draw(@fragments)
      ::DXRuby::Window.draw(@field_x, @field_y, @field)
    end

    def update
      # プレイヤーキャラが画面の縦半分より下に移動した場合は画面を追従させる
      if @yukko.y < field_lower_end
        dy = @yukko.y + @field_y - window_half_height
        if dy > 0
          @field_y -= dy
          ActionManager.add_depth(dy)
        end
      end
      shake_field

      ::DXRuby::Sprite.update(@field_objects)
      ::DXRuby::Sprite.update(@fragments)
      @fragments.each { |f| f.vanish if f.y > Config['window.height'] - @field_y }
      @fragments.delete_if { |f| f.vanished? }
    end

    def random(max)
      ApplicationManager.random_number_generator.rand(0..max)
    end

    # 画面揺れを発生する
    # 自動的に収束するため揺れを停止する用のメソッドは存在しない
    def shake!
      @shake_x = AMPLITUDE
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

    def put_field_object(obj)
      obj.target = @field
      @field_objects << obj
      if obj.block?
        @blocks << obj
      elsif obj.item?
        @items << obj
      end
    end

    # ステージのオブジェクトをランダム生成する
    def generate_field_objects
      line_length = Config['window.width'] / BreakableBlock.image.width
      DigYukko.log(:debug, "start generate_blocks, line_length: #{line_length}", self.class)
      lines = generate_lines(line_length)

      # ブロック/アイテムのクラスからインスタンスへ変換する
      lines.map.with_index do |line, line_num|
        line.map.with_index do |klass, block_num|
          next if klass.nil?
          klass.new(self, block_num, line_num).tap do |line_obj|
            line_obj.target = @field
          end
        end
      end
    end

    private

    # 画面揺れ表現のためにfieldの位置を補正する内部メソッド
    # 振幅の減衰もここで処理する
    def shake_field
      return if @shake_x.zero?
      dir = (@shake_x * -1) / @shake_x.abs
      @shake_x = (@shake_x.abs - (AMPLITUDE / SHAKING_FRAME)) * dir
      @field_x = @shake_x
    end

    def create_field_bg
      cell_image = UnbreakableBlock.image.change_hls(0, -60, 0)
      col_size = @field.width / cell_image.width
      row_size = @field.height / cell_image.height
      row_size.times do |y|
        col_size.times do |x|
          @field.draw(x * cell_image.width, y * cell_image.height, cell_image)
        end
      end
      @field_bg = @field.to_image
    end

    # 1ステージ分のブロックラインをブロックコード値で生成する
    def generate_lines(line_length)
      res = []
      line_dat = generate_initial_line(line_length)
      res << line_dat[:line]
      (DEPTH - 1).times do
        DigYukko.log(:debug, line_dat, self.class)
        line_dat =
          generate_single_line(line_length, line_dat[:x_offset], line_dat[:b_length])
        res << line_dat[:line]
      end
      res
    end

    # 一番最初のブロックラインを固定で生成する
    def generate_initial_line(length)
      res = Array.new(SIDE_WALL_LENGTH, UnbreakableBlock)
      res += Array.new(length - SIDE_WALL_LENGTH * 2, BreakableBlock)
      res += Array.new(SIDE_WALL_LENGTH, UnbreakableBlock)
      { line: res, x_offset: SIDE_WALL_LENGTH - 1, b_length: length - SIDE_WALL_LENGTH * 2 }
    end

    # 1行分のブロックラインをブロック/アイテム系のクラスの配列でランダム生成する
    # 直前の行の情報を元に進行不可なブロックラインを生成しないようにする
    def generate_single_line(length, prev_offset, prev_length)
      new_offset, new_length = nil, nil
      while invalid_offset_and_length?(length, new_offset, new_length,
                                       prev_offset, prev_length)
        new_offset = random(length - SIDE_WALL_LENGTH * 2) + SIDE_WALL_LENGTH
        new_length = random(length - SIDE_WALL_LENGTH - new_offset) + 1
      end

      res = Array.new(new_offset, UnbreakableBlock)
      breakable_end = new_offset + new_length
      while res.length < length
        if res.length < breakable_end
          res << @object_generator.breakable_object_class
        else
          res << UnbreakableBlock
        end
      end
      { line: res, x_offset: new_offset, b_length: new_length }
    end

    def invalid_offset_and_length?(block_length,
                                   new_offset, new_length,
                                   prev_offset, prev_length)
      new_offset.nil? ||
        new_length.nil? ||
        (new_offset >= prev_offset + prev_length) ||
        (new_offset + new_length) <= prev_offset ||
        (block_length / new_length) > 2
    end
  end
end

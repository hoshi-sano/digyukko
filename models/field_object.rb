module DigYukko
  # マップのフィールドに配置されるオブジェクトの基本クラス
  class FieldObject < ::DXRuby::Sprite
    include HelperMethods

    class << self
      def set_image(image)
        @image = image
      end

      def image
        @image
      end

      def set_score(score)
        @score = score
      end

      def score
        @score
      end

      def set_power(power)
        @power = power
      end

      def power
        @power
      end

      def fragment(image)
        # FieldObjectのサイズ基準はBreakableBlock
        width = BreakableBlock.image.width / 2
        height = BreakableBlock.image.height / 2
        center = { x: width / 2, y: height / 2 }
        image = ::DXRuby::Image.new(width, height).tap do |img|
          base_args = [center[:x], center[:y], width / 2]
          img.circle_fill(*base_args, average_color(image))
          img.circle(*base_args, deepest_color(image))
        end
        fragment_class = Class.new(FieldObject::Fragment) do |klass|
          klass.const_set(:'IMAGE', image)
        end
        const_set(:'Fragment', fragment_class)
      end
    end

    def initialize(map, x, y)
      @map = map
      @line_num = x
      @block_num = y
      image = self.class.image
      # FieldObjectのサイズ基準はBreakableBlock
      super(x * BreakableBlock.image.width,
            y * BreakableBlock.image.height + 192, image)
    end

    def width
      self.image.width
    end

    def height
      self.image.height
    end

    def foot_y
      self.y + height
    end

    def score
      self.class.score
    end

    def power
      self.class.power
    end

    def break
      raise NotImplementedError
    end

    def block?
      self.is_a?(Block)
    end

    def item?
      self.is_a?(Item)
    end

    # ブロックの破片を表現するクラス
    # FieldObject.fragmentで動的に継承して使われる前提
    class Fragment < ::DXRuby::Sprite
      include HelperMethods
      WIDTH = BreakableBlock.image.width / 2
      HEIGHT = BreakableBlock.image.height / 2
      CENTER = { x: WIDTH / 2, y: HEIGHT / 2 }

      POSITION_TO_PARAMS = {
        upper_left:  { dx:     0, dy: 0,      x_speed: -3, y_speed: -3 },
        upper_right: { dx: WIDTH, dy: 0,      x_speed:  3, y_speed: -3 },
        lower_left:  { dx:     0, dy: HEIGHT, x_speed: -1, y_speed: 5 },
        lower_right: { dx: WIDTH, dy: HEIGHT, x_speed:  1, y_speed: 5 },
      }

      def initialize(block, position)
        param = POSITION_TO_PARAMS[position]
        super(block.x + param[:dx], block.y + param[:dy], self.class::IMAGE)
        @x_speed = param[:x_speed]
        @y_speed = param[:y_speed]
      end

      def update
        @y_speed += 1
        self.x += @x_speed
        self.y += @y_speed
        # 基本的にはMap側の制御でvanishするためここは実行されない想定
        vanish if self.y > self.target.height
      end
    end
  end
end

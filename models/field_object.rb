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
    end

    def initialize(map, x, y)
      @map = map
      image = self.class.image
      super(x * image.width, y * image.height + 192, image)
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

    def break
      raise NotImplementedError
    end

    # ブロックの破片を表現するクラス
    class Fragment < ::DXRuby::Sprite
      include HelperMethods
      WIDTH = BreakableBlock.image.width / 2
      HEIGHT = BreakableBlock.image.height / 2
      CENTER = { x: WIDTH / 2, y: HEIGHT / 2 }
      IMAGE = ::DXRuby::Image.new(WIDTH, HEIGHT).tap do |img|
        base_args = [CENTER[:x], CENTER[:y], WIDTH / 2]
        img.circle_fill(*base_args, average_color(BreakableBlock.image))
        img.circle(*base_args, deepest_color(BreakableBlock.image))
      end

      def initialize(x, y, x_speed, y_speed)
        super(x, y, IMAGE)
        @x_speed = x_speed
        @y_speed = y_speed
      end

      POSITION_TO_PARAMS = {
        upper_left:  { dx:     0, dy: 0,      x_speed: -3, y_speed: -3 },
        upper_right: { dx: WIDTH, dy: 0,      x_speed:  3, y_speed: -3 },
        lower_left:  { dx:     0, dy: HEIGHT, x_speed: -1, y_speed: 5 },
        lower_right: { dx: WIDTH, dy: HEIGHT, x_speed:  1, y_speed: 5 },
      }

      def initialize(block, position)
        param = POSITION_TO_PARAMS[position]
        super(block.x + param[:dx], block.y + param[:dy], IMAGE)
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

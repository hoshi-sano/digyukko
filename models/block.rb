module DigYukko
  class Block < ::DXRuby::Sprite
    include HelperMethods

    UNBREAKALE_IMAGE = load_image('unbreakable_block')
    BREAKALE_IMAGE = load_image('breakable_block')

    class << self
      def set_image(image)
        @image = image
      end

      def image
        @image
      end
    end

    def initialize(map, x, y)
      @map = map
      image = self.class.image
      super(x * image.width, y * image.height + 200, image)
    end

    def height
      self.image.height
    end

    def foot_y
      self.y + height
    end

    def break
      raise NotImplementedError
    end

    # ブロックの破片を表現するクラス
    class Fragment < ::DXRuby::Sprite
      include HelperMethods
      WIDTH = Block::BREAKALE_IMAGE.width / 2
      HEIGHT = Block::BREAKALE_IMAGE.height / 2
      CENTER = { x: WIDTH / 2, y: HEIGHT / 2 }
      IMAGE = ::DXRuby::Image.new(WIDTH, HEIGHT).tap do |img|
        base_args = [CENTER[:x], CENTER[:y], WIDTH / 2]
        img.circle_fill(*base_args, average_color(Block::BREAKALE_IMAGE))
        img.circle(*base_args, deepest_color(Block::BREAKALE_IMAGE))
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
        vanish if self.x > Config['window.width'] || self.y > Config['window.height']
      end
    end
  end
end

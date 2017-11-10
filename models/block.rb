module DigYukko
  class Block < ::DXRuby::Sprite
    WHITE_IMAGE = ::DXRuby::Image.new(32, 32, ::DXRuby::C_WHITE)
    RED_IMAGE = ::DXRuby::Image.new(32, 32).tap do |img|
      img.box(0, 0, img.width, img.height, ::DXRuby::C_RED)
    end

    def initialize(x, y, breakable)
      @breakable = breakable
      super(x * 32, y * 32 + 200, @breakable ? RED_IMAGE : WHITE_IMAGE)
    end

    def height
      self.image.height
    end

    def foot_y
      self.y + height
    end

    def break
      return unless @breakable
      vanish
    end
  end
end

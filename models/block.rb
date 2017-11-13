module DigYukko
  class Block < ::DXRuby::Sprite
    include HelperMethods

    UNBREAKALE_IMAGE = load_image('unbreakable_block')
    BREAKALE_IMAGE = load_image('breakable_block')

    def initialize(x, y, breakable)
      @breakable = breakable
      image = @breakable ? BREAKALE_IMAGE : UNBREAKALE_IMAGE
      super(x * image.width, y * image.height + 200, image)
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

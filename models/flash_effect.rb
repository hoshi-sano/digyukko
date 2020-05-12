module DigYukko
  class FlashEffect < ::DXRuby::Sprite
    REDUCTION_RATIO = 0.7
    IMAGE = ::DXRuby::Image.new(Config['window.width'],
                                Config['window.height'],
                                ::DXRuby::C_WHITE)

    def initialize(cut_in, y = 0, alpha = 255)
      @count = 0
      super(0, y, IMAGE)
      self.center_y = cut_in.y + (cut_in.image.height / 2) - y
      self.alpha = alpha
      self.z = 255
    end

    def update
      self.scale_y = 1.0 * (REDUCTION_RATIO ** @count)
      @count += 1
      vanish if finished?
    end

    def finished?
      self.scale_y < 0.01
    end
  end
end

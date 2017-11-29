module DigYukko
  class BombEffect < ::DXRuby::Sprite
    FRAME_NUM = 12
    IMAGES = (0..FRAME_NUM).to_a.map do |n|
      ::DXRuby::Image.new(Bomb.image.width, Bomb.image.height).tap do |img|
        img.circle_fill(img.width / 2, img.height / 2, img.width / 2, ::DXRuby::C_YELLOW)
        img.circle_fill(img.width / 3, img.height / 1.5, n, [0, 0, 0, 0])
      end
    end

    def initialize(x, y)
      @count = 0
      super(x, y, IMAGES[@count])
      self.vanish if finished?
    end

    def update
      @count += 1
      self.image = IMAGES[@count]
    end

    def finished?
      @count > FRAME_NUM
    end
  end
end
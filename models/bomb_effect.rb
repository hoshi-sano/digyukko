module DigYukko
  class BombEffect < ::DXRuby::Sprite
    FRAME_NUM = 12
    IMAGES = (0..FRAME_NUM).to_a.map do |n|
      ::DXRuby::Image.new(Bomb.image.width, Bomb.image.height).tap do |img|
        img.circle_fill(img.width / 2, img.height / 2, img.width / 2, ::DXRuby::C_YELLOW)
        img.circle_fill(img.width / 3, img.height / 1.5, n, [0, 0, 0, 0])
      end
    end

    def initialize(x, y, power, delay = 0)
      @power = power
      @delay = delay * (FRAME_NUM / 3)
      @count = -1
      super(x, y, IMAGES[@count])
      self.z = 300
      self.visible = @delay.zero?
      self.collision_enable = @delay.zero?
      self.vanish if finished?
    end

    def update
      @delay -= 1
      return if @delay > 0
      self.visible = true
      self.collision_enable = true
      @count += 1
      self.image = IMAGES[@count]
    end

    def finished?
      @count > FRAME_NUM
    end

    def shot(obj)
      if obj.is_a?(Yukko)
        obj.damage(@power)
      else
        obj.break
      end
    end
  end
end

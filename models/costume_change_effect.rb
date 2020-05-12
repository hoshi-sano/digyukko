module DigYukko
  # コスチューム変更時のエフェクト
  class CostumeChangeEffect
    def initialize(yukko, new_costume_class)
      @blink = BlinkEffect.new(yukko, new_costume_class)
      @twinkle = TwinkleEffect.new(yukko)
      @cut_in = CutInEffect.new(new_costume_class)
      @flash = FlashEffect.new(@cut_in)
      SE.play(:power_up)
    end

    def update
      @blink.update
      @twinkle.update
      @flash.update
      @cut_in.update
    end

    def draw
      @blink.draw
      @twinkle.draw
      @flash.draw
      @cut_in.draw
    end

    def finished?
      @twinkle.finished? && @cut_in.finished?
    end

    class BlinkEffect < ::DXRuby::Sprite
      BLINK_INTERVAL = 3

      def initialize(yukko, new_costume_class)
        @count = 0
        image_y = Yukko::DIR.values.index(yukko.x_dir)
        image_x = yukko.animation_frame.floor
        image_index = image_y * new_costume_class::IMAGE_SPLIT_X + image_x
        super(yukko.x, yukko.y, new_costume_class::IMAGES[image_index])
        self.target = yukko.target
        self.alpha = 255
        self.z = 255
      end

      def update
        if (@count % BLINK_INTERVAL).zero?
          self.alpha = (self.alpha == 255) ? 0 : 255
        end
        @count += 1
      end
    end

    class TwinkleEffect < ::DXRuby::Sprite
      include HelperMethods

      IMAGE_SPLIT_X = 8
      IMAGE_SPLIT_Y = 1
      TWINKLE_IMAGE = load_image_tiles('costume_change_effect', IMAGE_SPLIT_X, IMAGE_SPLIT_Y)
      IMAGE_UPDATE_FREQUENCY = 2
      TTL = 30

      def initialize(yukko)
        @count = 0
        super(yukko.mid_x - TWINKLE_IMAGE[@count].width / 2,
              yukko.foot_y - TWINKLE_IMAGE[@count].height,
              TWINKLE_IMAGE[@count])
        self.target = yukko.target
        self.z = 255
      end

      def image_count
        (@count / IMAGE_UPDATE_FREQUENCY) % IMAGE_SPLIT_X
      end

      def update
        self.image = TWINKLE_IMAGE[image_count]
        @count += 1
      end

      def finished?
        @count > TTL
      end
    end

    class CutInEffect < ::DXRuby::Sprite
      TTL = 60

      def initialize(new_costume_class)
        @image = new_costume_class::CUT_IN_IMAGE
        @initial_x = Config['window.width']
        super(@initial_x, Config['window.height'] - @image.height, @image)
        self.z = 255
        @count = 0
      end

      def update
        self.x = @initial_x -
                 (Math.sin([@count ** 2, 90].min * (Math::PI / 180)) * @image.width).to_i
        @count += 1
      end

      def draw
        super
      end

      def finished?
        @count > TTL
      end
    end
  end
end

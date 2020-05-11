module DigYukko
  class ClearItem < Item
    set_image load_image('clear_item')
    # TODO: 適切な値を検討する
    set_score 100000
    set_power 0

    def initialize(map, x, y)
      super(map, x, y)
      @twinkle_effect = TwinkleEffect.new(self)
      self.target = map.field
      @twinkle_effect.target = map.field
    end

    def effect(yukko)
      ActionManager.add_score(self)
      ActionManager.push_cut_in_effect(ClearEffect.new)
      self.collision_enable = false
    end

    def draw
      super
      @twinkle_effect.draw
    end

    def break
    end

    def update
      super
      @twinkle_effect.update
    end

    class TwinkleEffect < ::DXRuby::Sprite
      include HelperMethods

      IMAGE_SPLIT_X = 8
      IMAGE_SPLIT_Y = 1
      IMAGES = load_image_tiles('clear_item_effect', IMAGE_SPLIT_X, IMAGE_SPLIT_Y)
      IMAGE_UPDATE_FREQUENCY = 3

      def initialize(clear_item)
        @count = 0
        y = clear_item.y + clear_item.image.height - IMAGES.first.height
        super(clear_item.x, y, current_image)
      end

      def draw
        super
      end

      def update
        # super
        @count += 1
        self.image = current_image
      end

      def image_count
        (@count / IMAGE_UPDATE_FREQUENCY) % IMAGE_SPLIT_X
      end

      def current_image
        IMAGES[image_count]
      end
    end
  end
end

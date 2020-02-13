module DigYukko
  # コスチュームの基本クラス
  class Costume
    include HelperMethods

    # 本クラスを継承する場合、以下の定数を定義すること
    #
    # IMAGE_SPLIT_X = 8
    # IMAGE_SPLIT_Y = 2
    # IMAGES = load_image_tiles('star_yukko', IMAGE_SPLIT_X, IMAGE_SPLIT_Y)

    class Weapon < ::DXRuby::Sprite
      # 本クラスを継承する場合、以下の定数を定義すること
      # TODO: アニメーション可能なものにする
      #
      # X_IMAGE = Image.new(5, 30, ::DXRuby::C_BLUE)
      # Y_IMAGE = Image.new(32, 5, ::DXRuby::C_BLUE)

      attr_reader :yukko

      def initialize(yukko)
        @yukko = yukko
        super(@yukko.x, @yukko.y, self.class::X_IMAGE)
        self.target = @yukko.target
        disable
      end

      def enabled?
        self.visible && self.collision_enable
      end

      def enable(key_x, key_y)
        if key_y.zero?
          self.image = self.class::X_IMAGE
          if key_x > 0 || @yukko.x_dir > 0
            self.x = @yukko.x + @yukko.width
          elsif key_x < 0 || @yukko.x_dir < 0
            self.x = @yukko.x - self.image.width
          end
          self.y = @yukko.y
        else
          self.image = self.class::Y_IMAGE
          self.x = @yukko.x
          self.y = (key_y < 0) ? (@yukko.y - self.image.height) : @yukko.foot_y
        end
        self.visible = true
        self.collision_enable = true
      end

      def disable
        self.visible = false
        self.collision_enable = false
      end

      def shot(obj)
        obj.break
      end

      def check_target
        self
      end
    end

    attr_reader :width, :height, :weapon

    def initialize(yukko)
      @yukko = yukko
      @width = self.class::IMAGES.first.width
      @height = self.class::IMAGES.first.height
      @weapon = self.class::Weapon.new(@yukko)
    end

    def current_image
      image_y = Yukko::DIR.values.index(@yukko.x_dir)
      image_x = @yukko.animation_frame.floor
      self.class::IMAGES[image_y * self.class::IMAGE_SPLIT_X + image_x]
    end

    def update_weapon
      # TODO: 武器の見た目の更新
    end

    def item_table
      raise NotImplementedError
    end
  end
end

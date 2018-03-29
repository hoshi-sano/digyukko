module DigYukko
  # 飛び道具コスチューム
  class ProjectileCostume < Costume
    IMAGE_SPLIT_X = 8
    IMAGE_SPLIT_Y = 2
    IMAGES = load_image_tiles('projectile_yukko', IMAGE_SPLIT_X, IMAGE_SPLIT_Y)
    # TODO: カットイン用の画像を用意する
    CUT_IN_IMAGE = Image.new(300, 300, ::DXRuby::C_WHITE)

    def update_weapon
      super
      @weapon.update_projectiles
    end

    class Weapon < ::DigYukko::Costume::Weapon
      X_IMAGE = Image.new(1, 1, ::DXRuby::C_BLUE)
      Y_IMAGE = Image.new(32, 5, ::DXRuby::C_BLUE)
      PROJECTILE_IMAGE = Image.new(10, 5, ::DXRuby::C_YELLOW)

      def initialize(yukko)
        super
        @projectiles = []
      end

      def draw
        super
        @projectiles.each(&:draw)
      end

      def check_target
        [self, @projectiles]
      end

      def enable(key_x, key_y)
        super
        if @projectiles.size < 3 && key_y.zero?
          @projectiles << Projectile.new(self)
        end
      end

      def update_projectiles
        @projectiles.delete_if(&:vanished?)
        @projectiles.each(&:update)
      end

      # 射出物
      class Projectile < ::DXRuby::Sprite
        SPEED = 6

        def initialize(weapon)
          yukko = weapon.yukko
          super(yukko.mid_x, yukko.mid_y, ProjectileCostume::Weapon::PROJECTILE_IMAGE)
          @direction = yukko.x_dir
          self.target = weapon.target
        end

        def update
          self.x = self.x + (self.class::SPEED * @direction)
          vanish if self.x < 0 || self.x > Config['window.width']
        end

        def shot(obj)
          obj.break
          vanish
        end
      end
    end
  end
end

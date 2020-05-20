module DigYukko
  # 飛び道具コスチューム
  class ProjectileCostume < Costume
    IMAGE_SPLIT_X = 8
    IMAGE_SPLIT_Y = 2
    IMAGES = load_image_tiles('projectile_yukko', IMAGE_SPLIT_X, IMAGE_SPLIT_Y)
    CUT_IN_IMAGE = load_image('projectile_costume_cut_in')

    set_max_extra_power 200
    set_attacking_time 5

    def update_weapon
      super
      @weapon.update_projectiles
      @extra_weapon.update_projectiles
    end

    def item_table
      {
        ProjectileCostumeItem => :zero,
        BoundCostumeItem => 2,
        DashCostumeItem => 2,
      }
    end

    class Weapon < ::DigYukko::Costume::Weapon
      include HelperMethods

      X_IMAGE = Image.new(1, 1, debug_color)
      Y_IMAGE = Image.new(32, 5, debug_color)
      IMAGE_SPLIT_X = 4
      IMAGE_SPLIT_Y = 2
      PROJECTILE_IMAGES = load_image_tiles('projectile', IMAGE_SPLIT_X, IMAGE_SPLIT_Y)
      MAX_PROJECTILE_NUM = 3

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
        if key_y.zero?
          if @projectiles.size < self.class::MAX_PROJECTILE_NUM
            @projectiles << self.class::Projectile.new(self)
            true
          end
        else
          self.image = self.class::Y_IMAGE
          self.x = @yukko.x
          self.y = (key_y < 0) ? (@yukko.y - self.image.height) : @yukko.foot_y
          self.visible = true
          self.collision_enable = true
          true
        end
      end

      def update_projectiles
        @projectiles.delete_if(&:vanished?)
        @projectiles.each(&:update)
      end

      # 射出物
      class Projectile < ::DXRuby::Sprite
        SPEED = 5
        IMAGE_SAMPLE = ProjectileCostume::Weapon::PROJECTILE_IMAGES.first

        def initialize(weapon)
          yukko = weapon.yukko
          super(yukko.x + (yukko.x_dir * IMAGE_SAMPLE.width / 2),
                yukko.mid_y - (IMAGE_SAMPLE.height / 2),
                IMAGE_SAMPLE)
          @direction = yukko.x_dir
          @image_y = Yukko::DIR.values.index(yukko.x_dir)
          @image_x_frame = 0
          self.target = weapon.target
        end

        def update
          self.image = current_image
          @image_x_frame += 0.5
          @image_x_frame = @image_x_frame % ProjectileCostume::Weapon::IMAGE_SPLIT_X
          self.x = self.x + (self.class::SPEED * @direction)
          vanish if self.x < 0 || self.x > Config['window.width']
        end

        def current_image
          ProjectileCostume::Weapon::PROJECTILE_IMAGES[
            @image_y * ProjectileCostume::Weapon::IMAGE_SPLIT_X + @image_x_frame
          ]
        end

        def shot(obj)
          obj.break
          vanish
        end
      end
    end

    class ExtraWeapon < ProjectileCostume::Weapon
      def enable(key_x, key_y)
        if @projectiles.size < self.class::MAX_PROJECTILE_NUM
          @projectiles << self.class::Projectile.new(self)
          true
        end
      end

      class Projectile < ProjectileCostume::Weapon::Projectile
        def shot(obj)
          obj.break
        end
      end
    end
  end
end

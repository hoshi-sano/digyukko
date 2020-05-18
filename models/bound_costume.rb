module DigYukko
  # 跳ね飛び道具コスチューム
  class BoundCostume < ProjectileCostume
    IMAGE_SPLIT_X = 8
    IMAGE_SPLIT_Y = 2
    IMAGES = load_image_tiles('bound_ball_yukko', IMAGE_SPLIT_X, IMAGE_SPLIT_Y)
    CUT_IN_IMAGE = load_image('bound_ball_costume_cut_in')

    set_max_extra_power 300
    set_attacking_time 5

    def item_table
      {
        ProjectileCostumeItem => :zero,
        BoundCostumeItem => :zero,
        # TODO: 上位コスチューム
      }
    end

    class Weapon < ::DigYukko::ProjectileCostume::Weapon
      IMAGE_SPLIT_X = 2
      IMAGE_SPLIT_Y = 2
      BALL_IMAGES = load_image_tiles('bound_ball', IMAGE_SPLIT_X, IMAGE_SPLIT_Y)
      MAX_PROJECTILE_NUM = 2
      PROJECTILE_TTL = 1

      # 射出物
      class Projectile < ::DXRuby::Sprite
        X_SPEED = 3
        Y_SPEED_INIT = -8
        Y_SPEED_DIFF = 1

        def initialize(weapon)
          @yukko = weapon.yukko
          img = BALL_IMAGES.first
          x = (@yukko.x_dir < 0) ? @yukko.x - img.width : @yukko.x + @yukko.width
          super(x, @yukko.foot_y - img.height, img)
          @direction = @yukko.x_dir
          @image_y = Yukko::DIR.values.index(@yukko.x_dir)
          @y_speed = Y_SPEED_INIT
          @ttl = weapon.class::PROJECTILE_TTL
          self.target = weapon.target
        end

        def update
          @bounded = false
          self.image = current_image
          self.y += @y_speed
          @y_speed += self.class::Y_SPEED_DIFF
          self.x = self.x + (self.class::X_SPEED * @direction)
          vanish if @ttl <= 0 || self.x < 0 || self.y < (@yukko.y - (Config['window.height'] / 2)) ||
                    self.x > Config['window.width'] || self.y > (@yukko.y + (Config['window.height'] / 2))
        end

        def current_image
          @y_speed > 0 ? BALL_IMAGES[@image_y * IMAGE_SPLIT_Y + 0] : BALL_IMAGES[@image_y * IMAGE_SPLIT_Y + 1]
        end

        def shot(obj)
          obj.break
          return if @bounded
          bound(obj)
        end

        def bound(obj)
          @bounded = true
          if @y_speed > 0
            @y_speed = Y_SPEED_INIT
            self.y = obj.y - self.image.height - 1
            @ttl -= 1 unless obj.is_a?(UnbreakableBlock)
          else
            vanish if obj.is_a?(UnbreakableBlock)
          end
        end
      end
    end

    class ExtraWeapon < BoundCostume::Weapon
      PROJECTILE_TTL = 10

      def enable(key_x, key_y)
        super
        current_x_dir = @yukko.x_dir
        Yukko::DIR.values.each do |dir|
          @yukko.instance_variable_set(:@x_dir, dir)
          @projectiles << self.class::Projectile.new(self)
        end
        @yukko.instance_variable_set(:@x_dir, current_x_dir)
      end
    end
  end
end

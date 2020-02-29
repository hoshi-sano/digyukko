module DigYukko
  # 跳ね飛び道具コスチューム
  class BoundCostume < ProjectileCostume
    IMAGE_SPLIT_X = 8
    IMAGE_SPLIT_Y = 2
    # TODO: 画像は暫定
    IMAGES = load_image_tiles('projectile_yukko', IMAGE_SPLIT_X, IMAGE_SPLIT_Y)
    CUT_IN_IMAGE = load_image('projectile_costume_cut_in')

    set_max_extra_power 300

    def item_table
      {
        ProjectileCostumeItem => :zero,
        BoundCostumeItem => :zero,
        # TODO: 上位コスチューム
      }
    end

    class Weapon < ::DigYukko::ProjectileCostume::Weapon
      # TODO: 正式な画像に変換
      BALL_IMAGES = [
        [
          ::DXRuby::Image.new(16, 16).tap { |i| i.circle_fill(8, 8, 8, ::DXRuby::C_RED) },
          ::DXRuby::Image.new(16, 16).tap { |i| i.box_fill(0, 8, 16, 16, ::DXRuby::C_RED) }
        ],
        [
          ::DXRuby::Image.new(16, 16).tap { |i| i.circle_fill(8, 8, 8, ::DXRuby::C_YELLOW) },
          ::DXRuby::Image.new(16, 16).tap { |i| i.box_fill(0, 8, 16, 16, ::DXRuby::C_YELLOW) }
        ],
      ]
      MAX_PROJECTILE_NUM = 2
      PROJECTILE_TTL = 1

      # 射出物
      class Projectile < ::DXRuby::Sprite
        X_SPEED = 3
        Y_SPEED_INIT = -8
        Y_SPEED_DIFF = 1

        def initialize(weapon)
          yukko = weapon.yukko
          img = BALL_IMAGES.first.first
          super(yukko.x + (yukko.x_dir * img.width / 2),
          yukko.mid_y - (img.height / 2),
          img)
          @direction = yukko.x_dir
          @image_y = Yukko::DIR.values.index(yukko.x_dir)
          @image_x = 0
          @y_speed = Y_SPEED_INIT
          @ttl = weapon.class::PROJECTILE_TTL
          self.target = weapon.target
        end

        def update
          self.image = current_image
          self.y += @y_speed
          @y_speed += self.class::Y_SPEED_DIFF
          self.x = self.x + (self.class::X_SPEED * @direction)
          vanish if @ttl <= 0 || self.x < 0 || self.x > Config['window.width']
        end

        def current_image
          @y_speed > 0 ? BALL_IMAGES[@image_y][1] : BALL_IMAGES[@image_y][0]
        end

        def shot(obj)
          obj.break
          if (obj.y > self.y) && (obj.y < self.y + @y_speed.abs)
            @y_speed = Y_SPEED_INIT
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

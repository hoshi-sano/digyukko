module DigYukko
  # 初期コスチューム
  class DefaultCostume < Costume
    IMAGE_SPLIT_X = 8
    IMAGE_SPLIT_Y = 2
    IMAGES = load_image_tiles('default_yukko', IMAGE_SPLIT_X, IMAGE_SPLIT_Y)

    set_max_extra_power 100
    set_attacking_time 10

    class Weapon < ::DigYukko::Costume::Weapon
      X_IMAGE = load_image('default_weapon_x')
      Y_IMAGE = load_image('default_weapon_y')
    end

    class ExtraWeapon < ::DigYukko::Costume::ExtraWeapon
      X_IMAGE = load_image('default_extra_weapon')
      Y_IMAGE = X_IMAGE

      def enable(key_x, key_y)
        if key_y.zero?
          if key_x > 0 || @yukko.x_dir > 0
            self.x = @yukko.x + @yukko.width
          elsif key_x < 0 || @yukko.x_dir < 0
            self.x = @yukko.x - self.image.width
          end
          self.image = self.class::X_IMAGE
          self.y = @yukko.y
        else
          if key_x > 0 || @yukko.x_dir > 0
            self.x = @yukko.x
          elsif key_x < 0 || @yukko.x_dir < 0
            self.x = @yukko.x - (self.image.width - @yukko.width)
          end
          self.image = self.class::Y_IMAGE
          self.y = (key_y < 0) ? (@yukko.y - self.image.height) : @yukko.foot_y
        end
        self.visible = true
        self.collision_enable = true
        true
      end
    end

    def item_table
      {}
    end
  end
end

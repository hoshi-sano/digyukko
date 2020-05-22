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
    end

    def item_table
      {}
    end
  end
end

module DigYukko
  # 初期コスチューム
  class DefaultCostume < Costume
    IMAGE_SPLIT_X = 8
    IMAGE_SPLIT_Y = 2
    # TODO: 画像を初期キャラクター画像にする
    IMAGES = load_image_tiles('star_yukko', IMAGE_SPLIT_X, IMAGE_SPLIT_Y)

    class Weapon < ::DigYukko::Costume::Weapon
      X_IMAGE = Image.new(5, 30, ::DXRuby::C_BLUE)
      Y_IMAGE = Image.new(32, 5, ::DXRuby::C_BLUE)
    end
  end
end

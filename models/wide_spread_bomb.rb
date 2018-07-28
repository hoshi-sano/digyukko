module DigYukko
  # 3x3の範囲で爆発する爆弾クラス
  class WideSpreadBomb < Bomb
    # TODO: 専用の画像を用意する
    set_image load_image('breakable_block').tap { |img|
      img.circle_fill(img.width / 2, img.height / 2, img.width / 2, ::DXRuby::C_RED)
    }
    set_score 100
    set_power 25
    set_x_range -1..1
    set_y_range -1..1
  end
end

module DigYukko
  class HorizontalBomb < Bomb; end

  # 7x1の範囲で爆発する爆弾クラス
  class HorizontalBomb1 < HorizontalBomb
    set_image load_image('horizontal_bomb_1')
    set_score 100
    set_power 25
    set_x_range -3..3
    set_y_range 0..0
  end

  # 11x2の範囲で爆発する爆弾クラス
  class HorizontalBomb2 < HorizontalBomb
    set_image load_image('horizontal_bomb_2')
    set_score 500
    set_power 25
    set_x_range -5..5
    set_y_range 0..0
  end

  # 21x4の範囲で爆発する爆弾クラス
  class HorizontalBomb3 < HorizontalBomb
    set_image load_image('horizontal_bomb_3')
    set_score 1000
    set_power 25
    set_x_range -10..10
    set_y_range -1..1
  end
end

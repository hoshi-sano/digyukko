module DigYukko
  class VerticalBomb < Bomb; end

  # 1x7の範囲で爆発する爆弾クラス
  class VerticalBomb1 < VerticalBomb
    set_image load_image('vertical_bomb_1')
    set_score 100
    set_power 25
    set_x_range 0..0
    set_y_range -3..3
  end

  # 2x11の範囲で爆発する爆弾クラス
  class VerticalBomb2 < VerticalBomb
    set_image load_image('vertical_bomb_2')
    set_score 500
    set_power 25
    set_x_range 0..0
    set_y_range -5..5
  end

  # 4x21の範囲で爆発する爆弾クラス
  class VerticalBomb3 < VerticalBomb
    set_image load_image('vertical_bomb_3')
    set_score 1000
    set_power 25
    set_x_range -1..1
    set_y_range -10..10
  end
end

module DigYukko
  class WideSpreadBomb < Bomb; end

  # 3x3の範囲で爆発する爆弾クラス
  class WideSpreadBomb1 < WideSpreadBomb
    set_image load_image('wide_spread_bomb_1')
    set_score 100
    set_power 25
    set_x_range -1..1
    set_y_range -1..1
  end

  # 5x5の範囲で爆発する爆弾クラス
  class WideSpreadBomb2 < WideSpreadBomb
    set_image load_image('wide_spread_bomb_2')
    set_score 500
    set_power 25
    set_x_range -2..2
    set_y_range -2..2
  end

  # 7x7の範囲で爆発する爆弾クラス
  class WideSpreadBomb3 < WideSpreadBomb
    set_image load_image('wide_spread_bomb_3')
    set_score 1000
    set_power 25
    set_x_range -3..3
    set_y_range -3..3
  end
end

module DigYukko
  # 爆弾の爆発範囲管理用オブジェクト
  class BombRange < ::DXRuby::Sprite
    # 爆発範囲オブジェクトはアルファ値で爆発までのリミットを表現する
    # アルファ値がLIMITに達したら爆発処理に遷移する
    LIMIT = 100

    # 1フレームあたりにアルファ値に加算する数
    UPDATE_UNIT = 3

    IMAGE = ::DXRuby::Image.new(Bomb.image.width, Bomb.image.height, ::DXRuby::C_RED)

    def initialize(bomb, x_range, y_range)
      @bomb = bomb
      super(@bomb.x, @bomb.y, IMAGE)
      self.center_x = Bomb.image.width / 2
      self.center_y = Bomb.image.height / 2
      self.scale_x = x_range
      self.scale_y = y_range
      self.alpha = 0
      self.z = 255
    end

    def update
      self.alpha += UPDATE_UNIT
    end

    def limit?
      self.alpha >= LIMIT
    end
  end
end

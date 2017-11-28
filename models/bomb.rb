module DigYukko
  class Bomb < BreakableBlock
    CODE = 2

    # 爆弾の爆発範囲管理用オブジェクト
    class Range < ::DXRuby::Sprite
      # 爆発範囲オブジェクトはアルファ値で爆発までのリミットを表現する
      # アルファ値がLIMITに達したら爆発処理に遷移する
      LIMIT = 100

      # 1フレームあたりにアルファ値に加算する数
      UPDATE_UNIT = 3

      def initialize(bomb, x_range, y_range)
        @bomb = bomb
        image = ::DXRuby::Image.new(Bomb.image.width * x_range,
                                    Bomb.image.height * y_range,
                                    ::DXRuby::C_RED)
        bomb_x = @bomb.x + @bomb.image.width / 2
        bomb_y = @bomb.y + @bomb.image.height / 2
        super(bomb_x - image.width / 2, bomb_y - image.height / 2, image)
        self.alpha = 0
        self.z = 255
      end

      def update
        self.alpha += UPDATE_UNIT
      end

      def limit?
        self.alpha >= LIMIT
      end

      def shot(obj)
        obj.break
        # TODO: objがYukkoならダメージ
      end
    end

    # TODO: 専用の画像を用意する
    # TODO: 1種類だけではなく、爆弾の種類によって画像を変える
    set_image load_image('breakable_block').tap { |img|
                img.circle_fill(img.width / 2, img.height / 2, img.width / 2, ::DXRuby::C_RED)
              }

    def update
      if @ignition
        # 着火中なら爆発範囲オブジェクトのupdateを行う
        # 爆発範囲オブジェクトのカウントがリミットに達したら爆発
        @range_obj.update
        explosion! if @range_obj.limit?
      elsif @explosion
        # 爆発中なら爆発エフェクトのupdateを行う
        # 爆発エフェクトが完了したらすべての処理を終了する
        update_bomb_effect
        @bomb_effect_count += 1
        if bomb_effect_finished?
          @explosion = false
          vanish
        end
      end
    end

    def draw
      super
      @range_obj.draw if @ignition
    end

    # TODO: 動的に生成するのではなくて予め生成して定数にしておく
    def update_bomb_effect
      self.image.clear
      self.image.circle_fill(self.image.width / 2,
                             self.image.height / 2,
                             self.image.width / 2,
                             ::DXRuby::C_YELLOW)
      self.image.circle_fill(self.image.width / 3,
                             self.image.height / 1.5,
                             @bomb_effect_count * 3,
                             [0, 0, 0, 0])
    end

    def bomb_effect_finished?
      @bomb_effect_count >= 12
    end

    def break
      return if @ignition
      @ignition = true
      @range_obj = Range.new(self, 3, 3)
      @range_obj.target = self.target
    end

    def explosion!
      @ignition = false
      @explosion = true
      @bomb_effect_count = 0
      self.image = ::DXRuby::Image.new(self.image.width, self.image.height)
      self.collision_enable = false

      ::DXRuby::Sprite.check(@range_obj, @map.blocks)
    end
  end
end

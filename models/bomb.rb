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

      # TODO: マジックナンバーをやめる
      IMAGE = ::DXRuby::Image.new(32, 32, ::DXRuby::C_RED)

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

      def shot(obj)
        if obj.is_a?(Yukko)
          obj.damage(@bomb.power)
        else
          obj.break
        end
      end
    end

    # TODO: 専用の画像を用意する
    # TODO: 1種類だけではなく、爆弾の種類によって画像を変える
    set_image load_image('breakable_block').tap { |img|
                img.circle_fill(img.width / 2, img.height / 2, img.width / 2, ::DXRuby::C_RED)
              }
    set_score 100
    set_power 25

    def update
      if @ignition
        # 着火中なら爆発範囲オブジェクトのupdateを行う
        # 爆発範囲オブジェクトのカウントがリミットに達したら爆発
        @range_obj.update
        explosion! if @range_obj.limit?
      elsif @explosion
        # 爆発エフェクトが完了したらすべての処理を終了する
        # 爆発エフェクトのupdateはmap側で行われるのでここでは完了チェックのみ
        if @bomb_effect.finished?
          @explosion = false
          vanish
        end
      end
    end

    def draw
      super
      @range_obj.draw if @ignition
      @bomb_effect.draw if @explosion
    end

    def break
      return if @ignition
      ActionManager.combo
      ActionManager.add_score(self)
      @ignition = true
      @range_obj = Range.new(self, 3, 3)
      @range_obj.target = self.target
    end

    def generate_bomb_effects
      res =
        [[-1, -1], [ 0, -1], [ 1, -1],
         [-1,  0], [ 0,  0], [ 1,  0],
         [-1,  1], [ 0,  1], [ 1,  1]].map do |dx, dy|
        BombEffect.new(self.x + dx * self.width, self.y + dy * self.height)
      end
      @bomb_effect = res[4]
      res
    end

    def explosion!
      @ignition = false
      @explosion = true
      self.visible = false
      @map.push_effects(generate_bomb_effects)
      self.collision_enable = false

      ::DXRuby::Sprite.check(@range_obj, @map.field_objects)
      ::DXRuby::Sprite.check(@range_obj, @map.yukko)
    end
  end
end

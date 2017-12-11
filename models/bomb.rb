module DigYukko
  # 爆弾の基本クラス
  class Bomb < BreakableBlock
    class << self
      def set_x_range(range)
        @x_range = range
      end

      def x_range
        @x_range
      end

      def set_y_range(range)
        @y_range = range
      end

      def y_range
        @y_range
      end
    end

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

    def x_range
      self.class.x_range
    end

    def y_range
      self.class.y_range
    end

    def break
      return if @ignition
      ActionManager.combo
      ActionManager.add_score(self)
      @ignition = true
      @range_obj = BombRange.new(self, x_range.to_a.size, y_range.to_a.size)
      @range_obj.target = self.target
    end

    def generate_bomb_effects
      res = []
      y_range.each do |dy|
        x_range.each do |dx|
          res << BombEffect.new(self.x + dx * self.width, self.y + dy * self.height)
        end
      end
      @bomb_effect = res[res.size / 2]
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

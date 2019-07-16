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
        ::DXRuby::Sprite.update(@bomb_effects)
        @bomb_effects.delete_if(&:vanished?)
        ::DXRuby::Sprite.check(@bomb_effects, @map.field_objects)
        ::DXRuby::Sprite.check(@bomb_effects, @map.yukko)
        # 最も遠い爆発エフェクトが完了したらすべての処理を終了する
        # 爆発エフェクトのupdateはmap側で行われるのでここでは完了チェックのみ
        if @farthest_bomb_effect.finished?
          @explosion = false
          vanish
        end
      end
    end

    def draw
      super
      @range_obj.draw if @ignition || @explosion
      ::DXRuby::Sprite.draw(@bomb_effects) if @explosion
    end

    def x_range
      self.class.x_range
    end

    def y_range
      self.class.y_range
    end

    def break
      return if @ignition
      SE.play(:pre_bomb)
      ActionManager.combo
      ActionManager.add_score(self)
      @ignition = true
      @range_obj = BombRange.new(self, x_range.to_a.size, y_range.to_a.size)
      @range_obj.target = self.target
    end

    def generate_bomb_effects
      @bomb_effects = []
      farthest = 0
      y_range.each do |dy|
        x_range.each do |dx|
          effect_x = self.x + dx * self.width
          effect_y = self.y + dy * self.height
          delay = [dx, dy].map(&:abs).max
          effect = BombEffect.new(effect_x, effect_y, power, delay)
          effect.target = self.target
          @bomb_effects << effect

          @farthest_bomb_effect ||= effect
          if delay > farthest
            farthest = delay
            @farthest_bomb_effect = effect
          end
        end
      end
      @bomb_effects
    end

    def explosion!
      @ignition = false
      @explosion = true
      self.visible = false
      generate_bomb_effects
      self.collision_enable = false
    end
  end
end

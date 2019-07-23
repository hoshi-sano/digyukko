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

    EMPTY_HASH = {}

    attr_reader :map

    def update
      if @ignition
        # 爆発エフェクトの警告カウントがリミットに達したら爆発
        ::DXRuby::Sprite.update(@bomb_effects)
        # explosion! if bomb_effect(0, 0).limit?
        if bomb_effect(0, 0).limit?
          @bomb_effects.each(&:wait_ignition!)
          explosion!
        end
      elsif @explosion
        ::DXRuby::Sprite.update(@bomb_effects)
        @bomb_effects.delete_if(&:vanished?)
        ::DXRuby::Sprite.check(@bomb_effects, @map.field_objects)
        ::DXRuby::Sprite.check(@bomb_effects, @map.yukko)
        if @bomb_effects.empty?
          @explosion = false
          vanish
        end
      end
    end

    def draw
      super
      # TODO: 描画も爆発処理と同じく伝搬する形式で実行されるようにする
      ::DXRuby::Sprite.draw(@bomb_effects) if @ignition || @explosion
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
      generate_bomb_effects
    end

    def set_bomb_effect(effect_x, effect_y, distance = 0)
      @bomb_effects_window ||= {}
      @bomb_effects_window[effect_x] ||= {}

      return nil unless (x_range.include?(effect_x) && y_range.include?(effect_y))
      return nil if bomb_effect(effect_x, effect_y)

      effect = BombEffect.new(self, effect_x, effect_y, distance)
      @bomb_effects_window[effect_x][effect_y] = effect

      @bomb_effects ||= []
      @bomb_effects << effect

      effect
    end

    def bomb_effect(effect_x, effect_y)
      (@bomb_effects_window[effect_x] || EMPTY_HASH)[effect_y]
    end

    def generate_bomb_effects
      new_effects = [set_bomb_effect(0, 0)]
      while(new_effects.any?)
        effects = []
        new_effects.each do |effect|
          effects << effect.generate_next_effects
        end
        new_effects = effects.flatten
      end
    end

    def explosion!
      @ignition = false
      @explosion = true
      self.visible = false
      self.collision_enable = false
      # 最初に中心の爆発エフェクトのみを発生させ遠くに向かって伝搬させる
      bomb_effect(0, 0).ignition!
    end
  end
end

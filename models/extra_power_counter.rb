module DigYukko
  class ExtraPowerCounter
    attr_reader :count

    POSITION = { x: 10, y: 45 }
    BG_IMAGE = ::DXRuby::Image.new(1, 10, ::DXRuby::C_BLACK)
    GAGE_IMAGE = ::DXRuby::Image.new(1, 10, ::DXRuby::C_CYAN)
    GAGE_UPDATE_UNIT = 1

    def initialize(yukko)
      @yukko = yukko
      @max = @yukko.max_extra_power
      @count = @yukko.extra_power

      @bg = ::DXRuby::Sprite.new(POSITION[:x], POSITION[:y], BG_IMAGE)
      @gage = ::DXRuby::Sprite.new(POSITION[:x], POSITION[:y], GAGE_IMAGE)
      @gages = [@bg, @gage]
      @gages.each { |g| g.center_x = 0 }
      adjust_max_scale
      adjust_count_scale
    end

    def update
      adjust_count_scale
    end

    def zero!
      @count = 0
    end

    def skill_available?
      @count >= @max
    end

    # 現在のコスチュームの最大値をセットする
    # カウントは旧最大値との割合を維持する
    def reset_max
      ratio = (@count / @max.to_f).round(2)
      @max = @yukko.max_extra_power
      @count = (@max * ratio).floor
      adjust_max_scale
      adjust_count_scale
    end

    def count_up(combo_count)
      return if skill_available?
      # TODO: いい感じの加算になるよう調整する
      @count += 1 + (combo_count / 20)
      if @count >= @max
        @count = @max
        @yukko.fire_extra_power_charged_effect
      end
    end

    def adjust_max_scale
      @bg.scale_x = (@max * (100 / @max.to_f)).floor
    end

    def adjust_count_scale
      @gage.scale_x = (@count * (100 / @max.to_f)).floor
    end

    def draw
      ::DXRuby::Sprite.draw(@gages)
    end
  end
end

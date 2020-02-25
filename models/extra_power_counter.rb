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
      adjust_scale
    end

    def update
      adjust_scale
    end

    def reset_max
      @max = @yukko.max_extra_power
    end

    def count_up(combo_count)
      return if @count >= @max
      # TODO: いい感じの加算になるよう調整する
      @count += combo_count
      if @count > @max
        @count = @max
        # TODO: @yukko.fire_extra_power_effect
        SE.play(:ok) # TODO: 専用の音を用意する
      end
    end

    def adjust_scale
      @bg.scale_x = @max
      @gage.scale_x = @count
    end

    def draw
      ::DXRuby::Sprite.draw(@gages)
    end
  end
end

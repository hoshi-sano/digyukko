module DigYukko
  class LifeCounter
    attr_reader :count

    POSITION = { x: 10, y: 30 }
    BG_IMAGE = ::DXRuby::Image.new(1, 10, ::DXRuby::C_BLACK)
    PROGRESS_GAGE_IMAGE = ::DXRuby::Image.new(1, 10, ::DXRuby::C_RED)
    GAGE_IMAGE = ::DXRuby::Image.new(1, 10, ::DXRuby::C_GREEN)
    GAGE_UPDATE_UNIT = 1

    def initialize(yukko)
      @yukko = yukko
      @max = @yukko.max_life
      @count = @yukko.life
      @prev_count = @yukko.life

      @bg = ::DXRuby::Sprite.new(POSITION[:x], POSITION[:y], BG_IMAGE)
      @progress = ::DXRuby::Sprite.new(POSITION[:x], POSITION[:y], PROGRESS_GAGE_IMAGE)
      @gage = ::DXRuby::Sprite.new(POSITION[:x], POSITION[:y], GAGE_IMAGE)
      @gages = [@bg, @progress, @gage]
      @gages.each { |g| g.center_x = 0 }
      adjust_scale
    end

    # 現象したライフが一気に減算・表示されるのではなく
    # 徐々に減少するのを表現する
    def update
      @count = @yukko.life
      return if @count == @prev_count
      @prev_count -= GAGE_UPDATE_UNIT
      @prev_count = @count if @prev_count < @count
      adjust_scale
    end

    def adjust_scale
      @bg.scale_x = @max
      @progress.scale_x = @prev_count
      @gage.scale_x = @count
    end

    def draw
      ::DXRuby::Sprite.draw(@gages)
    end
  end
end

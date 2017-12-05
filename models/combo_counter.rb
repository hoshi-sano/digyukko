module DigYukko
  class ComboCounter
    attr_reader :count

    POSITION = { x: Config['window.width'] - 80, y: 60 }
    DISPLAY_THRESHOLD = 2
    COMBO_TIMER = 60
    TIMER_GAGE_IMAGE = ::DXRuby::Image.new(1, 5, [255, 155, 0])
    # コンボ数の表示用オプション
    NUMBER_OPTIONS = {
      color: ::DXRuby::C_WHITE,
      edge: true,
      edge_color: [255, 155, 0],
      edge_width: 3,
    }
    COMBO_STR = 'COMBO'
    # 「COMBO」という文字列の表示用オプション
    COMBO_STR_OPTIONS = {
      edge: true,
      edge_color: [255, 155, 0],
      edge_width: 5,
      edge_level: 5,
    }
    MAX_COMBO_STR = 'MAX COMBO: %d'
    MAX_COMBO_STR_OPTIONS = {
      color: ::DXRuby::C_WHITE,
      edge: true,
      edge_color: ::DXRuby::C_BLACK,
    }


    def initialize
      reset
      @timer = 0
      @scale = 1.0
      @timer_gage = ::DXRuby::Sprite.new(POSITION[:x] - 30,
                                         POSITION[:y] + 55, TIMER_GAGE_IMAGE)
      @timer_gage.center_x = 0
      @max_combo = 0
      update_count_str
      @max_combo_str = sprintf(MAX_COMBO_STR, @max_combo)
    end

    def update_count_str
      @count_str = @count.to_s
    end

    def reset
      @count = 0
    end

    def count_up
      @stop = false
      @count += 1
      @timer = COMBO_TIMER
      @scale = 0.2
      update_count_str
      if @count > @max_combo
        @max_combo = @count
        @max_combo_str = sprintf(MAX_COMBO_STR, @max_combo)
      end
    end

    def stop
      @stop = true
    end

    def update
      return if @timer.zero? || @stop
      @timer -= 1
      @timer_gage.scale_x = @timer
      reset if @timer.zero?
    end

    def draw
      ::DXRuby::Window.draw_font_ex(POSITION[:x] - 120,
                                    POSITION[:y] - 30,
                                    @max_combo_str,
                                    FONT[:regular],
                                    MAX_COMBO_STR_OPTIONS)
      return if @count < DISPLAY_THRESHOLD
      opts = NUMBER_OPTIONS.merge(scale_x: @scale * 2, scale_y: @scale * 2)
      ::DXRuby::Window.draw_font_ex(POSITION[:x],
                                    POSITION[:y],
                                    @count_str,
                                    FONT[:regular],
                                    opts)
      ::DXRuby::Window.draw_font_ex(POSITION[:x] - 30,
                                    POSITION[:y] + 30,
                                    COMBO_STR,
                                    FONT[:regular],
                                    COMBO_STR_OPTIONS)
      @timer_gage.draw
      # 次の拡大率の計算。最終的に1.0に収束する
      @scale = (1 + Math.log10(@scale)).to_r.ceil(1).to_f
    end
  end
end

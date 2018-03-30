module DigYukko
  class ScoreCounter
    POSITION = { x: Config['window.width'] - 200, y: 10 }
    STR_FORMAT = 'SCORE: %010d'
    OPTIONS = {
      color: ::DXRuby::C_WHITE,
      edge: true,
      edge_color: ::DXRuby::C_BLACK,
    }
    COUNT_UPDATE_UNIT = 4

    attr_accessor :count

    def initialize(combo_counter, depth_counter, score = 0)
      @combo_counter = combo_counter
      @depth_counter = depth_counter
      @count = score
      @reserved_count = 0
      update_count_str
    end

    # スコアポイントを返す
    # countには一時的な値が入っていることがあるため、
    # 実態のスコアを取得するときにはこちらを使うこと
    def score
      @count + @reserved_count
    end

    # 取得したスコアポイントが一気に計上・表示されるのではなく
    # 徐々に加算されるのを表現する
    def update
      return if @reserved_count.zero?
      @reserved_count -= COUNT_UPDATE_UNIT
      @count += COUNT_UPDATE_UNIT
      update_count_str
      return if @reserved_count >= 0
      @count += @reserved_count
      @reserved_count = 0
      update_count_str
    end

    def update_count_str
      @count_str = sprintf(STR_FORMAT, @count)
    end

    # 破壊/取得したオブジェクトのスコアポイントに深度ボーナスと
    # コンボボーナスをかけ合わせた数値が取得スコアポイントとなる
    def add(obj)
      @reserved_count += (obj.score * combo_bonus_ratio * depth_bonus_ratio).to_i
    end

    # TODO: 計算式は要調整
    def combo_bonus_ratio
      1 + (@depth_counter.count / 10000.to_r)
    end

    # TODO: 計算式は要調整
    def depth_bonus_ratio
      1 + (@combo_counter.count / 500.to_r)
    end

    def draw
      ::DXRuby::Window.draw_font_ex(POSITION[:x],
                                    POSITION[:y],
                                    @count_str,
                                    FONT[:regular],
                                    OPTIONS)
    end
  end
end

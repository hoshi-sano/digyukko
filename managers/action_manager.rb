module DigYukko
  module ActionManager
    class << self
      def init(yukko = nil, combo_counter = nil, depth_counter = nil, score = 0)
        @map = Map.new
        @yukko = yukko || Yukko.new
        @yukko.map = @map
        @combo_counter = combo_counter || ComboCounter.new
        @depth_counter = depth_counter || DepthCounter.new
        @score_counter = ScoreCounter.new(@combo_counter, @depth_counter)
        @score_counter.count = score
        @life_counter = LifeCounter.new(@yukko)
      end

      def combo
        @combo_counter.count_up
      end

      def add_depth(val)
        @depth_counter.count += val
      end

      def add_score(obj)
        @score_counter.add(obj)
      end

      def update_components
        @yukko.update
        @yukko.check_attack(@map.blocks)
        @map.update
        @combo_counter.update
        @score_counter.update
        @life_counter.update
        @combo_counter.stop if @yukko.over_last_row?
        go_to_next_stage if @yukko.at_bottom?
      end

      def draw_components
        @yukko.draw
        @map.draw
        @combo_counter.draw
        @depth_counter.draw
        @score_counter.draw
        @life_counter.draw
      end

      def check_keys
        @yukko.move(KEY.x)
        @yukko.jump if KEY.down?(KEY.jump)
        @yukko.attack(KEY.x, KEY.y) if KEY.push?(KEY.attack)
        @yukko.nojump unless KEY.down?(KEY.jump)
      end

      def go_to_next_stage
        next_scene =
          ActionScene.new(@yukko, @combo_counter, @depth_counter, @score_counter.count)
        ApplicationManager.change_scene(next_scene)
      end
    end
  end
end

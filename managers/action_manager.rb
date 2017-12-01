module DigYukko
  module ActionManager
    class << self
      def init(*)
        @map = Map.new
        @yukko = Yukko.new(@map)
        @combo_counter = ComboCounter.new
        @depth_counter = DepthCounter.new
        @score_counter = ScoreCounter.new(@combo_counter, @depth_counter)
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
    end
  end
end

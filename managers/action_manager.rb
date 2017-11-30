module DigYukko
  module ActionManager
    class << self
      def init(*)
        @map = Map.new
        @yukko = Yukko.new(@map)
        @combo_counter = ComboCounter.new
      end

      def combo
        @combo_counter.count_up
      end

      def update_components
        @yukko.update
        @yukko.check_attack(@map.blocks)
        @map.update
        @combo_counter.update
      end

      def draw_components
        @yukko.draw
        @map.draw
        @combo_counter.draw
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

module DigYukko
  module ActionManager
    class << self
      def init(*)
        @map = Map.new
        @yukko = Yukko.new(@map)
      end

      def update_components
        @yukko.update
        @yukko.check_attack(@map.blocks)
      end

      def draw_components
        @yukko.draw
        @map.draw
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

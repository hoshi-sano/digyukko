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
        KEY.down_keys.each do |key|
          case key
          when KEY.attack
            @yukko.attack
          when KEY.jump
            @yukko.jump
          when KEY.left
            @yukko.move_left
          when KEY.right
            @yukko.move_right
          end
        end
        @yukko.nojump unless KEY.down?(KEY.jump)
      end
    end
  end
end

module DigYukko
  # 進行度管理用マネージャ
  module LevelManager
    class << self
      def init
        @@current_level = 1
      end

      def calc_level(score)
        while LEVEL_TO_SCORE[@@current_level + 1]
          if score >= LEVEL_TO_SCORE[@@current_level + 1]
            @@current_level += 1
          else
            break
          end
        end
        @@current_level
      end
    end

    LEVEL_TO_SCORE = {
      1 => 0,
      2 => 1_000,
      3 => 5_000,
    }
  end
end

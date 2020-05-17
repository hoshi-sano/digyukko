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

      def current_level
        @@current_level
      end
    end

    LEVEL_TO_SCORE = {
      1 => 0,
      2 => 200,
      3 => 1_000,
      4 => 5_000,
      5 => 10_000,
      6 => 25_000,
      7 => 50_000,
      8 => 75_000,
      9 => 100_000,
      10 => 130_000,
      11 => 160_000,
      12 => 200_000,
      13 => 240_000,
      14 => 290_000,
      15 => 350_000,
      16 => 400_000,
      17 => 450_000,
      18 => 500_000,
      19 => 550_000,
      20 => 600_000,
    }
  end
end

module DigYukko
  class MapObjectTableGenerator
    def self.fetch(score)
      LEVEL_TO_ADDITIONAL_TABLE[calc_level(score)]
    end

    def self.calc_level(score)
      @@current_level ||= 1
      while LEVEL_TO_SCORE[@@current_level + 1]
        if score >= LEVEL_TO_SCORE[@@current_level + 1]
          @@current_level += 1
        else
          break
        end
      end
      @@current_level
    end

    LEVEL_TO_SCORE = {
      1 => 0,
      2 => 1_000,
      3 => 5_000,
    }

    LEVEL_TO_ADDITIONAL_TABLE = {
      1 => {},
      2 => {
        ProjectileCostumeItem => 1,
        WideSpreadBomb2 => 1,
      },
      3 => {
        ProjectileCostumeItem => 1,
        HardBreakableBlock => 1,
        WideSpreadBomb2 => 2,
      },
    }
  end
end

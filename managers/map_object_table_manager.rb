module DigYukko
  module MapObjectTableManager
    def self.fetch(score)
      LEVEL_TO_ADDITIONAL_TABLE[LevelManager.calc_level(score)]
    end

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

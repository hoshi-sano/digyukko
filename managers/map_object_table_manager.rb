module DigYukko
  module MapObjectTableManager
    def self.fetch(score)
      LEVEL_TO_ADDITIONAL_TABLE[LevelManager.calc_level(score)]
    end

    LEVEL_TO_ADDITIONAL_TABLE = {
      1 => {},
      2 => {
        WideSpreadBomb1 => 4,
      },
      3 => {
        WideSpreadBomb1 => 8,
      },
      4 => {
        ProjectileCostumeItem => 1,
        WideSpreadBomb1 => 8,
        WideSpreadBomb2 => 1,
      },
      5 => {
        ProjectileCostumeItem => 1,
        HardBreakableBlock => 1,
        WideSpreadBomb1 => 6,
        WideSpreadBomb2 => 2,
      },
    }
  end
end

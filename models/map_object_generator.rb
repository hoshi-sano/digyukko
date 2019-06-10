module DigYukko
  class MapObjectGenerator
    def initialize(yukko)
      @yukko = yukko
    end

    # ItemBoxなどから利用するメソッド
    # TODO: yukkoの状態やスコア等を考慮しつつ、ややランダムにアイテムのクラスを返す
    def generate_item
      LifeRecoverItem
    end

    # 破壊可能なブロック、爆弾、アイテムのいずれかのクラスを返す
    # TODO: いい感じの確率で返すようにする
    def breakable_object_class
      val = random(100)
      if val > 98
        ProjectileCostumeItem
      elsif val > 95
        ItemBox
      elsif val > 93
        LifeRecoverItem
      elsif val > 85
        WideSpreadBomb
      else
        BreakableBlock
      end
    end

    private

    def random(max)
      ApplicationManager.random_number_generator.rand(0..max)
    end
  end
end

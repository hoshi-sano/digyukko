module DigYukko
  class MapObjectGenerator
    # ランダムマップ生成時の破壊可能オブジェクト排出率管理用クラス
    class BreakableObjectTable < Hash
      DEFAULT_SCORE = [
        [BreakableBlock,        80],
        [ProjectileCostumeItem, 2],
        [ItemBox,               2],
        [LowRecoverItem,        2],
        [FullRecoverItem,       0],
        [WideSpreadBomb1,       8],
        [WideSpreadBomb2,       0],
        [WideSpreadBomb3,       0],
        [HorizontalBomb1,       0],
        [HorizontalBomb2,       0],
        [HorizontalBomb3,       0],
        [VerticalBomb1,         0],
        [VerticalBomb2,         0],
        [VerticalBomb3,         0],
      ]

      def initialize
        super
        init_score
      end

      def []=(key, val)
        @max_score = nil
        super
        reset_stock
      end

      # オブジェクトの排出スコアを初期化する
      def init_score
        self.class::DEFAULT_SCORE.each { |obj, score| self[obj] = score }
      end

      def draw(val)
        @stock.find { |_, score| val <= score }[0]
      end

      def max_score
        @max_score ||= self.values.inject(&:+)
      end

      # 排出スコアを積算して通し番号にする
      def reset_stock
        @stock = {}
        obj_to_score_ary = self.dup.to_a
        prev = nil
        @stock = obj_to_score_ary.map { |obj, score|
          new_score = score + (prev || 0)
          prev = new_score
          [obj, new_score]
        }.to_h
      end
    end

    # アイテム排出率管理用クラス
    class ItemTable < BreakableObjectTable
      DEFAULT_SCORE = [
        [ProjectileCostumeItem, 2],
        [LowRecoverItem,        2],
        [FullRecoverItem,       0],
      ]
    end

    def initialize(yukko)
      @yukko = yukko
      @breakable_object_table = BreakableObjectTable.new
      @item_table = ItemTable.new
    end

    # ItemBoxなどから利用するメソッド
    # TODO: yukkoの状態やスコア等を考慮しつつ、ややランダムにアイテムのクラスを返す
    def generate_item
      @item_table.draw(random(@item_table.max_score))
    end

    # 破壊可能なブロック、爆弾、アイテムのいずれかのクラスを返す
    # TODO: マップ進行度やスコア等を考慮してマップ構成を変更する
    def breakable_object_class
      @breakable_object_table.draw(random(@breakable_object_table.max_score))
    end

    private

    def random(max)
      ApplicationManager.random_number_generator.rand(1..max)
    end
  end
end

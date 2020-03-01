module DigYukko
  class MapObjectGenerator
    attr_reader :breakable_object_table, :item_table

    # ランダムマップ生成時の破壊可能オブジェクト排出率管理用クラス
    class BreakableObjectTable < Hash
      DEFAULT_SCORE = [
        [BreakableBlock,        100],
        [HardBreakableBlock,    0],
        [ProjectileCostumeItem, 0],
        [BoundCostumeItem,      0],
        [DashCostumeItem,       10],
        [ItemBox,               2],
        [LowRecoverItem,        0],
        [FullRecoverItem,       0],
        [SmallScoreUpItem,      0],
        [MiddleScoreUpItem,     0],
        [LargeScoreUpItem,      0],
        [WideSpreadBomb1,       0],
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
        reset_stock
      end

      # オブジェクトの排出スコアを初期化する
      def init_score
        @max_score = nil
        self.class::DEFAULT_SCORE.each { |obj, score| self[obj] = score }
      end

      # 排出スコアを表現したハッシュを足し込む
      # スコア(数値)ではなくシンボルを指定していた場合はその内容に応じた操作を行う
      def add(hash)
        @max_score = nil
        hash.each do |key, value_or_operator|
          if value_or_operator.is_a?(Integer)
            calculate(key, :+, value_or_operator)
          else
            calculate(key, value_or_operator)
          end
        end
        reset_stock
      end

      # 排出スコアを一時的に足し込む
      # ブロック内でのみ足しこんだ結果のスコアが有効となる
      def temp_add(hash, &block)
        temp = self.dup

        add(hash)
        res = yield(self)

        self.clear
        add(temp)

        res
      end

      def calculate(key, operator, value = nil)
        case operator
        when :+
          if key?(key)
            self[key] += value
          else
            self[key] = value
          end
        when :zero
          self[key] = 0
        else
          raise "invalid operator: calculate(#{key}, #{operator}, #{value})"
        end
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
        [SmallScoreUpItem,      100],
        [MiddleScoreUpItem,     5],
        [LargeScoreUpItem,      1],
        [ProjectileCostumeItem, 1],
        [LowRecoverItem,        2],
        [FullRecoverItem,       0],
      ]
    end

    def initialize(yukko, score)
      @yukko = yukko
      @breakable_object_table = BreakableObjectTable.new
      reset_by_progress(score)
      @item_table = ItemTable.new
    end

    # ゲームの進行度に応じてオブジェクト排出テーブルを変更する
    # 進行しているほどハイリスク・ハイリターンな排出率となる
    def reset_by_progress(score)
      @breakable_object_table.init_score
      @breakable_object_table.add(MapObjectTableManager.fetch(score))
    end

    # ItemBoxなどから利用するメソッド
    # yukkoの状態を考慮しつつ、ややランダムにアイテムのクラスを返す
    def generate_item
      @item_table.temp_add(@yukko.current_item_table) do |table|
        table.draw(random(@item_table.max_score))
      end
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

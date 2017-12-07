module DigYukko
  # アイテムの基本クラス
  class Item < FieldObject
    def break
      @map.push_fragments(
        %i[upper_left upper_right lower_left lower_right].map do |pos|
          self.class::Fragment.new(self, pos)
        end
      )
      ActionManager.combo
      ActionManager.add_score(self)
      vanish
    end
  end
end

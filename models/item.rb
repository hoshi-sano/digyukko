module DigYukko
  # アイテムの基本クラス
  class Item < FieldObject
    def temporary_unbreakable(f = 14)
      @temp_unbreakable ||= f
    end

    def update
      return unless @temp_unbreakable
      @temp_unbreakable -= 1
      @temp_unbreakable = nil if @temp_unbreakable < 0
    end

    def break
      return if @temp_unbreakable
      @map.push_fragments(
        %i[upper_left upper_right lower_left lower_right].map do |pos|
          self.class::Fragment.new(self, pos)
        end
      )
      SE.play(:break)
      ActionManager.combo
      ActionManager.add_score(self)
      vanish
    end

    def force_break
      self.break
    end
  end
end

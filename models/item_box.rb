module DigYukko
  class ItemBox < BreakableBlock
    set_image load_image('item_box')
    set_score 100
    fragment(image)

    def break
      super
      item = @map.object_generator.generate_item.new(@map, @line_num, @block_num)
      # 出現と同時に破壊されるのを防ぐため数フレームほど破壊不可にする
      item.temporary_unbreakable
      @map.put_field_object(item)
    end
  end
end

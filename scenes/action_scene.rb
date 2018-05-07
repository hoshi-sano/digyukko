module DigYukko
  class ActionScene < BaseScene
    manager_module ActionManager

    # シーン切替時のフェードアウト処理
    # アクションシーンは同じシーンが連続するためフェードアウトしない
    # @return [Boolean] 次のシーンに遷移可能か否か
    def fade_out
      manager.update_components
      manager.draw_components
      true
    end

    # シーン切替時の前処理
    def pre_process
      super
      DigYukko.log(:debug, "call GC.disable")
      GC.disable
      BGM.play(:dungeon)
    end

    # シーン切替時の後処理
    def post_process
      super
      DigYukko.log(:debug, "call GC.enable")
      GC.enable
      GC.start
      DigYukko.log(:debug, "GC.count: #{GC.count}")
    end
  end
end

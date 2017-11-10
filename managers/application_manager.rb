module DigYukko
  # ゲームの挙動全体を統括するマネージャモジュール
  module ApplicationManager
    class << self
      def init
        @current_scene = ActionScene.new
      end

      def current_scene
        @current_scene
      end

      # 実行中繰り返し呼ばれるメソッド
      def play
        current_scene.play
      end

      # シーン切替時にコールするメソッド
      def change_scene(scene)
      end
    end
  end
end

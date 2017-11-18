module DigYukko
  # ゲームの挙動全体を統括するマネージャモジュール
  module ApplicationManager
    class << self
      def init
        KEY.init
        FontManager.load
        @current_scene = TitleScene.new
        @prev_scene = nil
      end

      def current_scene
        @current_scene
      end

      # 実行中繰り返し呼ばれるメソッド
      def play
        if scene_changing?
          finish = @prev_scene.fade_out
          complete_scene_change if finish
        else
          current_scene.play
        end
        DigYukko.close('Pushed ESC Key') if KEY.esc_down?
      end

      # シーン切替時にコールするメソッド
      def change_scene(scene)
        return if scene.class == @current_scene.class
        @current_scene.post_process
        @prev_scene = @current_scene
        @current_scene = scene
        DigYukko.log(:debug, 'changing scene started.')
      end

      # シーン切替処理を完了し次のシーンに完全移行する
      def complete_scene_change
        DigYukko.log(:debug,
                     "changing scene finished. " \
                     "from: #{@prev_scene.class}, to: #{@current_scene.class}")
        @current_scene.pre_process
        @prev_scene = nil
      end

      # シーン切替中か否か
      def scene_changing?
        !@prev_scene.nil?
      end
    end
  end
end

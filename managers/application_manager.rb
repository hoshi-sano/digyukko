module DigYukko
  # ゲームの挙動全体を統括するマネージャモジュール
  module ApplicationManager
    class << self
      def init
        KEY.init
        BGM.init
        SE.init
        FontManager.load
        init_random_number_generator
        @current_scene = StoryScene.new(:opening, TitleScene)
        @prev_scene = nil
      end

      def init_random_number_generator
        seed = Config['random_seed'] || ::Random.new_seed
        DigYukko.log(:debug, "use Random seed: #{seed}")
        @random_number_generator = ::Random.new(seed)
      end

      def random_number_generator
        @random_number_generator
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
        Ayame.update
        DigYukko.close('Pushed ESC Key') if KEY.esc_down?
      end

      # シーン切替時にコールするメソッド
      def change_scene(scene)
        return if scene_changing?
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

module DigYukko
  # 各シーンのベースとなるクラス
  class BaseScene
    # シーン切替用の暗幕
    BLACK_CURTAIN =
      ::DXRuby::Sprite.new(0, 0, ::DXRuby::Image.new(Config['window.width'],
                                                     Config['window.height'],
                                                     ::DXRuby::C_BLACK))

    class << self
      # このシーンで利用するManagerモジュールを指定するためのメソッド
      # Managerは以下のメソッドをコール可能であることが期待される
      #   * init: 初期化処理
      #   * update_components: 要素の毎フレーム毎の処理の実行用
      #   * draw_components: 要素の描画用
      #   * check_keys: 当該シーン特有のキー入力処理用
      def manager_module(mod)
        @manager_module = mod
      end

      def manager
        @manager_module
      end
    end

    def initialize(*args)
      DigYukko.log(:debug, 'initialized', self.class)
      manager.init(*args)
      BLACK_CURTAIN.alpha = 0
    end

    def manager
      self.class.manager
    end

    # シーン切替時の前処理
    def pre_process
      DigYukko.log(:debug, 'pre_process', self.class)
    end

    # シーン切替時の後処理
    def post_process
      DigYukko.log(:debug, 'post_process', self.class)
    end

    def play
      manager.update_components
      manager.draw_components
      manager.check_keys
    end

    # シーン切替時のフェードアウト処理
    # 入力のチェックを行わないことでフェードアウト中の操作を禁止している
    # @return [Boolean] 次のシーンに遷移可能か否か
    def fade_out
      manager.update_components
      manager.draw_components
      BLACK_CURTAIN.alpha += (BLACK_CURTAIN.alpha > 225) ? 1 : 10
      BLACK_CURTAIN.draw
      BLACK_CURTAIN.alpha >= 255
    end
  end
end

module DigYukko
  # 設定管理用のモジュール
  #
  # <APP_ROOT>/config/settings.ymlを読み込む
  # 利用時は Config['foo.bar.bazz'] のような形式でアクセスする
  # 設定に不備があった場合は DEFAULT_SETTINGS の内容を返す
  module Config
    require 'yaml'

    DEFAULT_SETTINGS = {
      log: {
        level:      :debug,
        shift_age:  3,
        shift_size: 1048576,
      },
      window: {
        width:  800,
        height: 480,
      },
    }

    class << self
      def [](string)
        res = nil
        begin
          res = string.split('.').inject(@settings) { |hash, key| hash[key.to_sym] }
        rescue NoMethodError => e
        end
        unless res
          DigYukko.log(:warn, "cannot read '#{string}' from settings.yml, use default", self)
          res = string.split('.').inject(DEFAULT_SETTINGS) { |hash, key| hash[key.to_sym] }
        end
        res
      end

      def load
        DigYukko.log(:debug, 'start load', self)
        @settings = load_settings
      end

      def load_settings
        YAML.load_file(File.join(config_path, 'settings.yml'))
      end

      def load_user_settings
        YAML.load_file(File.join(config_path, 'user_settings.yml'))
      end

      def config_path
        File.join(DigYukko.app_root, 'config')
      end

      def unloaded?
        !@settings
      end
    end
  end
end

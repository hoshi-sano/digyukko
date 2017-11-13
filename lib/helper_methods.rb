module DigYukko
  module HelperMethods
    IMAGE_DIR = File.join(DigYukko.app_root, 'data', 'images')

    def self.included(base)
      # 以下で定義するメソッドをインスタンスメソッドとしても
      # クラスメソッドとしても利用可能にする
      base.extend(self)
    end

    def find_file(dirs, name, exts)
      res = nil
      name_pattern = "#{name}.{#{exts.join(',')}}"
      Array(dirs).each do |dir|
        pattern = File.join(dir, name_pattern)
        res = Dir.glob(pattern).first
        break if res
      end
      res
    end

    # 画像配置用ディレクトリから指定した名前の画像ファイルを読み込む
    # @param [String] name ファイル名(拡張子除く)
    def load_image(name)
      path = find_file(IMAGE_DIR, name, %w(png jpg))
      ::DXRuby::Image.load(path)
    end

    # 画像配置用ディレクトリから指定した名前の画像ファイルを読み込み、
    # 指定した数で分割し配列で返す
    # @param [String] name ファイル名(拡張子除く)
    # @param [Integer] x_count X軸分割数
    # @param [Integer] y_count Y軸分割数
    def load_image_tiles(name, x_count, y_count)
      path = find_file(IMAGE_DIR, name, %w(png jpg))
      ::DXRuby::Image.load_tiles(path, x_count, y_count)
    end
  end
end

module DigYukko
  module HelperMethods
    require 'yaml'

    CUSTOM_IMAGE_DIR = File.join(DigYukko.app_root, 'customize', 'images')
    IMAGE_DIR = File.join(DigYukko.app_root, 'data', 'images')
    CUSTOM_MUSIC_DIR = File.join(DigYukko.app_root, 'customize', 'musics')
    MUSIC_DIR = File.join(DigYukko.app_root, 'data', 'musics')
    CUSTOM_SOUND_DIR = File.join(DigYukko.app_root, 'customize', 'sounds')
    SOUND_DIR = File.join(DigYukko.app_root, 'data', 'sounds')

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
      path = find_file([CUSTOM_IMAGE_DIR, IMAGE_DIR], name, %w(png jpg))
      ::DXRuby::Image.load(path)
    end

    # 画像配置用ディレクトリから指定した名前の画像ファイルを読み込み、
    # 指定した数で分割し配列で返す
    # @param [String] name ファイル名(拡張子除く)
    # @param [Integer] x_count X軸分割数
    # @param [Integer] y_count Y軸分割数
    def load_image_tiles(name, x_count, y_count)
      path = find_file([CUSTOM_IMAGE_DIR, IMAGE_DIR], name, %w(png jpg))
      ::DXRuby::Image.load_tiles(path, x_count, y_count)
    end

    # 指定したディレクトリ、名前のYAMLファイルを読み込む
    # @param [String] name ファイル名(拡張子除く)
    def load_yaml(dir, name)
      path = find_file(dir, name, %w(yml yaml))
      YAML.load_file(path)
    end

    # 引数で渡した画像データの最も暗い色をRGB配列で返す
    def deepest_color(img)
      res = [255, 255, 255]
      img.height.times do |y|
        img.width.times do |x|
          next if img[x, y][0] < 255 # 不透明色以外は無視
          rgb = img[x, y][1..-1]
          rgb_sum = rgb[1..-1].inject(:+)
          res = rgb if res.inject(:+) > rgb_sum
        end
      end
      res
    end

    # 引数で渡した画像データの平均色をRGB配列で返す
    def average_color(img)
      sum = [0, 0, 0]
      d = 0
      img.height.times do |y|
        img.width.times do |x|
          next if img[x, y][0] < 255 # 不透明色以外は無視
          rgb = img[x, y][1..-1]
          rgb.each_with_index { |val, idx| sum[idx] += val }
          d += 1
        end
      end
      sum.map { |v| v / d }
    end

    # デバッグモード以外の場合は透明となる色
    def debug_color(color = ::DXRuby::C_BLUE)
      return color if Config['debug']
      if color.size == 3
        rgb = color
      else
        rgb = color[1..-1]
      end
      [0] + rgb
    end
  end
end

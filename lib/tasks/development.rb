MD_BASE_URL = 'https://maoudamashii.jokersounds.com/music'
BGM_LIST = {
  title:   '/bgm/mp3/bgm_maoudamashii_8bit29.mp3',
  dungeon: '/bgm/mp3/bgm_maoudamashii_8bit28.mp3',
}
SE_LIST = {
  break:    '/se/wav/se_maoudamashii_retro22.wav',   # ブロック破壊音
  failed:   '/se/wav/se_maoudamashii_jingle02.wav',  # 失敗音
  fanfare:  '/se/wav/se_maoudamashii_jingle07.wav',  # ファンファーレ
  fatal:    '/se/wav/se_maoudamashii_magical06.wav', # 致命傷
  got_item: '/se/wav/se_maoudamashii_retro08.wav',   # アイテム取得音
  jump:     '/se/wav/se_maoudamashii_retro03.wav',   # ジャンプ
  ok:       '/se/wav/se_maoudamashii_retro16.wav',   # 決定音
  power_up: 'se/wav/se_maoudamashii_magical13.wav',  # パワーアップ音
  pre_bomb: '/se/wav/se_maoudamashii_retro24.wav',   # 爆発前兆音
  success:  '/se/wav/se_maoudamashii_jingle05.wav',  # クリア音
}


# dxruby.soファイルが配置されているディレクトリを返す
def dxruby_so_dir
  $LOAD_PATH.each do |path|
    dxruby_so_path = File.join(path, 'dxruby.so')
    return path if File.exists?(dxruby_so_path)
  end
  raise 'cannot find dxruby.so'
end

# 魔王魂さまよりBGM/SE用ファイルを取得し指定したディレクトリに配置する
def fetch_md_file(md_file_name, dist)
  return if File.exists?(dist)
  url = File.join(MD_BASE_URL, md_file_name)
  fetch_binary_file(url, dist)
end

def fetch_binary_file(url, dist)
  open(url) do |file|
    open(dist, 'wb') do |out|
      out.write(file.read)
      puts "got #{url}, and wrote #{dist}"
    end
  end
end

namespace :dev do
  desc 'ayame.soファイルをdxruby.soファイルと同じディレクトリに配置する'
  task :put_ayame_so, :ayame_so_path do |task, args|
    dir = dxruby_so_dir
    if File.exist?(File.join(dir, 'ayame.so'))
      puts "already exists: #{File.join(dir, 'ayame.so')}"
    else
      puts "copy #{args[:ayame_so_path]} to #{dir}"
      FileUtils.copy(args[:ayame_so_path], dir)
    end
  end

  desc '魔王魂さまよりBGMやSEなどの必要なファイルを取得する'
  task :fetch_md do
    require 'zip'
    require 'open-uri'
    require 'certified'
    [[BGM_LIST, File.join(ROOT, 'data', 'musics')],
     [SE_LIST,  File.join(ROOT, 'data', 'sounds')]].each do |list, dist_dir|
      list.each do |dist_file_name, md_file_name|
        ext = File.extname(md_file_name)
        dist = File.join(dist_dir, "#{dist_file_name}#{ext}")
        fetch_md_file(md_file_name, dist)
      end
    end
  end
end

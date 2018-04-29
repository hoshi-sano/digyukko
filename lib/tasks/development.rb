# dxruby.soファイルが配置されているディレクトリを返す
def dxruby_so_dir
  $LOAD_PATH.each do |path|
    dxruby_so_path = File.join(path, 'dxruby.so')
    return path if File.exists?(dxruby_so_path)
  end
  raise 'cannot find dxruby.so'
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
end

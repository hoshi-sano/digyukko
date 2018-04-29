module DigYukko
  module AutoLoader
    AUTO_LOAD_PATH = %w[lib models managers scenes]
    LOADED_FILES = %w[lib/auto_loader.rb lib/config.rb lib/dig_yukko.rb]
    EXCLUDES = LOADED_FILES + %w[lib/tasks/development.rb]

    class << self
      def run
        DigYukko.log(:debug, 'start auto load', self)
        DigYukko.log(:debug, 'search files', self)
        search_load_files
        DigYukko.log(:debug, 'try load', self)
        try_load
        DigYukko.log(:debug, 'finish auto load', self)
      end

      def try_load
        @loaded_files = []
        @prev_loaded_files = []
        DigYukko.log(:debug, "load_files.size: #{@load_files.size}", self)
        while @loaded_files.size != @load_files.size
          single_load
          if @prev_loaded_files.size == @loaded_files.size
            raise LoadError, connot_load_fiels_message
          else
            @prev_loaded_files = @loaded_files.dup
            DigYukko.log(:debug, "loaded_files.size: #{@loaded_files.size}", self)
          end
        end
      end

      def single_load
        @load_files.each do |file_path, loaded|
          next if loaded
          begin
            @load_files[file_path] = require(file_path) unless loaded
            @loaded_files << file_path
          rescue => e
            DigYukko.log(:debug, "#{e.message}", self)
            e.backtrace.each { |m| DigYukko.log(:debug, "#{m}", self) }
          end
        end
      end

      def connot_load_fiels_message
        connot_load_fiels = (@load_files.keys - @loaded_files).map { |s| "#{s}," }
        header_msg = "cannot load #{connot_load_fiels.size} files:"
        connot_load_fiels.unshift(header_msg).join("\n")
      end

      def search_load_files
        @load_files = {}
        AUTO_LOAD_PATH.each do |base_path|
          search_dir(File.join(DigYukko.app_root, base_path))
        end
      end

      def search_dir(dir)
        DigYukko.log(:debug, "search dir: #{dir}", self)
        Dir.glob(File.join(dir, '*')).each do |path|
          DigYukko.log(:debug, "find: #{path}", self)
          if File.directory?(path)
            search_dir(path)
          else
            next if EXCLUDES.any? { |f| path.match(/#{f}\z/) }
            @load_files[path] = false
          end
        end
      end
    end
  end
end

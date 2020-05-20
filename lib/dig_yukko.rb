module DigYukko
  require 'dxruby'
  require 'ayame'
  require 'logger'
  require 'lib/config'
  require 'lib/auto_loader'

  VERSION = '0.0.1'

  class << self
    def setup
      log(:debug, 'start setup')
      Config.load
      @logger = nil
      log(:info, 'start application')
      ::DXRuby::Window.caption = caption
      ::DXRuby::Window.width = Config['window.width']
      ::DXRuby::Window.height = Config['window.height']
      ::DXRuby::Window.fps = 60
      ::DXRuby::Window.frameskip = false
      AutoLoader.run
    end

    def caption
      [Config['title'], ' ver.', VERSION].join
    end

    def app_root
      File.join(File.dirname(__FILE__), '..')
    end

    def log(level, message, progname = self)
      logger.send(level, progname) { message }
    end

    def logger
      if Config.unloaded?
        @logger ||= ::Logger.new(STDOUT)
      else
        @logger ||=
          ::Logger.new(File.join(app_root, 'log', 'application.log'),
                       Config['log.shift_age'],
                       Config['log.shift_size']).tap do |logger|
          logger.level = Config['log.level']
        end
      end
    end

    def play
      setup
      ApplicationManager.init
      ::DXRuby::Window.loop do
        ApplicationManager.play
      end
    end

    def close(msg= '')
      log(:info, "close application: #{msg}")
      ::DXRuby::Window.close
    end
  end
end

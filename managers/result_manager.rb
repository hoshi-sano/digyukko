module DigYukko
  # リザルト画面管理用マネージャ
  module ResultManager
    include HelperMethods

    SCORE_FORMAT= '%010d'
    HEADER = 'RESULT'
    HEADER_X = 330
    HEADER_Y = 100
    LINE_IMAGE = ::DXRuby::Image.new(350, 4, ::DXRuby::C_WHITE)
    SHARE_MESSAGE_STR = 'PUSH SPACE KEY: Share on Twitter'
    CLEAR_TEXT = Config['share.clear_text'] || Config::DEFAULT_SETTINGS[:share][:clear_text]
    SHARE_TEXT_BASE = Config['share.share_text'] || Config::DEFAULT_SETTINGS[:share][:share_text]

    class << self
      def init(succeeded_or_failed)
        BGM.stop
        @count = 0
        @succeeded_or_failed = succeeded_or_failed
        result = ActionManager.result
        @score_strs = generate_score_strings(result)
        @depth = result[:depth]
        @share_message = @score_strs[-1]
        @share_message.visible = false unless Config['share.url']
        @yukko = result[:yukko]
        prepare_yukko
        @index = nil
        @se_played = false
      end

      def generate_score_strings(result)
        @total_score = SCORE_FORMAT % calc_total_score(result)
        common_score_width = FONT[:regular].get_width(@total_score)
        bonus_score_width = FONT[:regular].get_width(bonus_score_str(result))
        common_score_x = 550 - common_score_width
        bonus_score_x = 550 - bonus_score_width
        [
          ResultString.new(200, 140, 'LIFE'),
          ResultString.new(common_score_x, 140, SCORE_FORMAT % result[:yukko].life),
          ResultString.new(200, 170, 'DEPTH'),
          ResultString.new(common_score_x, 170, SCORE_FORMAT % result[:depth]),
          ResultString.new(200, 200, 'MAX COMBO'),
          ResultString.new(common_score_x, 200, SCORE_FORMAT % result[:combo]),
          ::DXRuby::Sprite.new(200, 243, LINE_IMAGE),
          ResultString.new(200, 260, 'BONUS'),
          ResultString.new(bonus_score_x, 260, bonus_score_str(result)),
          ResultString.new(200, 290, 'SCORE'),
          ResultString.new(common_score_x, 290, SCORE_FORMAT % result[:score]),
          ::DXRuby::Sprite.new(200, 333, LINE_IMAGE),
          ResultString.new(200, 350, 'TOTAL'),
          ResultString.new(common_score_x, 350, @total_score),
          ResultString.new(200, 400, SHARE_MESSAGE_STR),
        ]
      end

      def prepare_yukko
        @yukko.instance_variable_set(:@x_dir, Yukko::DIR[:left])
        @yukko.x = 580
        @yukko.y = 350
        @yukko.target = nil
        @yukko.update_image
      end

      def calc_total_score(result)
        calc_bonus_score(result) + result[:score]
      end

      def calc_bonus_score(result)
        ((result[:yukko].life * 0.01) + 1) * (result[:depth] / 100) * result[:combo]
      end

      def bonus_score_str(result)
        life_bonus = '%.2f' % ((result[:yukko].life * 0.01) + 1)
        "#{life_bonus} x #{result[:depth] / 100} x #{result[:combo]} +"
      end

      def update_components
        @count += 1
        if @count % 30 == 0
          update_index
          if @index == @score_strs.size && !@se_played
            SE.play(@succeeded_or_failed)
            @se_played = true
          end
        end
      end

      def update_index
        @index ||= -1
        if @index < @score_strs.size
          @index += 1
          SE.play(:break) unless @index >= @score_strs.size
        end
      end

      def draw_components
        ::DXRuby::Window.draw_font_ex(HEADER_X, HEADER_Y, HEADER, FONT[:regular])
        @yukko.draw
        return unless @index
        @score_strs[0..@index].each(&:draw)
      end

      def check_keys
        return unless @index
        return unless KEY.push?(KEY.attack) || KEY.push?(KEY.space)
        if @index >= @score_strs.size && se_finished?
          if KEY.push?(KEY.attack)
            go_to_title_scene
          elsif @share_message.visible
            share_on_twitter
          end
        else
          SE.play(:break) if @index < @score_strs.size
          @index = @score_strs.size
        end
      end

      def go_to_title_scene
        ApplicationManager.change_scene(TitleScene.new)
      end

      def se_finished?
        @se_played && SE.finished?(@succeeded_or_failed)
      end

      def share_on_twitter
        begin
          require "win32ole"
          require "uri"
          wsh = WIN32OLE.new("WScript.Shell")
          prog_id = wsh.RegRead("HKCU\\Software\\Microsoft\\Windows\\Shell\\Associations\\UrlAssociations\\https\\UserChoice\\ProgId")
          command_base = wsh.RegRead("HKEY_CLASSES_ROOT\\#{prog_id}\\shell\\open\\command\\")
          text = SHARE_TEXT_BASE.gsub(/depth|score/, {'depth' => @depth, 'score' => @total_score.to_i})
          text = CLEAR_TEXT + text if @succeeded_or_failed == :success
          hash = {
            text: text,
            url: Config['share.url'],
            hashtags: Config['share.hashtag'] || Config::DEFAULT_SETTINGS[:share][:hashtag] || 'digyukko',
          }
          params = URI.encode_www_form(hash)
          command = command_base.gsub("%1", "https://twitter.com/intent/tweet/?#{params}")
          Kernel.spawn(command)
          @share_message.visible = false
        rescue => e
          @share_message.str = Config['share.failed_message'] || Config::DEFAULT_SETTINGS[:share][:failed_message]
          DigYukko.log(:error, e.message)
          DigYukko.log(:debug, e.backtrace.join("\n"))
        end
      end
    end

    # DXRuby::Spriteクラスと同じような扱いで文字列を描画するためのクラス
    class ResultString
      attr_accessor :str, :visible

      def initialize(x, y, str, font = nil)
        @x = x
        @y = y
        @str = str
        @font = font || FONT[:regular]
        @visible = true
      end

      def draw
        return unless @visible
        ::DXRuby::Window.draw_font_ex(@x, @y, @str, @font)
      end
    end
  end
end

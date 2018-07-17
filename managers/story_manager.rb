module DigYukko
  module StoryManager
    include HelperMethods

    CUSTOM_STORY_DIR = File.join(DigYukko.app_root, 'customize', 'stories')
    STORY_DIR = File.join(DigYukko.app_root, 'data', 'stories')

    class << self
      def init(story_type, next_scene_class, next_scene_args = [])
        @slides = load_story(story_type)
        @slide_idx = 0
        @next_scene_class = next_scene_class
        @next_scene_args = next_scene_args
        @skip_message = SkipMessage.new
      end

      def update_components
        @slides[@slide_idx].update
        if @slides[@slide_idx].finished?
          if @slides[@slide_idx + 1]
            @slide_idx += 1
          else
            unless ApplicationManager.scene_changing?
              ApplicationManager.change_scene(@next_scene_class.new(*@next_scene_args))
            end
          end
        end
        @skip_message.update
      end

      def draw_components
        @slides[@slide_idx].draw
        @skip_message.draw if @slides[@slide_idx].skip?
      end

      def check_keys
        return if ApplicationManager.scene_changing?
        if KEY.pushed_keys.any? && @slides[@slide_idx].skip?
          ApplicationManager.change_scene(@next_scene_class.new(*@next_scene_args))
        end
      end

      def load_story(story_type)
        prev_info = {}
        load_yaml([CUSTOM_STORY_DIR, STORY_DIR], story_type).map do |slide_info|
          slide = Slide.new(slide_info, prev_info)
          prev_info = slide.info
          slide
        end
      end
    end

    class Slide
      include HelperMethods

      ALPHA_MIN = 0
      ALPHA_MAX = 255

      class Event
        attr_reader :message

        def initialize(info)
          @message = info[:message]
          @procs = []

          if info[:bgm_start]
            bgm_name = info[:bgm_start]
            BGM.add(bgm_name)
            @procs << Proc.new { BGM.play(bgm_name) }
          end
          @procs << Proc.new { BGM.stop } if info[:bgm_stop]

          if info[:sound_effect]
            se_name = info[:sound_effect]
            SE.add(se_name)
            @procs << Proc.new { SE.play(se_name) }
          end
        end

        def exec_actions
          @procs.each(&:call)
        end
      end

      # 以下指定可能な値の一覧。
      # image_file_name以外は指定しない場合は前のスライドの値を継続する。
      # カッコ内はデフォルト値。(最初のスライドで指定しなかった場合に利用される)
      #
      #   * image_file_name: スライド画像のファイル名 (なし)
      #   * skip: ボタン押下によるスキップを許容するか否か (nil)
      #   * fade_in: スライド表示開始時にフェードインするか否か (nil)
      #   * fade_out: スライド表示終了時にフェードインするか否か (nil)
      #   * alpha_diff: フェードイン・フェードアウトする際の速さ(3)
      #   * image_x: スライド画像の表示位置のx座標 (画像が中央にくるx座標)
      #   * image_y: スライド画像の表示位置のy座標 (画像が中央にくるy座標)
      #   * message_x: 文章の表示位置のx座標 (画像のx座標)
      #   * message_y: 文章の表示位置のy座標 (画像の下端+20pixel)
      #   * message_speed: 文章の表示速度 (5)
      #   * keep_duration: 表示し終えたスライドの表示継続時間 (message_speed * 30)
      #
      def initialize(info, prev_info = {})
        if info[:image_file_name]
          @image = load_image(info[:image_file_name])
        else
          @image = ::DXRuby::Image.new(1, 1)
        end
        @events = Array(info[:events]).map { |event_info| Event.new(event_info)  }
        @event_idx = 0
        @skip = info.key?(:skip) ? info[:skip] : prev_info[:skip]
        @fade_in = info.key?(:fade_in) ? info[:fade_in] : prev_info[:fade_in]
        @fade_out = info.key?(:fade_out) ? info[:fade_out] : prev_info[:fade_out]
        @state = @fade_in ? :fade_in : :appeared
        @alpha = @fade_in ? ALPHA_MIN : ALPHA_MAX
        @alpha_diff = info[:alpha_diff]  || prev_info[:alpha_diff] || 3
        @r_target = ::DXRuby::RenderTarget
                    .new(Config['window.width'],
                         Config['window.height'])
        @image_x = info[:image_x] || prev_info[:image_x] || @r_target.width / 2 - @image.width / 2
        @image_y = info[:image_y] || prev_info[:image_y] || @r_target.height / 2 - @image.height / 2
        @message_x = info[:message_x] || prev_info[:message_x] || @image_x
        @message_y = info[:message_y] || prev_info[:message_y] || @image_y + @image.height + 20
        @message_speed = info[:message_speed] || prev_info[:message_speed] || 5
        @keep_duration = info[:keep_duration] || prev_info[:keep_duration] || @message_speed * 30
        @display_message = ''
        @display_message_counter = 0
        @keep_counter = 0
      end

      def info
        {
          skip:          @skip,
          fade_in:       @fade_in,
          fade_out:      @fade_out,
          alpha_diff:    @alpha_diff,
          image_x:       @image_x,
          image_y:       @image_y,
          message_x:     @message_x,
          message_y:     @message_y,
          message_speed: @message_speed,
          keep_duration: @keep_duration,
        }
      end

      def skip?
        @skip
      end

      def hidden?
        @alpha <= ALPHA_MIN
      end

      def showed?
        @alpha >= ALPHA_MAX
      end

      def finished?
        @state == :finished
      end

      def current_event
        @events[@event_idx]
      end

      def current_message
        return nil if current_event.nil?
        current_event.message
      end

      def update
        case @state
        when :fade_in
          @alpha += @alpha_diff
          if showed?
            @alpha = ALPHA_MAX
            @state = :appeared
          end
        when :fade_out
          @alpha -= @alpha_diff
          if hidden?
            @alpha = ALPHA_MIN
            @state = :finished
          end
        when :appeared
          @state = current_event ? :exec_event : :keep
        when :exec_event
          # 最初の1回だけEvent#exec_actionsを呼ぶ
          current_event.exec_actions if current_event && @display_message_counter.zero?
          # 表示するメッセージが無かったり、メッセージを表示しきった場合は
          # keep状態に移行する
          if !current_message || !current_message[@display_message.length]
            @state = :keep
            @keep_counter = 0
            return
          end
          # 表示する文言を徐々に増やしてメッセージ送りを表現する
          if (@display_message_counter % @message_speed).zero?
            @display_message.concat(current_message[@display_message.length])
          end
          @display_message_counter += 1
        when :keep
          # @keep_durationに負の数を指定した場合は
          # キー押下によるskipが行われるまでスライドを表示し続ける
          return if @keep_duration < 0
          # 画像やメッセージを表示しきった状態で、一定時間表示したのちに
          # 次のスライドへ遷移する
          @keep_counter += 1
          if (@keep_counter % @keep_duration).zero?
            @display_message = ''
            @display_message_counter = 0
            @event_idx += 1
            if current_event
              @state = :exec_event
            else
              @event_idx = 0
              @state = @fade_out ? :fade_out : :finished
            end
          end
        end
      end

      def draw
        @r_target.draw(@image_x, @image_y, @image)
        @r_target.draw_font(@message_x, @message_y, @display_message, FONT[:regular])
        ::DXRuby::Window.draw_ex(0, 0, @r_target, alpha: @alpha)
      end
    end

    class SkipMessage
      MESSAGE = 'PUSH ANY BUTTON'
      TOGGLE_INTERVAL = 45

      def initialize
        @show = true
        @counter = 0
        @font = FONT[:small]
        @x = (Config['window.width'] / 2) - (@font.get_width(MESSAGE) / 2)
      end

      def update
        @counter += 1
        if (@counter % TOGGLE_INTERVAL).zero?
          @show = !@show
          @counter = 0
        end
      end

      def draw
        ::DXRuby::Window.draw_font(@x, 0, MESSAGE, @font) if @show
      end
    end
  end
end

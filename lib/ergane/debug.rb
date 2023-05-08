module Ergane
  module Debug

    class << self

      @nl = false

      def enable_break!
        class << self
          define_method(:break, &binding.method(:pry))
        end
      end

      def suppress
        original_stdout, original_stderr = $stdout.clone, $stderr.clone
        $stderr.reopen File.new('/dev/null', 'w')
        $stdout.reopen File.new('/dev/null', 'w')
        yield
      ensure
        $stdout.reopen original_stdout
        $stderr.reopen original_stderr
      end

      def break
        puts "Breakpoints Not Enabled"
      end

      def format_print(m)
        case m
        when String
          format_print(m.split("\n"))
        when Array
          m.join("\n\t")
        else
          m
        end
      end

      def puts(m=nil, prefix: false, &block)
        prefix ||= $debug ? 'DEBUG' : false
        if (prefix)
          if @nl || m.blank?
            $stdout.puts format_print(m)
          else
            $stdout.print "[#{prefix.upcase.light_magenta}] " unless prefix.blank?
            $stdout.puts format_print(m)
          end
        else
          yield if block_given?
        end
        @nl = false
      end

      def print(m=nil, prefix: false, &block)
        @nl = true
        prefix ||= $debug ? 'DEBUG' : false
        if (prefix)
          if (m.blank?)
            $stdout.print format_print(m)
          else
            $stdout.print "[#{prefix.upcase.light_magenta}] " unless prefix.blank?
            $stdout.print format_print(m)
          end
        else
          yield if block_given?
        end
      end

    end

    enable_break! if $debug

  end

end

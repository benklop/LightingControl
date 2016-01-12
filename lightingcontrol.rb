require 'faderuby'

module LightingControl
  class Controller
    def initialize(host, port, length=36)
      @client = FadeRuby::Client.new(host, port)
      @strip = FadeRuby::Strip.new(length)

      start
    end

    def start
      @running = true
      Thread.new do
        while @running
          @client.write(@strip)
          sleep 5 #write a minimum of every 5 seconds
        end
      end
    end

    def stop
      off
      @running = false
    end

    def update
      yield @strip
      @client.write @strip
    end

    def update_each_pix
      @strip.pixels.each do |pix|
        yield pix
        @client.write @strip
      end
    end

    def colorwheel
      next_color = [rand(255), rand(255), rand(255)]
      update_each_pix do |pix|
        pix.set(r: next_color[0], g: next_color[1], b: next_color[2])
        sleep 0.1
      end
    end

    def colorall
      update_each_pix do |pix|
        next_color = [rand(255), rand(255), rand(255)]
        pix.set(r: next_color[0], g: next_color[1], b: next_color[2])
      end
    end

    def off
      @strip.set_all(r: 0, g: 0, b: 0)
    end
  end
end


#
# Quadrature encoder reading class for the control panel knob.
# designed to notify observers of:
#
# :up
# :down
# :short_press
# :double_press
# :long_press
#
# These should be sufficient actions for most purposes.
#

require 'pi_piper'
require 'observer'
require 'timeout'

module LightingControl
  module Panel
    class QuadratureEncoder
      include PiPiper
      include Observable

      def initialize(pin_sw_a, pin_sw_b, pin_btn, pullup = false)
        @btn = PiPiper::Pin.new(:pin => pin_btn, :direction => :in, :pull => pullup ? :up : :down)
        @sw_a = PiPiper::Pin.new(:pin => pin_sw_a, :direction => :in, :pull => pullup ? :up : :down)
        @sw_b = PiPiper::Pin.new(:pin => pin_sw_b, :direction => :in, :pull => pullup ? :up : :down)
    
        watch @btn do
          @btn.read
          if @btn.on?
            #pressed
            changed
            press = :none
            begin
              Timeout::timeout(1) do
                @btn.wait_for_change
                #held for less than second
                begin
                  Timeout::timeout(0.2) do
                    @btn.wait_for_change
                    #pressed again before .2 seconds
                    press = :double_press
                  end
                rescue Timeout::Error
                  #short pressed once
                  press = :short_press
                end
              end
            rescue Timeout::Error
              #held more than 1 second
              press = :long_press
            end
            notify_observers(:double_press)
            yield press
          end
        end

        watch @sw_a do
          @sw_a.read
          if @sw_a.on?
            changed
            if @sw_b.on?
              notify_observers(:up)
            else
              notify_observers(:down)
            end
          end
        end

        watch @sw_b do
          @sw_b.read
        end
      end
    end
  end
end

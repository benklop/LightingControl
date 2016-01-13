
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
# This should be sufficient for most purposes.
#

# the Control Panel board is connected via a 10 pin header. the connections are as follows on either end:
# pin :   Pi pin   :     Controller connection    : Notes
# 1   : 3.3 volts
# 2   : 5 volts
# 3   : GPIO 18    : PWM for WS2812 LED control   : with 3.3 => 5v converter
# 4   : GPIO 21    : Int for TSL2571FN Lux Sensor : interrupt pin to signal data available
# 5   : GPIO 22    : Quadrature encoder button    : pullup high, switch shorts to ground
# 6   : GPIO 0     : I2C 0 SDA                    : I2C data line for display and lux sensor
# 7   : GPIO 23    : Quadrature encoder A switch  : pullup high, rotation shorts to ground
# 8   : GPIO 1     : I2C 0 SCL                    : I2C clock line for display and lux sensor
# 9   : GPIO 24    : Quadrature encoder B switch  : pullup high, rotation shorts to ground
# 10  : Ground
#
require 'pi_piper'
require 'observer'
require 'timeout'

module LightingControl
  module Panel
    class QuadratureEncoder
      include PiPiper
      include Observable

      def initialize(pin_sw_a, pin_sw_b, pin_btn)
        @btn = PiPiper::Pin.new(:pin => 22, :direction => :in, :pull => :up)
        @sw_a = PiPiper::Pin.new(:pin => 23, :direction => :in, :pull => :up)
        @sw_b = PiPiper::Pin.new(:pin => 24, :direction => :in, :pull => :up)
    
        watch @btn do
          @btn.read
          if @btn.on?
            #pressed
            changed
            begin
              Timeout::timeout(1) do
                @btn.wait_for_change
                #held for less than second
                begin
                  Timeout::timeout(0.2) do
                    @btn.wait_for_change
                    #pressed again before .2 seconds
                    notify_observers(:double_press)
                  end
                rescue Timeout::Error
                  #short pressed once
                  notify_observers(:short_press)
                end
              end
            rescue Timeout::Error
              #held more than 1 second
              notify_observers(:long_press)
            end
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

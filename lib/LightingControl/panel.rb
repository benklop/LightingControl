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
require 'Panel/quadrature_encoder'

module LightingControl
  class Panel
    attr_accessor :knob

    def initialize
      @knob = QuadratureEncoder.new(22,23,24)
    end
  end
end

require 'pry'
require 'ftdi'

ctx = Ftdi::Context.new
handle = ctx.usb_open(0x0403, 0xfaf0)
ctx.baudrate = 115200
ctx.set_line_property(:bits_8, :stop_bit_1, :none)
sleep 0.001
ctx.flowctrl = Ftdi::SIO_RTS_CTS_HS

binding.pry
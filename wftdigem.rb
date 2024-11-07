require 'pry'
require 'ftdi'

def jog(context, steps)
  raise "Steps should be an integer, pos or neg." unless steps.is_a? Integer

  steps = 2000 if steps.abs > 2000 # Chop
  # Set step sizes
  command_head = "\xC0\x08"
  command_length = [22].pack "S"

  sub_msg_id = "\x2D\x00"
  channel = "\x01\x00"
  jog_mode = "\x02\x00"
  forward_size = [steps.abs].pack "L"
  reverse_size = [steps.abs].pack "L"
  rate = [2000].pack "L"
  accel = [50000].pack "L"

  command = command_head + command_length + "\xD0\x01"
  command.force_encoding Encoding::ASCII_8BIT
  command += sub_msg_id + channel + jog_mode + forward_size + reverse_size + rate + accel
  context.write_data command
  puts context.read_data
  puts "Step size set"

  command = "\xD9\x08"
  command += (steps > 0) ? "\x01\x01" : "\x01\x02"
  command += "\x50\x01"
  puts "Now rotate"
  context.write_data command
  puts context.read_data
end

def zero(context)
  command = "\xC0\x08\x0C\x00\xD0\x01".force_encoding Encoding::ASCII_8BIT
  command += "\x05\x00\x01\x00" + ("\0"*8)
  context.write_data command
  puts context.read_data
end

ctx = Ftdi::Context.new
handle = ctx.usb_open(0x0403, 0xfaf0)
ctx.baudrate = 115200
ctx.set_line_property(:bits_8, :stop_bit_1, :none)
sleep 0.001
ctx.flowctrl = Ftdi::SIO_RTS_CTS_HS

jog = "\xD9\x08\x01\x01\x50\x01"
stat = "\xe0\x08\x00\x00\x50\x01"

binding.pry

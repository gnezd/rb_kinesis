require 'libusb'
require 'pry'

def stat(handle)
  stat = "\xe0\x08\x00\x00\x50\x01"
  while message = handle.bulk_transfer(endpoint: 0x81, dataIn:512, timeout:500)
    if message == "\x11\x60"
    else
      puts message.unpack "H*"
      break
    end
  end
end

context = LIBUSB::Context.new
puts "Devices: \n"
context.devices.each do |device| 
  puts "  #{device.bus_number}-#{device.device_address}: #{device.product}"
end
found_device = nil
while !found_device
  puts "Pick one?"
  match = gets.match(/(\d+)\-(\d+)/)
  found_device = (context.devices.filter {|x| (x.bus_number==match[1].to_i) && (x.device_address==match[2].to_i)})[0] if match
end
handle = found_device.open
timeout = 500
# Set baud rate
puts "Setting baud. Expect zero?"
puts handle.control_transfer(bmRequestType: 0x40, bRequest: 0x03, wValue: 0x1a, wIndex: 0x00, timeout: timeout)

# Set data characteristics
puts "Setting data charateristics. Expect zero?"
puts handle.control_transfer(bmRequestType: 0x40, bRequest: 0x04, wValue: 0x08, wIndex: 0x00, timeout: timeout)
sleep 50E-6

# Set flow control
puts handle.control_transfer(bmRequestType: 0x40, bRequest: 0x02, wValue: 0x00, wIndex: 0x0100, timeout: timeout)

# Set Modem control
puts handle.control_transfer(bmRequestType: 0x40, bRequest: 0x01, wValue: 0x0202, wIndex: 0x00, timeout: timeout)

# Reset
puts handle.control_transfer(bmRequestType: 0x40, bRequest: 0x00, wValue: 0x00, wIndex: 0x00, timeout: timeout)

sleep 50E-6

# Purge
puts "Now purge"
# Flushes
puts handle.control_transfer(bmRequestType: 0x40, bRequest: 0x00, wValue: 0x02, wIndex: 0x00, timeout: timeout)
puts handle.control_transfer(bmRequestType: 0x40, bRequest: 0x00, wValue: 0x01, wIndex: 0x00, timeout: timeout)

sleep 50E-6
jog = "\xD9\x08\x01\x01\x50\x01"
puts handle.bulk_transfer(endpoint: 0x02, dataOut: jog, timeout: 500)
stat = "\xe0\x08\x00\x00\x50\x01"
puts handle.bulk_transfer(endpoint: 0x02, dataOut: stat, timeout: 500)

10.times {stat(handle); sleep 5E-5}

binding.pry
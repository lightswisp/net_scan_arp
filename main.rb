#!/usr/bin/ruby

#				TODO				#
#									#
# HW ADDR MANUFACTURE RESOLUTION 	#
#									#
#				TODO				#
require "socket"
require "ipaddr"

class String
def black;          "\e[30m#{self}\e[0m" end
def red;            "\e[31m#{self}\e[0m" end
def green;          "\e[32m#{self}\e[0m" end
def brown;          "\e[33m#{self}\e[0m" end
def blue;           "\e[34m#{self}\e[0m" end
def magenta;        "\e[35m#{self}\e[0m" end
def cyan;           "\e[36m#{self}\e[0m" end
def gray;           "\e[37m#{self}\e[0m" end

def bg_black;       "\e[40m#{self}\e[0m" end
def bg_red;         "\e[41m#{self}\e[0m" end
def bg_green;       "\e[42m#{self}\e[0m" end
def bg_brown;       "\e[43m#{self}\e[0m" end
def bg_blue;        "\e[44m#{self}\e[0m" end
def bg_magenta;     "\e[45m#{self}\e[0m" end
def bg_cyan;        "\e[46m#{self}\e[0m" end
def bg_gray;        "\e[47m#{self}\e[0m" end

def bold;           "\e[1m#{self}\e[22m" end
def italic;         "\e[3m#{self}\e[23m" end
def underline;      "\e[4m#{self}\e[24m" end
def blink;          "\e[5m#{self}\e[25m" end
def reverse_color;  "\e[7m#{self}\e[27m" end
end

def main()
	
	interfaces = Socket.getifaddrs
	interfaces.reject!{|i| !i.addr.ipv4?}.reject!{|i| i.addr.ipv4_loopback?}.each.with_index do |i, j|
		p "#{i.name} -> #{j}"
	end
	puts "Select an interface to use: "
	interface_index = gets.chomp.to_i
	interface_name  = interfaces[interface_index].name
	ip_range = IPAddr.new("#{interfaces[interface_index].addr.ip_address}/#{interfaces[interface_index].netmask.ip_address}").to_range.to_a
	threads = []
	alive_addr_list = []

	ip_range.length.times do |i|
		next if i == 255 # skip the broadcast address
		threads << Thread.new(ip_range[i]){ |ip|
			command = `arping -I wlp2s0 -c 1 #{ip.to_s}`
			#if(system("arping -I wlp2s0 -c 1 #{ip.to_s} > /dev/null") == true)
			if($?.exitstatus == 0)
				alive_addr_list.append(ip.to_s)
				puts "#{command.match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s\[.*\]/).to_s} is alive!".green

			elsif ARGV[0] == "-D"
				puts "#{ip.to_s} seems to be dead!".red
			end
		}
	end
	threads.each{|th| th.join}
	puts "#{alive_addr_list.length} devices are alive".bold
end

main()

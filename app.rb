#!/usr/bin/env ruby

require 'socket'
require './db.rb'


port = 8080
puts "starting server on port #{port}"

server = TCPServer.new port # Server bind to port 2000
client_die = false
loop do
  # client = server.accept    # Wait for a client to connect
  
	Thread.start(server.accept) do |client|
		loop do
			request_type = client.gets( "\n" ).chomp( "\n" )
			puts "request:" + request_type + ";"
			if(request_type.match(/GET/i))
				puts "ok here you are\n"
				client.puts "ok here you are\n"
				# 	Coords.where(:sent => false).each do |to_send|
				# 		puts to_send
				# 		client.puts to_send
				# 		to_send.sent = true
				# 		to_send.save	
				# 	end
			end
			if(request_type.match(/PUT/i))
				puts "give me something\n"
				client.puts "ok here you are\n"
			end
			if(request_type.match(/BYE/i))
				puts "bye bye closing connection\n"
				client.puts "bye bye closing connection\n"
				client.close
			end
		end

	end
  
end

db.close


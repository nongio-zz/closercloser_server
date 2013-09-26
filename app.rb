#!/usr/bin/env ruby

require 'socket'
require './db.rb'
require 'timeout'

port = 8080
puts "starting server on port #{port}"

server = TCPServer.new port # Server bind to port 2000

def receiver(from, client)
	puts "setting up new reciver from: #{from}"
	while ! client.closed?
			begin 
				Timeout::timeout(5) do
					coords = client.gets( "\n" )
					if ! coords.nil?
						coords = coords.chomp( "\n" )
					else
						close client
						return
					end
					
					coords = coords.split(",")
					if coords.size > 0 && !coords[4].nil?
						
						date_parts = coords[4].split(":")
						ms = date_parts.pop
						date_string = date_parts.join(":")
						t = DateTime.strptime(date_string, "%Y-%m-%d %H:%M:%S") 
							Coords.transaction do 
								c = Coords.create(:from => from[-2,2], :n => coords[1], :x => coords[2], :y => coords[3], :time => t, :ms => ms, :sent => false)
								c.save
							end
						
					end
				end
			rescue Timeout::Error
				puts "Timed out!"
				break
			end
	end
	
end
def close (client)
	client.close
	ActiveRecord::Base.connection.close
	puts "fine while"
end
def sender(of, client)
	while (! client.closed?)
			coords = []
			Coords.transaction do 
				coords = Coords.where(:from => of, :sent => false).order("time ASC")
			end
			while(coords.size >= 1)
					Coords.transaction do 
						c = coords.pop
						begin
							client.puts "#{c.n},#{c.x},#{c.y},#{c.time.strftime("%Y-%m-%d %H:%M:%S")},#{sprintf '%03d', c.ms}\n"
							c.sent = true
							c.save
						rescue
							close client
							break
						end
					end
			end
	end
end

loop do
  # client = server.accept    # Wait for a client to connect
  	puts "loop"
  	Thread.abort_on_exception = true
	Thread.start(server.accept) do |client|
			client.sync = true
			request_type = client.gets( "\n" ).chomp( "\n" )
			puts "request:" + request_type + ";"
			if(request_type.match(/GET/i))
				puts "ok here you are\n"
				sender "FI", client
			end
			if(request_type.match(/PUT/i))
				puts "give me something\n"
				receiver "FI", client
			end
	end
  
end

db.close


#!/usr/bin/env ruby

require 'socket'
require './db.rb'
require 'timeout'

port = 3339
puts "starting server on port #{port}"

server = TCPServer.new port # Server bind to port 2000
checker_client = nil
def receiver(from, client)
	puts "setting up new reciver from: #{from}"
	while ! client.closed?
			begin 
				#Timeout::timeout(5) do
					coords = client.gets( "\n" )
					if ! coords.nil?
						coords = coords.chomp( "\n" )
					else
						close client
						return
					end
					
					coords = coords.split(",")
					#puts coords.inspect
					if coords.size > 0 && !coords[5].nil?
						date_parts = coords[5].split(":")
						ms = date_parts.pop
						date_string = date_parts.join(":")
						t = DateTime.strptime(date_string, "%Y-%m-%d %H:%M:%S") 
							Coords.transaction do 
								c = Coords.create(:from => from[-2,2], :n => coords[1], :x => coords[2], :y => coords[3], :value => coords[4], :time => t, :ms => ms, :sent => false, :check => false)
								c.save
								#puts c.inspect
							end
						
					end
				#end
                sleep(0.2)
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
			while(coords.size > 0)
					Coords.transaction do 
						c = coords.pop
						begin
							client.puts "#{c.n},#{c.x},#{c.y},#{c.value},#{c.time.strftime("%Y-%m-%d %H:%M:%S")},#{sprintf '%03d', c.ms}\n"
							c.sent = true
							c.save
						rescue
							close client
							break
						end
					end
			end
            sleep(0.2)
	end
end
def sender_check(client)
    checker_client = client
	while (! checker_client.closed?)
			coords = []
			Coords.transaction do
				coords = Coords.where(:check => false).order("time ASC")
			end
			while(coords.size > 0)
					Coords.transaction do 
						c = coords.pop
						begin
							checker_client.puts "#{c.from},#{c.n},#{c.x},#{c.y},#{c.value},#{c.time.strftime("%Y-%m-%d %H:%M:%S")},#{sprintf '%03d', c.ms}\n"
							c.check = true
                            c.save
						rescue
							close checker_client
							break
						end
					end
			end
            sleep(4)
            puts "check"
	end
end
def sender_check_web(client)
	while (! client.closed?)
			coords = []
			Coords.transaction do
				coords = Coords.where(:check => false).order("time ASC")
			end
			while(coords.size > 0)
					Coords.transaction do 
						c = coords.pop
						begin
							client.puts "#{c.from},#{c.n},#{c.x},#{c.y},#{c.value},#{c.time.strftime("%Y-%m-%d %H:%M:%S")},#{sprintf '%03d', c.ms}\n"
						rescue
							close client
							break
						end
					end
			end
            sleep(1)
	end
end
class Thread
      attr_accessor :checker
end
loop do
  # client = server.accept    # Wait for a client to connect
  	puts "loop"
  	Thread.abort_on_exception = true
	t = Thread.start(server.accept) do |client|
			client.sync = true
			request_type = client.gets( "\n" )
            request_type = request_type.nil? ? "" : request_type
            Thread.current.checker = false
            if(request_type)
                request_type = request_type.chomp( "\n" )
            end
			puts "request:" + request_type + ";"
			if(request_type.match(/GET/i))
				parts = request_type.split ":"
				puts "ok here you are #{parts[1]} \n"
				sender parts[1], client
			end
			if(request_type.match(/PUT/i))
				parts = request_type.split ":"
				puts "give me something #{parts[1]}\n"
				receiver parts[1], client
			end
            if(request_type.match(/WEB/i))
                parts = request_type.split ":"
                sender_check_web client
            end
			if(request_type.match(/CHECK/i))
				parts = request_type.split ":"
                checker_client = client
                Thread.list.each {|t| 
                    if(t.checker)
                        t.exit
                    end
                }
                Thread.current.checker = true
                sender_check client
			end
    end
end

db.close

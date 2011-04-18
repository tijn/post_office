require 'socket'
require 'thread'

# This class starts a generic server, accepting connections
# on options[:port]
#
# When extending this class make sure you:
#
# * def greet(client)
# * def process(client, command, full_data)
# * client.close when you're done
#
# You can respond to the client using:
#
# * respond(client, text)
#
# The command given to process equals the first word
# of full_data in upcase, e.g. QUIT or LIST
#
# It's possible for multiple clients to connect at the same
# time, so use client.object_id when storing local data

class GenericServer
  
  def initialize(options)
    @port = options[:port]
    server = TCPServer.open(@port)
    puts "#{self.class.to_s} listening on port #{@port}"
    
    # Accept connections until infinity and beyond
    loop do
      Thread.start(server.accept) do |client|
        begin
          greet client

          # Keep processing commands until somebody closed the connection
          begin
            input = client.gets

            # The first word of a line should contain the command
            command = input.to_s.gsub(/ .*/,"").upcase.gsub(/[\r\n]/,"")

            puts "#{client.object_id}:#{@port} < #{input}"

            process(client, command, input)
          end until client.closed?
        rescue => detail
          puts "#{client.object_id}:#{@port} ! #{$!}"
          client.close
        end
      end
    end
  end
  
  # Respond to client by sending back text
  def respond(client, text)
    puts "#{client.object_id}:#{@port} > #{text}"
    client.puts text
  rescue
    puts "#{client.object_id}:#{@port} ! #{$!}"
    client.close
  end
  
end
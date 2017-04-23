require "socket"
require "process"
Signal::INT.trap { puts "exiting gracefully!"; exit 0 }


def handle_connection(con : TCPSocket)
  if con
    until con.closed?
      tmp = con.gets
      if tmp
        dir = "/"
        env = {shell: true}
        args = tmp.split(' ')
        if args.size >= 1
          command = args.shift
          if command == "exit"
            break
          end
          begin
          Process.run(command,  # command name
                      args,     # args
                      nil,      # environment
                      false,    # clear env
                      false,    # shell false - we are the shell
                      con,      # input
                      con,      # output
                      con,      # stderr
                      dir
                      )
          rescue
          end
        end
      end
    end
    con.close
  end
end

server = TCPServer.new(8721)
loop do
  if socket = server.accept
    spawn handle_connection(socket)
  else
    break
  end
end

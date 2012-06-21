module MCollective
    module Agent
      class Jigsaw<RPC::Agent
        metadata :name        => "Jigsaw munin-collector agent",
                 :description => "Agent for collecting munin metrics and configand storing to tsdb and mongo",
                 :author      => "Ørjan Ommundsen <orjan@redpill-linpro.com>",
                 :license     => "Apache v.2",
                 :version     => "1.0",
                 :url         => "",
                 :timeout     => 2

        action "echo" do
          validate :msg, String

          reply[:msg] = request[:msg]
          reply[:time] = Time.now.to_s
        end
      end
    end
end

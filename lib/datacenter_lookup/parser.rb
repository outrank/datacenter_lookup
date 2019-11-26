require "ipaddr"
require "csv"

module DatacenterLookup
  class Parser
    def initialize
      @starts = Array.new
      @ends = Array.new
      @urls = Array.new
      File.open(DatacenterLookup::DefaultDatacentersPath, "r").readlines.map do |line|
        add(*CSV.parse_line(line))
      end
    end

    def add(start, stop, name, url=nil)
      @starts << IPAddr.new(start).to_i
      @ends << IPAddr.new(stop).to_i
      @urls << url
    end

    def length
      @starts.length
    end

    def find(ipstring)
      ip = IPAddr.new(ipstring).to_i
      high = length
      low = 0
      while high >= low do
        probe = ((high+low)/2).floor.to_i
        return nil unless @starts[probe]
        if @starts[probe] > ip
          high = probe - 1
        elsif @ends[probe] < ip
          low = probe + 1
        else
          return @urls[probe]
        end
      end
      return nil
    end
  end
end

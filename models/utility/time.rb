require "time"

class Time
  def self.iso(val=6)
    now.iso(val)
  end

  def iso(val=6)
    self.utc.iso8601(val)
  end

  def cockroach
    self.utc.strftime("%Y-%m-%d %H:%M:%S.%3N")
  end
end

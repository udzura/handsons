lav = Loadavg.new

if lav.avg_over_1min >= 3
  "1"
else
  "0"
end

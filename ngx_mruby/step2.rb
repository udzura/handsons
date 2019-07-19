lav = Loadavg.new
uname = Uname.new

Nginx.rputs({
  "1min" => lav.avg_over_1min,
  "5min" => lav.avg_over_5min,
  "15min" => lav.avg_over_15min,
  "linux_nodename" => uname.nodename,
  "linux_release" => uname.release
}.to_json)

data = Nginx::Var.new
domain = data.http_host
upstream = ""

case domain
when /apache/
  upstream = "127.0.0.1:8081"
when /nginx/
  upstream = "127.0.0.1:8082"
else
end

upstream

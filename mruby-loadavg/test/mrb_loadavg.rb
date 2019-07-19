##
## Loadavg Test
##

assert("Loadavg#hello") do
  t = Loadavg.new "hello"
  assert_equal("hello", t.hello)
end

assert("Loadavg#bye") do
  t = Loadavg.new "hello"
  assert_equal("hello bye", t.bye)
end

assert("Loadavg.hi") do
  assert_equal("hi!!", Loadavg.hi)
end

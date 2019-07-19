##
## Uname Test
##

assert("Uname#hello") do
  t = Uname.new "hello"
  assert_equal("hello", t.hello)
end

assert("Uname#bye") do
  t = Uname.new "hello"
  assert_equal("hello bye", t.bye)
end

assert("Uname.hi") do
  assert_equal("hi!!", Uname.hi)
end

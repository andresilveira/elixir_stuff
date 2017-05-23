map_n_puts = fn collection, func -> Enum.map(collection, func) |> IO.puts end

# Prints from 1 to 15 with its parity cycling between odd and even
Stream.cycle(~w{ odd even })
|> Stream.zip(1..5)
|> map_n_puts.(fn {parity, number} -> ~s{#{number} is #{parity}.\n} end)

# Prints tic tac with the current time
clock = fn -> Time.utc_now end
Stream.repeatedly(clock)
|> Stream.take(5)
|> Stream.zip(Stream.cycle(~w{TIC TAC}))
|> map_n_puts.(fn {time, tick} -> ~s{#{tick} #{time}\n} end)

now = fn -> DateTime.utc_now |> DateTime.to_unix(:microseconds) end
elapsed = fn time -> now.() - time end
# creates an Stream of the difference between the first value and the next, starting from 0
# we take every two because the stream generated is something like
# 0, 1495363177092068, 28, 1495363177092073, 31, ...
Stream.iterate(0, &(now.() - &1))
|> Stream.take_every(2)
|> Enum.take(5)
|> map_n_puts.(fn elapsed_time -> ~s{#{elapsed_time}µs elapsed\n} end)

# prints how many microseconds have elapsed since the last stream value using Stream.iterate/2
Stream.iterate({0, now.()}, fn {_diff, current} -> { elapsed.(current), now.() } end)
|> Enum.take(5)
|> map_n_puts.(fn {diff, _time} -> ~s{#{diff}µs elapsed\n} end)

# prints how many microseconds have elapsed since the last stream value using Stream.unfold/2
Stream.unfold({0, now.()}, fn {_diff, current} -> { elapsed.(current), {elapsed.(current), now.()} } end)
|> Stream.take(5)
|> map_n_puts.(fn elapsed_time -> ~s{#{elapsed_time}µs elapsed\n} end)

# creates a timer that returns how many seconds until the next minute
# then we pipe the value to be printed and pipe again to the say function
# finally we pipe it to Stream.run/0 to run the stream
sleep_a_second = fn -> receive do after 1000 -> nil end end
say = fn text -> spawn(fn -> :os.cmd('say #{text}') end) end
Stream.resource(
  fn -> Time.utc_now.second end,
  fn
    0 ->
      {:halt, 0}
    count ->
      sleep_a_second.()
      { [inspect(count)], count - 1 }
  end,
  fn _ -> end
)
|> Stream.each(&IO.puts/1)
|> Stream.each(say)
|> Stream.run

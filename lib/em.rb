def em_wait
  while !EM::reactor_running? do
    sleep 1
  end
end

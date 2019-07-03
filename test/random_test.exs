defmodule RandomTest do
  use ExUnit.Case
  doctest Random
  
  test "weighted choice" do
    assert Random.weighted_choice([1,2,3],0.4) == 1
  end
  
  test "blue pts" do
    file = File.open!("points.txt",[:write])
    Random.low_density_blue(5,:cartesian_sq,
      MersenneTwister.init(42) 
      |> Enum.take(101),
      {1,1})
      |> Enum.each( fn {x,y} -> IO.puts(file,"#{x} #{y}") end)
    File.close(file)
  end
end

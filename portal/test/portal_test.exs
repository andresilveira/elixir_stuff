defmodule PortalTest do
  use ExUnit.Case
  doctest Portal
  
  setup_all do
    { :ok,
      orange: Portal.shoot(:orange),
      blue: Portal.shoot(:blue),
      portal: Portal.transfer(:orange, :blue, [1,2,3])
    }
  end
  
  test "initialy orange has all the data (but in inverse order)" do
    assert Portal.Door.get(:orange) == [3,2,1]
    assert Portal.Door.get(:blue)   == []
  end
  
  test "when we push_right data is moved from orange to blue", state do
    Portal.push_right(state[:portal])
    assert Portal.Door.get(:orange) == [2,1]
    assert Portal.Door.get(:blue)   == [3]
  end
  
  test "when we push_left data is moved from blue to orange", state do
    Portal.push_left(state[:portal])
    
    assert Portal.Door.get(:orange) == [3,2,1]
    assert Portal.Door.get(:blue)   == []
  end
end

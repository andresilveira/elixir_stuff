defmodule Portal do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      worker(Portal.Door, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :simple_one_for_one, name: Portal.Supervisor]
    Supervisor.start_link(children, opts)
  end
  
  defstruct [:left, :right]
  
  @doc """
  Shoots a new door with the given `color`.
  """
  def shoot(color) do
    Supervisor.start_child(Portal.Supervisor, [color])
  end
  
  @doc """
  Starts transfering `data` from `left` to `right`.
  """
  def transfer(left, right, data) do
    # First add all data to the portal on the left
    for item <- data do
      Portal.Door.push(left, item)
    end
    
    # Returns a portal struct we will use next
    %Portal{left: left, right: right}
  end
  
  @doc """
  Pushes data from left to right in the given `portal`
  """
  def push_right(portal) do
    # See if we can pop data from the left. If so, push the
    # popped data to the right. Otherwise, do nothing.
    case Portal.Door.pop(portal.left) do
      :error        -> :ok
      {:ok, value}  -> Portal.Door.push(portal.right, value)
    end
    
    portal
  end
  
  @doc """
  Pushes data from right to left in the given `portal`.
  """
  def push_left(portal) do
    case Portal.Door.pop(portal.right) do
      :error        -> :ok
      {:ok, value}  -> Portal.Door.push(portal.left, value)
    end
    
    portal
  end
end

defimpl Inspect, for: Portal do
  def inspect(%Portal{left: left, right: right}, _) do
    left_door = inspect(left)
    right_door = inspect(right)
    
    left_data = inspect(Enum.reverse(Portal.Door.get(left)))
    right_data = inspect(Portal.Door.get(right))
    
    max = max(String.length(left_door), String.length(left_door))
    
    """
    #Portal<
      #{String.rjust(left_door, max)} <=> #{right_door}
      #{String.rjust(left_data, max)} <=> #{right_data}
    >
    """
  end
end

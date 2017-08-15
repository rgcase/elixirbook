defmodule Metex.Cache do
    use GenServer

    @name MC

    ## Client API
    def start_link(opts \\ []) do
        GenServer.start(__MODULE__, :ok, opts ++ [name: MC])
    end

    def write(key, value) do
        GenServer.cast(@name, {:write, key, value})
    end

    def read(key) do
        GenServer.call(@name, {:read, key})
    end

    def delete(key) do
        GenServer.cast(@name, {:delete, key})
    end

    def clear() do
        GenServer.cast(@name, :clear)
    end

    def exist?(key) do
        GenServer.call(@name, {:exist, key})
    end



    ## Server Callbacks
    def init(_args) do
       {:ok, %{}} 
    end

    def handle_call({:read, key}, _from, state) do
        case Map.has_key?(state, key) do
            true -> {:reply, Map.get(state, key), state}
            false -> {:reply, :error, state}
        end
    end

    def handle_call({:exist, key}, _from, state) do
        {:reply, Map.has_key?(state, key), state}
    end

    def handle_cast({:write, key, value}, state) do
        new_state = case Map.has_key?(state, key) do
            true -> Map.update!(state, key, value)
            false -> Map.put_new(state, key, value)
        end
        {:noreply, new_state}
    end

    def handle_cast({:delete, key}, state) do
        new_state = Map.delete(state, key)
        {:noreply, new_state}
    end

    def handle_cast(:clear, _state) do
        {:noreply, %{}}
    end
    

    ## Helper Functions
end
defmodule Metex2.Worker do
    use GenServer

    ## Client API

    def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def get_temperature(pid, location) do
        GenServer.call(pid, {:location, location})
    end

    def get_stats(pid) do
        GenServer.call(pid, :get_stats)
    end

    def reset_stats(pid) do
        GenServer.cast(pid, :reset_stats)
    end

    def stop(pid) do
        GenServer.cast(pid, :stop)
    end

    ## Server Callbacks

    def init(:ok) do
        {:ok, %{}}
    end

    def handle_call({:location, location}, _from, state) do
        case temperature_of(location) do
            {:ok, temp} ->
                new_stats = update_stats(state, location)
                {:reply, "#{temp}C", new_stats}
            _ ->
                {:reply, :error, state}
        end
    end

    def handle_call(:get_stats, _from, stats) do
        {:reply, stats, stats}
    end

    def handle_cast(:reset_stats, _stats) do
        {:noreply, %{}}
    end

    def handle_cast(:stop, stats) do
        {:stop, :normal, stats}
    end

    def terminate(reason, stats) do
        IO.puts "server terminated because of #{inspect reason}"
        inspect stats
        :ok
    end

    ## Helper Functions
    defp temperature_of(location) do
        url_for(location) |> HTTPoison.get |> parse_response
    end

    defp url_for(location) do
        "http://api.openweathermap.org/data/2.5/weather?q=#{location}&APPID=#{apikey()}"
    end

    defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
        body |> JSON.decode! |> compute_temperature
    end

    defp parse_response(_), do: :error

    defp compute_temperature(json) do
        try do
            temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
            {:ok, temp}
        rescue
            _ -> :error
        end
    end

    defp apikey do
        "68da6555a9d2ee5e2eaf6a8da28d1d83"
    end

    defp update_stats(old_stats, location) do
        case Map.has_key?(old_stats, location) do
            true ->
                Map.update!(old_stats, location, &(&1 + 1))
            false ->
                Map.put_new(old_stats, location, 1)
        end
    end

end

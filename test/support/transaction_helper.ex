defmodule Discorelic.TransactionTestHelper do
  defmacro __using__(_opts) do
     quote do
       import Discorelic.TransactionTestHelper
     end
   end

  defmacro assert_recorded_transaction(key, duration) do
    quote do
      assert [ micro_seconds ] = find(unquote(key))
      ms = :erlang.convert_time_unit(micro_seconds, :micro_seconds, :milli_seconds)
      assert Enum.member?(unquote(duration), ms), "Invalid duration for #{ micro_seconds |> inspect }"
    end
  end

  def find(key) do
    key |> to_spec_query |> ets_find
  end

  # You know how crazy this ETS queries are. Discorelic uses statman_histograms
  # to store transactions. These are stored in this format
  # [ {"test_transaction", :total }, 502561 }, 0 ]
  # This helper matches the name of the transaction, and returns an array of the
  # time taken metric in micro_seconds.
  defp to_spec_query(key) do
    [
      {
        { { key, :"$3" }, :"_" },
        [],
        [ :"$3" ]
      }
    ]
  end

  defp ets_find(query) do
    :ets.select(:statman_histograms, query)
  end
end

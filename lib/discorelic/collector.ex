defmodule Discorelic.Collector do
  alias Discorelic.Transaction
  alias Discorelic.TransactionSegment, as: Segment

  def record!(transaction) do
    :ok = deliver_segments(transaction)
    :ok = deliver_total_time(transaction)
    :ok
  end

  defp deliver_total_time(transaction) do
    newrelic_client.record_value(
      { transaction.name, :total }, transaction.duration
    )
  end

  defp deliver_segments(%Transaction{ segments: [] }), do: :ok
  defp deliver_segments(
    %Transaction{ name: name, before_call: before_call, segments: segments }) do
    Enum.each(segments, fn (%Segment{ } = segment) ->
      deliver_segment(name, before_call, segment)
    end)
  end

  defp deliver_segment(
    transaction_name, _, %Segment{ name: name, duration: duration }) do
    newrelic_client.record_value( { transaction_name, name }, duration)
  end

  defp newrelic_client do
    Application.get_env(:discorelic, :newrelic_client, :statman_histogram)
  end
end

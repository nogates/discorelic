defmodule Discorelic.Timer do
  alias Discorelic.Collector
  alias Discorelic.TransactionSegment, as: Segment

  def record(transaction, result \\ nil) do
    transaction
      |> finish
      |> Map.put(:result, result)
      |> publish
  end

  def record_segment(transaction, segment, _, timestamp) do
    segment  = Map.put(segment, :after_call, timestamp)
    segment  = Map.put(segment, :duration, :timer.now_diff(segment.after_call, segment.before_call))
    segments = transaction.segments ++ [ segment ]

    %{ transaction | segments: segments }
  end

  def finish(transaction) do
    transaction = Map.put(transaction, :after_call, :os.timestamp)
    transaction = Map.put(transaction, :duration,
      (:timer.now_diff(transaction.after_call, transaction.before_call))
    )
    transaction
  end

  def publish(transaction) do
    :ok = Collector.record!(transaction)
  end
end

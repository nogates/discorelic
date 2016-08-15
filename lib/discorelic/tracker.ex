defmodule Discorelic.Tracker do
  # Macro implementation
  defmacro record_transaction!({ _, _ } = name, do: expression) do
    var = Macro.var(:transaction, nil)
    quote do
      segment     = init_transaction_segment(unquote(name))
      result      = unquote(expression)
      transaction = Discorelic.Timer.record_segment(unquote(var), segment, result, :os.timestamp)
      var!(unquote(var)) = transaction
    end
  end

  defmacro record_transaction!(name, do: expression) do
    var = Macro.var(:transaction, nil)
    quote do
      transaction  = init_transaction(unquote(name))
      unquote(var) = transaction
      result       = unquote(expression)
      Discorelic.Timer.record(unquote(var), result)
    end
  end

  def init_transaction(name) do
    %Discorelic.Transaction{ name: name, before_call: :os.timestamp }
  end

  def init_transaction_segment(name) do
    %Discorelic.TransactionSegment{ name: name, before_call: :os.timestamp }
  end

  def record(transaction, %Discorelic.TransactionSegment{} = segment) do
    now = :os.timestamp
    Discorelic.Timer.record_segment(transaction, segment, "", now)
  end

  def record(transaction, { module, segment_name }) do
    now     = :os.timestamp
    segment = init_transaction_segment({ module, segment_name })
    segment = %{ segment | before_call: transaction.before_call }
    Discorelic.Timer.record_segment(transaction, segment, "", now)
  end

  def publish(%Discorelic.Transaction{ after_call: nil } = transaction) do
    transaction = Discorelic.Timer.finish(transaction)
    :ok = Discorelic.Timer.publish(transaction)
    { :ok, transaction }
  end
end

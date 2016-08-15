defmodule Discorelic.TransactionSegment do
  defstruct name: nil, before_call: nil, after_call: nil, duration: nil,
            module: nil
end

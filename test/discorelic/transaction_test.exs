defmodule Discorelic.TransactionTest do
  use ExUnit.Case
  use Discorelic.TransactionTestHelper
  import Discorelic.Tracker

  test "Total transaction" do
    :ok = record_transaction! "test_transaction" do
      :timer.sleep 500
    end

    assert_recorded_transaction({ "test_transaction", :total }, 500..520)
  end

  test "transaction with segments" do
    :ok = record_transaction! "test_transaction_with_segments" do
      :timer.sleep 500
      var1 = "variables can be accessed"

      record_transaction!({ Discorelic.TransactionTest, "segment_1" }) do
        var2 = "even here"
        assert var1 == "variables can be accessed"
        var1 = "and changed"
        :timer.sleep 200
      end

      record_transaction!({ Discorelic.TransactionTest, "segment_2" }) do
        assert var1 == "and changed"
        assert var2 == "even here"
        :timer.sleep 100
      end
    end

    assert_recorded_transaction(
      { "test_transaction_with_segments", :total },
      800..820
    )

    assert_recorded_transaction(
      { "test_transaction_with_segments", { Discorelic.TransactionTest, "segment_1" } },
      200..210
    )

    assert_recorded_transaction(
      { "test_transaction_with_segments", { Discorelic.TransactionTest, "segment_2" } },
      100..110
    )
  end

  test "Dynamic transaction" do
    test_pid = self
    defmodule TestDynamic do
      @test_pid test_pid
      def call do
        fn ->
          transaction = Discorelic.Tracker.init_transaction("/asyncTest")

          loop(transaction)
        end |> Task.async
      end

      def loop(transaction) do
        receive do
          :finish  -> { :ok, transaction } = Discorelic.Tracker.publish(transaction) ; loop(transaction)
          :segment -> Discorelic.Tracker.record(transaction, { TestDynamic, "step_1" }) |> loop
          { :manual, segment }-> Discorelic.Tracker.record(transaction, segment) |> loop
          { :record_data, _ } = message -> send @test_pid, message; loop(transaction)
        end
      end
    end

    # start the async task
    task = TestDynamic.call

    # run the async calls
    Task.async fn -> :timer.sleep 400; send(task.pid, :segment) end
    Task.async fn -> :timer.sleep 600; send(task.pid, :finish) end

    # create a segment
    segment = Discorelic.Tracker.init_transaction_segment { TestDynamic, "step_2" }

    # give it sometime, and then pass it to the task so it can be stored into the transaction
    :timer.sleep 205
    send(task.pid, { :manual, segment })

    # give sometime to complete the task
    :timer.sleep 810

    assert_recorded_transaction(
      { "/asyncTest", { Discorelic.TransactionTest.TestDynamic, "step_1" } },
      400..420
    )

    assert_recorded_transaction(
      { "/asyncTest", { Discorelic.TransactionTest.TestDynamic, "step_2" } },
      200..220
    )

    assert_recorded_transaction(
      { "/asyncTest", :total },
      600..620
    )
  end
end

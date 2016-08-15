# Discorelic

Discorelic is an Elixir implementation of the NewRelic intrumentation PaaS. It's based on erlang newrelic, which basically has reversed engineering the python client, so its integration with NewRelic is not 100% perfect.

## Why?

There are a few implementations out there written in Elixir to publish metrics in NewRelic. However, all of them are using either the NewRelic SDK client, which wasn't very easy to work with, or requiring libraries that are not always required for all projects, like `Plug` or `Ecto`, as [`new-relixir`](https://github.com/TheRealReal/new-relixir) is doing.

The aim of this project it to create a library that contains the minimal dependencies and has a consistent way to interact with NewRelic transactions.


## Installation


  1. Add discorelic to your list of dependencies in `mix.exs`:
    ```elixir

    def deps do
      [ { :discorelic, "~> 0.0.1", github: "nogates/discorelic" } ]
    end

    ```

  2. Ensure discorelic is started before your application:

  ```elixir

    def application do
      [ applications: [ :discorelic ] ]
    end
  ```

## Usage

Discorelic uses Elixir's macros in order to provide an easy way to record transactions. Currently it supports:

 - Web transactions / total time:

  ```elixir
  # Basic module transaction
  defmodule MyModule do
    import Discorelic.Tracker

    def request_with_tracking do
      record_transaction! "my_request" do
        my_request
      end
    end
  end

  ```

- Web transactions / Module segments:

  ```elixir
  # Basic module transaction
  defmodule MyModule do
    import Discorelic.Tracker

    def request_with_tracking do
      record_transaction! "my_request" do
        record_transaction! { User, "user_login" } do
          User.login
        end
        record_transaction! { Request, "Http request" } do
          Request.my_request
        end
      end
    end
  end
  ```

- Manually handle async transactions

  ```elixir

  defmodule AsyncTask do
    alias Discorelic.Tracker

    def call(pid) do
      # Create a transaction
      transaction = Tracker.init_transaction "Async Transaction"

      # Initialise a task process with the transaction
      task_pid    = Task.start_link(fn -> loop(transaction) end)

      # Call an external pid process, which will notify the running task at some point
      GenServer.cast(pid, { :async_event, task_pid })
    end

    def loop(%Discorelic.Transaction{} = transaction) do
      receive do
        # the process has completed the first step, record a time set for the module
        # and continue the loop
        { :step_1, _pid } -> Tracker.record(transaction, { AsyncTask, "step 1" }) |> loop
        # You can also provide a transaction segment to this record function
        :wait ->
          transaction_segment = Tracker.init_transaction_segment { AsyncTask, "wait" }
          :timer.sleep 5_000
          Tracker.record(transaction, transaction_segment) |> loop
        # the process has finished. record the transaction
        :finish         -> { :ok, _transaction } = Tracker.publish(transaction)

      end
    end
  end
  ```


## TODO

 - Publish this to hex


## License

Please see [LICENSE](https://github.com/nogates/discorelic/blob/master/LICENSE)

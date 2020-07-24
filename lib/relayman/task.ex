defmodule Relayman.Task do
  alias Relayman.EventStore

  require Logger

  def prune_sources do
    perform(fn ->
      Logger.info(inspect(EventStore.prune_sources!()))
    end)
  end

  def list_sources do
    perform(fn ->
      Logger.info(inspect(EventStore.list_sources!()))
    end)
  end

  defp perform(fun) do
    Application.ensure_all_started(:relayman)

    Logger.info("Starting...")

    start = System.system_time(:millisecond)

    fun.()

    stop = System.system_time(:millisecond)

    Logger.info("Finished in #{stop - start}ms")
  end
end

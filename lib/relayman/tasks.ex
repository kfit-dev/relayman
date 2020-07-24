defmodule Relayman.Task do
  alias Relayman.EventStore

  def prune_sources do
    start()
    EventStore.prune_sources()
  end

  def list_sources do
    start()
    EventStore.list_sources()
  end

  defp start do
    Application.ensure_all_started(:relayman)
  end
end

defmodule Relayman.Task do
  alias Relayman.EventStore

  def clear_sources do
    start()
    EventStore.clear_sources()
  end

  def list_sources do
    start()
    EventStore.list_sources()
  end

  defp start do
    Application.ensure_all_started(:relayman)
  end
end

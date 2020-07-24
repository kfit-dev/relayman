defmodule Relayman.EventStore do
  alias RelaymanWeb.Endpoint
  alias Redis.Command, as: CMD

  def create(event, ttl \\ default_ttl()) do
    event = Map.put(event, :id, UUID.uuid4())
    timestamp = System.system_time(:millisecond)
    source = "source:#{event[:source]}"
    type = event[:type]

    transaction =
      Redis.transaction([
        CMD.set(event.id, event, ~w[PX #{ttl}]),
        CMD.zadd(source, timestamp, event.id)
      ])

    with {:ok, ["OK", 1]} <- transaction,
         :ok <- Endpoint.broadcast!(source, type, event) do
      {:ok, event}
    end
  end

  def read_from(source, event_id) do
    with {:ok, score} <-
           Redis.command(CMD.zscore("source:#{source}", event_id)),
         {:ok, event_ids} <-
           Redis.command(CMD.zrange_by_score_gt("source:#{source}", score)),
         {:ok, events} <-
           Redis.command(CMD.multi_get(event_ids)) do
      {:ok, Redis.Coder.decode(events)}
    end
  end

  def list_sources! do
    Redis.command!(CMD.keys("source:*"))
  end

  def prune_sources!(ttl \\ default_ttl()) do
    score = System.system_time(:millisecond) - ttl
    sources = list_sources!()

    for source <- sources do
      Redis.command!(CMD.zremrange_by_score_lt(source, score))
    end
  end

  defp default_ttl do
    "RELAYMAN_EVENT_TTL_MS"
    |> System.get_env("#{:timer.hours(1)}")
    |> String.to_integer()
  end
end

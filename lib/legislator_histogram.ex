defmodule LegislatorHistogram do
  @moduledoc """
  Documentation for LegislatorHistogram.
  """
  def prepare_histogram do
    all_legislators = get_data()

    all_legislators
    |> Enum.filter(fn legislator ->
      get_in(legislator, ["bio", "gender"]) == "F"
    end)
    |> Enum.flat_map(fn legislator ->
      Map.get(legislator, "terms")
    end)
    |> Enum.filter(fn term ->
      term["type"] == "rep"
    end)
    |> Enum.flat_map(fn term ->
      term_start = term["start"] |> String.slice(0, 4) |> String.to_integer
      term_end = term["end"] |> String.slice(0, 4) |> String.to_integer

      Enum.to_list(term_start..term_end)
    end)
    |> Enum.group_by(fn year -> year end)
    |> Enum.sort_by(fn {k, v} -> k end)
    |> Enum.map(fn {year, reps} ->
      "#{year}: #{Enum.map_join(reps, "", fn rep -> "#" end)}\n"
    end)
    |> Enum.join("")
    |> IO.puts
  end

  def get_data do
    legislators =
      File.read!("../legislators-current.json")
      |> Poison.decode!()
  end
end

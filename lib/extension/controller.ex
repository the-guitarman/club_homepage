defmodule ClubHomepage.Extension.Controller do
  # https://github.com/bitwalker/timex#formatting-a-datetime-via-strftime
  def parse_date_field(params, field, format \\ "%d.%m.%Y") do
    field_name = Atom.to_string(field)

    params  
    |> extract_value(field_name)
    |> check_value
    |> parse_value(field_name, format)
  end

  defp extract_value(params, field_name), do: {:ok, params, params[field_name]}

  defp check_value({:ok, params, nil}), do: {:empty, params, nil}
  defp check_value({:ok, params, value}), do: {:ok, params, value}

  defp parse_value({:empty, params, nil}, _field_name, _format), do: params
  defp parse_value({:ok, params, value}, field_name, format) do
    case Timex.parse(value, format, :strftime) do
      {:ok, timex_datetime} -> Map.put(params, field_name, timex_datetime)
      {:error, error} ->
        IO.inspect error
        Map.put(params, field_name, nil)
    end
  end

  def parse_datetime_field(params, field, format \\ "%d.%m.%Y %H:%M") do
    parse_date_field(params, field, format)
  end

  # defp get_competition_select_options(conn, _) do
  #   query = from(s in ClubHomepage.Competition,
  #                select: {s.name, s.id},
  #                order_by: [desc: s.name])
  #   assign(conn, :competition_options, ClubHomepage.Repo.all(query))
  # end

  # defp get_season_select_options(conn, _) do
  #   query = from(s in ClubHomepage.Season,
  #     select: {s.name, s.id},
  #     order_by: [desc: s.name])
  #   assign(conn, :season_options, ClubHomepage.Repo.all(query))
  # end

  # defp get_team_select_options(conn, _) do
  #   query = from t in ClubHomepage.Team,
  #     select: {t.name, t.id},
  #     order_by: [asc: t.name]
  #   assign(conn, :team_options, ClubHomepage.Repo.all(query))
  # end

  # defp get_opponent_team_select_options(conn, _) do
  #   query = from ot in ClubHomepage.OpponentTeam,
  #     select: {ot.name, ot.id},
  #     order_by: [asc: ot.name]
  #   assign(conn, :opponent_team_options, ClubHomepage.Repo.all(query))
  # end

  # defp get_meeting_point_select_options(conn, _) do
  #   query = from mp in ClubHomepage.MeetingPoint,
  #     join: a in assoc(mp, :address),
  #     select: {[mp.name, " (", a.street, ", ", a.zip_code, " ", a.city, ")"], mp.id},
  #     order_by: [asc: mp.name]
  #   assign(conn, :meeting_point_options, ClubHomepage.Repo.all(query))
  # end
end

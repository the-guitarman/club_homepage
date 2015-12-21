defmodule Extension.SeasonController do
  alias ClubHomepage.Repo
  alias ClubHomepage.Season

  def new_years(year) do
    calculate_new_years(year)
  end
  def new_years do
    %{year: year} = Timex.Date.local
    calculate_new_years(year)
  end

  defp calculate_new_years(year) do
    generate_saison = fn(y)
      -> result = "#{y}-#{(y+1)}"
         case Repo.get_by(Season, name: result) do
           nil -> result
           _ -> nil
         end
    end
    Enum.map(year..(year + 1), generate_saison)
      |> Enum.drop_while(fn(x) -> x == nil end)
  end
end
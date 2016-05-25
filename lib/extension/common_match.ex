defmodule ClubHomepage.Extension.CommonMatch do
  def failure_reasons do
    Application.get_env(:club_homepage, :match)[:failure_reasons]
  end
end

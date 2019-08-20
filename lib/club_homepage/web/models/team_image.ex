defmodule ClubHomepage.TeamImage do
  use ClubHomepage.Web, :model
  use Arc.Ecto.Schema

  schema "team_images" do
    field :year, :integer
    field :attachment, ClubHomepage.Web.TeamUploader.Type
    field :description, :string

    belongs_to :team, ClubHomepage.Team

    timestamps([type: :utc_datetime])
  end

  @cast_fields [:team_id, :year, :description]
  @required_fields [:team_id, :year, :attachment]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(model, params \\ %{}) do
    start_year = Application.get_env(:club_homepage, :common)[:founding_year]
    %{year: current_year} = Timex.local

    model
    |> cast(params, @cast_fields)
    |> cast_attachments(params, [:attachment])
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:team_id)
    |> validate_inclusion(:year, start_year..current_year)
  end
end

defmodule ClubHomepage.TeamImage do
  use ClubHomepage.Web, :model
  use Arc.Ecto.Schema

  schema "team_images" do
    field :year, :integer
    field :attachment, ClubHomepage.Web.TeamUploader.Type
    field :description, :string

    belongs_to :team, ClubHomepage.Team

    timestamps()
  end

  @cast_fields [:team_id, :year, :description]
  @required_fields [:team_id, :year]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    start_year = Application.get_env(:club_homepage, :common)[:founding_year]
    %{year: current_year} = Timex.local

    params = Map.drop(params, [:attachment, "attachment"])

    struct
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:team_id)
    |> validate_inclusion(:year, start_year..current_year)
  end

  def image_changeset(model, params \\ %{}) do
    model
    |> cast(params, @cast_fields)
    |> cast_attachments(params, [:attachment])
    |> validate_required([:attachment])
    #|> prepare_changes(fn(changeset) -> cast_attachments(changeset, params, [:avatar]) end)
  end
end

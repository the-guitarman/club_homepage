defmodule ClubHomepage.TeamImage do
  use ClubHomepage.Web, :model
  use Arc.Ecto.Schema

  schema "team_images" do
    field :year, :integer
    field :attachment, ClubHomepage.TeamUploader.Type
    field :description, :string

    belongs_to :team, ClubHomepage.Team

    timestamps()
  end

  @required_fields [:team_id, :year]
  @optional_fields [:description]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:team_id)
  end

  def image_changeset(model, params \\ %{}) do
    model
    |> cast_attachments(params, [:attachment])
    |> validate_required([:attachment])
  end
end

defmodule ClubHomepage.Permalink do
  use ClubHomepageWeb, :model

  schema "permalinks" do
    field :source_path, :string
    field :destination_path, :string

    timestamps([type: :utc_datetime])
  end

  @cast_fields ~w(source_path destination_path)a
  @required_fields [:source_path, :destination_path]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
  end
end

defmodule ClubHomepage.Permalink do
  use ClubHomepage.Web, :model

  schema "permalinks" do
    field :source_path, :string
    field :destination_path, :string

    timestamps()
  end

  @required_fields ~w(source_path destination_path)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

defmodule ClubHomepage.News do
  use ClubHomepage.Web, :model

  schema "news" do
    field :public, :boolean, default: false
    field :subject, :string
    field :body, :string

    timestamps()
  end

  @cast_fields ~w(public subject body)
  @required_fields [:public, :subject, :body]

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

defmodule ClubHomepage.Secret do
  use ClubHomepage.Web, :model

  schema "secrets" do
    field :key, :string
    field :expires_at, Timex.Ecto.DateTime

    timestamps
  end

  @required_fields ~w()
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> set_attributes
  end

  defp set_attributes(changeset) do
    expires_at = 
      Timex.Date.local
      |> Timex.Date.add(Timex.Time.to_timestamp(7, :days))

    changeset
    |> put_change(:key, SecureRandom.urlsafe_base64)
    |> put_change(:expires_at, expires_at)
  end
end

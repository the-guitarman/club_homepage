defmodule ClubHomepage.PaymentList do
  use ClubHomepage.Web, :model

  schema "payment_lists" do
    belongs_to :user, ClubHomepage.User
    belongs_to :deputy, ClubHomepage.User

    has_many :debitors, ClubHomepage.PaymentListDebitor

    field :title, :string
    field :price_per_piece, :float

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(title user_id price_per_piece), ~w(deputy_id))
    |> validate_required([:title, :user_id, :price_per_piece])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:deputy_id)
    |> validate_number(:price_per_piece, greater_than: 0)
    |> validate_deputy_is_not_the_owner
  end

  defp validate_deputy_is_not_the_owner(changeset) do
    user_id = get_field(changeset, :user_id)
    deputy_id = get_field(changeset, :deputy_id)
    cond do
      user_id != nil && user_id == deputy_id ->
        add_error(changeset, :deputy_id, "owner and deputy can't be the same person")
      true -> changeset
    end
  end
end

defmodule ClubHomepage.User do
  use ClubHomepageWeb, :model

  #alias ClubHomepageWeb.ModelValidator
  alias ClubHomepageWeb.UserRole

  schema "users" do
    field :active, :boolean
    field :birthday, :utc_datetime
    field :login, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string
    field :name, :string
    field :nickname, :string
    field :roles, :string
    field :meta_data, :map
    field :token, :string
    field :token_set_at, :utc_datetime
    field :mobile_phone, :string

    has_many :team_chat_messages, ClubHomepage.TeamChatMessage
    has_many :payment_list_debitor_history_records, ClubHomepage.PaymentListDebitorHistoryRecord, on_delete: :nilify_all, foreign_key: :editor_id
    has_many :standard_team_players, ClubHomepage.StandardTeamPlayer, on_delete: :delete_all, foreign_key: :user_id

    timestamps([type: :utc_datetime])
  end

  def unregistered_changeset(model, params \\ %{}) do
    model
    |> cast(params, [:email, :name, :nickname, :login, :birthday, :active, :roles, :meta_data, :token, :token_set_at, :mobile_phone])
    |> validate_required([:email, :name])
    |> validate_length(:name, max: 100)
    |> check_email
    |> UserRole.check_roles
    |> set_active(false)
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> unregistered_changeset(params)
    |> cast(params, [:login, :birthday])
    |> validate_required([:login, :birthday])
    |> validate_length(:login, min: 6)
    |> validate_length(:login, max: 20)
    |> validate_format(:login, ~r/\A[a-z0-9._-]+\z/i)
    |> update_change(:login, &String.downcase/1)
    |> unique_constraint(:login)
    |> validate_format(:login, ~r/\A[a-z0-9._-]+\z/i)
    #|> ModelValidator.validate_uniqueness(:login)
  end

  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> validate_length(:password, min: 6, max: 100)
    |> validate_length(:password_confirmation, min: 6, max: 100)
    |> validate_confirmation(:password)
    |> put_pass_hash()
    |> set_active(true)
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: pass}} = changeset) do
    put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
  end
  defp put_pass_hash(changeset), do: changeset

  defp set_active(%Ecto.Changeset{data: %ClubHomepage.User{active: nil}} = changeset, state) do
    changeset
    |> put_change(:active, state)
  end
  defp set_active(changeset, _state), do: changeset

  defp check_email(%Ecto.Changeset{data: %ClubHomepage.User{email: nil}} = changeset) do
    changeset
    |> validate_format(:email, ~r/\A[A-Z0-9_\.&%\+\-\']+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,13})\z/i)
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
    #|> ModelValidator.validate_uniqueness(:email)
  end
  defp check_email(changeset) do
    changeset
    |> validate_format(:email, ~r/\A[A-Z0-9_\.&%\+\-\']+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,13})\z/i)
    |> update_change(:email, &String.downcase/1)
  end
end

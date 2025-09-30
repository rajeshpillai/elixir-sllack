defmodule Sllack.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sllack.Accounts.User
  alias Sllack.Chat.Room

  schema "messages" do
    field :body, :string
    belongs_to :user, User
    belongs_to :room, Room

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs, user_scope) do
    message
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> put_change(:user_id, user_scope.user.id)
  end
end

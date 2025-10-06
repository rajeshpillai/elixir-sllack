defmodule Sllack.Chat.Reply do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sllack.Accounts.User
  alias Sllack.Chat.Message

  schema "replies" do
    field :body, :string

    belongs_to :message, Message
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(reply, attrs, user_scope) do
    reply
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> put_change(:user_id, user_scope.user.id)
  end
end

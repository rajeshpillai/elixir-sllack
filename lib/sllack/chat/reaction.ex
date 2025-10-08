defmodule Sllack.Chat.Reaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sllack.Accounts.User
  alias Sllack.Chat.Message

  schema "reactions" do
    field :emoji, :string

    belongs_to :user, User
    belongs_to :message, Message
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(reaction, attrs, _user_scope \\ %{}) do
    reaction
    |> cast(attrs, [:emoji])
    |> unique_constraint([:emoji, :message_id, :user_id])
    |> validate_required([:emoji])
    # |> put_change(:user_id, user_scope.user.id)
  end
end

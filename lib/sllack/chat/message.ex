defmodule Sllack.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :body, :string
    field :user_id, :id
    field :room_id, :id

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

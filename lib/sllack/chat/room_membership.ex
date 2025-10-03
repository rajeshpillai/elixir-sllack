defmodule Sllack.Chat.RoomMembership do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sllack.Accounts.User
  alias Sllack.Chat.Room

  schema "room_memberships" do

    belongs_to :room, Room
    belongs_to :user, User

    field :last_read_at, :utc_datetime_usec

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room_membership, attrs, user_scope) do
    room_membership
    |> cast(attrs, [])
    |> validate_required([])
    |> put_change(:user_id, user_scope.user.id)
  end
end

defmodule Sllack.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset
  alias Sllack.Chat.Message
  alias Sllack.Accounts.User
  alias Sllack.Chat.RoomMembership

  schema "rooms" do
    field :name, :string
    field :topic, :string

    many_to_many :members, User, join_through: RoomMembership
    has_many :messages, Message
    has_many :memberships, RoomMembership

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :topic])
    |> validate_required([:name, :topic])
    |> validate_length(:name, max: 80)
    |> validate_format(:name, ~r/\A[a-z0-9-]+\z/, message: "can only contain lowercase letters, numbers and dashes")
    |> validate_length(:topic, max: 200)
    |> unsafe_validate_unique(:name, Sllack.Repo)
    |> unique_constraint(:name)
  end
end

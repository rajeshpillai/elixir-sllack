defmodule Sllack.Chat do
  alias Sllack.Chat.Message
  alias Sllack.Chat.Room
  alias Sllack.Repo

  import Ecto.Query

  def list_messages_in_room(%Room{id: room_id}) do

    # OR DSL
    # from(m in Message,
    #   where: m.room_id == ^room_id,
    #   order_by: [asc: m.inserted_at, asc: :id]
    # )
    # |> Repo.all()

    Message
    |> where([m], m.room_id == ^room_id)
    |> order_by([m], asc: m.inserted_at, asc: :id)
    |> preload(:user)
    |> Repo.all()


  end

  def list_rooms do
    Repo.all(from Room, order_by: [asc: :name])
  end

  def get_room!(id) do
    Repo.get!(Room, id)
  end

  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  def create_message(room, attrs, user) do
    %Message{room: room, user: user}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

end

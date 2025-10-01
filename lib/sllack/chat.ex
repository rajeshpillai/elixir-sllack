defmodule Sllack.Chat do
  alias Sllack.Chat.Message
  alias Sllack.Chat.Room
  alias Sllack.Repo
  alias Sllack.Accounts.User
  alias Sllack.Chat.RoomMembership

  import Ecto.Query
  @pubsub Sllack.PubSub


  import Ecto.Query


  def subscribe_to_room(room) do
    Phoenix.PubSub.subscribe(@pubsub, topic(room.id))
  end

  def unsubscribe_from_room(room) do
    Phoenix.PubSub.unsubscribe(@pubsub, topic(room.id))
  end

  defp topic(room_id), do: "chat_room:#{room_id}"

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

  def join_room!(room, user) do
    Repo.insert!(%RoomMembership{room: room, user: user})
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
    # %Message{room: room, user: user}
    # |> Message.changeset(attrs)
    # |> Repo.insert()

    with {:ok, message} <-
           %Message{room: room, user: user}
           |> Message.changeset(attrs)
           |> Repo.insert() do
                Phoenix.PubSub.broadcast(@pubsub, topic(room.id), {:new_message, message})
        {:ok, message}
      end
  end

  def delete_message_by_id(id, %User{id: user_id}) do
    message = Repo.get_by(Message, id: id, user_id: user_id)
    Repo.delete(message)

    Phoenix.PubSub.broadcast(@pubsub, topic(message.room_id), {:message_deleted, message})
  end

end

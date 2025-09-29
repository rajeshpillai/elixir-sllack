defmodule Sllack.Chat do
  alias Sllack.Chat.Room
  alias Sllack.Repo

  def list_rooms do
    Repo.all(Room)
  end

  def get_room!(id) do
    Repo.get!(Room, id)
  end
end

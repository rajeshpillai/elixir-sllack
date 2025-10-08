defmodule Sllack.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sllack.Accounts.User
  alias Sllack.Chat.Room
  alias Sllack.Chat.Reply
  alias Sllack.Chat.Reaction

  schema "messages" do
    field :body, :string
    belongs_to :user, User
    belongs_to :room, Room
    has_many :replies, Reply
    has_many :reactions, Reaction

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end

defmodule SllackWeb.ChatRoomLive.Edit do
  use SllackWeb, :live_view

  alias Sllack.Chat

  def mount(%{"id" => id}, _session, socket) do
    room = Chat.get_room!(id)
    # {:ok, assign(socket, room: room, page_title: "Edit chat room")}
    changeset = Chat.change_room(room)
    socket =
      socket
      |> assign(room: room, page_title: "Edit chat room")
      |> assign_form(changeset)

    {:ok, socket}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto w-96 mt-12">
      <.header>
        {@page_title}
        <:actions>
          <.link class="font-normal text-xs text-blue-600 hover:text-blue-700"
            navigate={~p"/rooms/#{@room}"}>
            Back
          </.link>
        </:actions>

      </.header>
      <.simple_form for={@form} id="room-form">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:topic]} type="text" label="Topic" />
        <:actions>
          <.button phx-disable-with="Saving..." class="w-full">Save</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end

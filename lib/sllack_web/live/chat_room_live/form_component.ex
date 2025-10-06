defmodule SllackWeb.ChatRoomLive.FormComponent do
  use SllackWeb, :live_component

  alias Sllack.Chat
  alias Sllack.Chat.Room

  import SllackWeb.RoomComponents

  def render(assigns) do
    ~H"""
    <div id="new-room-form">
      <.room_form form={@form} target={@myself} />
    </div>
    """
  end

  def mount(socket) do
    changeset = Chat.change_room(%Room{})

    socket
    |> assign_form(changeset)
    |> ok()
  end

  def handle_event("validate-room", %{"room" => room_params}, socket) do
    changeset =
      %Room{}
      |> Chat.change_room(room_params)
      |> Map.put(:action, :validate)

    socket
    |> assign_form(changeset)
    |> noreply()
  end

  def handle_event("save-room", %{"room" => room_params}, socket) do
    case Chat.create_room(room_params) do
      {:ok, room} ->
        Chat.join_room!(room, socket.assigns.current_user)

        socket
        |> put_flash(:info, "Created room")
        |> push_navigate(to: ~p"/rooms/#{room}")
        |> noreply()

      {:error, %Ecto.Changeset{} = changeset} ->
        socket
        |> assign_form(changeset)
        |> noreply()
    end
  end

  # NOTE:  This is redundant as the default does the same thing
  # def update(assigns, socket) do
  #   socket
  #   |> assign(:current_user, assigns.current_user)
  #   |> ok()
  # end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end
end

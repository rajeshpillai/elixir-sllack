defmodule SllackWeb.ChatRoomLive do
  use SllackWeb, :live_view

  alias Sllack.Chat.Room
  # - alias Sllack.Repo
  alias Sllack.Chat
  alias Sllack.Chat.Message

  def mount(_params, _session, socket) do
    rooms = Chat.list_rooms()
    {:ok, assign(socket, rooms: rooms)}
  end

  def handle_params(params, _uri, socket) do
    room =
      case Map.fetch(params, "id") do
        {:ok, id} ->
          Chat.get_room!(id)

        :error ->
          List.first(socket.assigns.rooms)
      end

    # {:noreply, assign(socket, room: room, hide_topic?: false, page_title: "#" <> room.name)}
    messages = Chat.list_messages_in_room(room)

    {:noreply,
     socket
     |> assign(room: room, hide_topic?: false, page_title: "#" <> room.name, messages: messages)
     |> assign(:current_scope, socket.assigns[:current_scope])}
  end

  def handle_event("toggle-topic", _params, socket) do
    # {:noreply, assign(socket, :hide_topic?, !socket.assigns.hide_topic?)}
    {:noreply, update(socket, :hide_topic?, &(!&1))}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
    <div class="flex flex-col shrink-0 w-64 bg-slate-100">
      <div class="flex justify-between items-center shrink-0 h-16 border-b border-slate-300 px-4">
        <div class="flex flex-col gap-1.5">
          <h1 class="text-lg font-bold text-gray-800">
            Sllack
          </h1>
        </div>
      </div>
      <div class="mt-4 overflow-auto">
        <div class="flex items-center h-8 px-3">
          <span class="ml-2 leading-none font-medium text-sm">Rooms</span>
        </div>
        <div id="rooms-list">
          <.room_link :for={room <- @rooms} room={room} active={room.id == @room.id} />
        </div>
      </div>
    </div>
    <div class="flex flex-col grow shadow-lg">
      <div class="flex justify-between items-center shrink-0 h-16 bg-white border-b border-slate-300 px-4">
        <div class="flex flex-col gap-1.5">
          <h1 class="text-sm font-bold leading-none">
            #{@room.name}
            <.link class="font-normal text-xs text-blue-600 hover:text-blue-700"
              navigate={~p"/rooms/#{@room}/edit"}>
              Edit
            </.link>
          </h1>
          <div
            class={["text-xs leading-none h-3.5", @hide_topic? && "text-slate-600"]}
            phx-click="toggle-topic"
          >
            <%= if @hide_topic? do %>
              [Topic hidden]
            <% else %>
              {@room.topic}
            <% end %>
          </div>
        </div>
      </div>
        <ul class="menu menu-horizontal w-full relative z-10 flex items-center gap-4 px-4 sm:px-6 lg:px-8 justify-end">
          <%= if @current_scope do %>
            <li>
              {@current_scope.user.email}
            </li>
            <li>
              <.link href={~p"/users/settings"}>Settings</.link>
            </li>
            <li>
              <.link href={~p"/users/log-out"} method="delete">Log out</.link>
            </li>
          <% else %>
            <li>
              <.link href={~p"/users/register"}>Register</.link>
            </li>
            <li>
              <.link href={~p"/users/log-in"}>Log in</.link>
            </li>
          <% end %>
        </ul>
        <div class="flex flex-col grow overflow-auto">
          <.message :for={message <- @messages} message={message} />
        </div>
    </div>
    </Layouts.app>

    """
  end

  attr :message, Message, required: true

  defp message(assigns) do
    ~H"""
    <div class="relative flex px-4 py-3">
      <div class="h-10 w-10 rounded shrink-0 bg-slate-300"></div>
      <div class="ml-2">
        <div class="-mt-1">
          <.link class="text-sm font-semibold hover:underline">
            <span>User</span>
          </.link>
          <p class="text-sm">{@message.body}</p>
        </div>
      </div>
    </div>
    """
  end

  attr :active, :boolean, required: true
  attr :room, Room, required: true

  defp room_link(assigns) do
    ~H"""
    <.link
      class={[
        "flex items-center h-8 text-sm pl-8 pr-3",
        (@active && "bg-slate-300") || "hover:bg-slate-300"
      ]}
      navigate={~p"/rooms/#{@room}"}
    >
      <.icon name="hero-hashtag" class="h-4 w-4" />
      <span class={["ml-2 leading-none", @active && "font-bold"]}>
        {@room.name}
      </span>
    </.link>
    """
  end

end

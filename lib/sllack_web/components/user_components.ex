defmodule SllackWeb.UserComponents do
  use SllackWeb, :html

  alias Sllack.Accounts.User

  attr :user, User
  attr :rest, :global

  def user_avatar(assigns) do
    ~H"""
    <img data-user-avatar-id={@user.id} src={user_avatar_path(@user)} {@rest} />
    """
  end

  defp user_avatar_path(user) do
    if user.avatar_path do
      ~p"/uploads/#{user.avatar_path}"
    else
      ~p"/images/avatar.png"
    end
  end
end

defmodule Sllack.Repo.Migrations.AddLastReadAtToMemberships do
  use Ecto.Migration

  def change do
    alter table(:room_memberships) do
      add :last_read_at, :utc_datetime_usec
    end

  end
end

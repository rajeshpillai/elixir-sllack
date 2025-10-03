defmodule Sllack.Repo.Migrations.AddUsernameToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :username, :string
    end

    execute """
            UPDATE users
            SET username = initcap(substring(email FROM '^[^@]+'));
            """, ""

    alter table(:users) do
      modify :username, :string, null: false, from: {:string, null: true}
    end

    create unique_index(:users, [:username])
  end
end

defmodule Reader.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :ext_no, :integer
      add :type, :string
      add :issued, :date
      add :title, :text
      add :language, :string
      add :authors, :text
      add :subjects, :text
      add :locc, :string
      add :bookshelves, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:books, [:ext_no])
    create index(:books, [:title])
    create index(:books, [:language])
  end
end

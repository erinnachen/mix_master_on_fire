defmodule MixMaster.Repo.Migrations.CreateArtist do
  use Ecto.Migration

  def change do
    create table(:artists) do
      add :name, :string
      add :image_path, :string

      timestamps
    end

  end
end

defmodule MixMaster.Artist do
  use MixMaster.Web, :model

  schema "artists" do
    field :name, :string
    field :image_path, :string

    timestamps
  end

  @required_fields ~w(name image_path)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

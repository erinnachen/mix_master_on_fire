ExUnit.start

Mix.Task.run "ecto.create", ~w(-r MixMaster.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r MixMaster.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(MixMaster.Repo)


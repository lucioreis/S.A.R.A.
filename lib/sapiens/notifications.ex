defmodule Sapiens.Notifications do
  import Ecto.Query, warn: false
  alias Sapiens.Repo, warn: false
  alias Sapiens.Cursos.Notification


  def list_notifications do
    Repo.all(Notification) |> Repo.preload(:actor)
  end

  def get_all_notifications(user_id) do
    Notification
    |> where(estudante_id: ^user_id)
    |> where([n], n.inserted_at >= datetime_add(^NaiveDateTime.utc_now(), -1, "week") )
    |> order_by(desc: :id)
    |> preload(:estudante)
    |> Repo.all
  end

  def build_grade_notification(disciplina, target, msg) do
    Ecto.build_assoc(target, :notifications, %{message: msg})
    %Notification{}
    |> Notification.changeset(%{message: msg})
    |> Ecto.Changeset.put_assoc(:estudante, target)
    |> Ecto.Changeset.put_assoc(:disciplina, disciplina)
  end

  def create_grade_notification(disciplina, target, msg) do
    build_grade_notification(disciplina, target, msg)
    |> Repo.insert()
    |> case do 
      {:ok, note} -> note
      {:error, changeset} -> changeset
    end
  end

  def mark_as_read(notification) do
    notification
    |> Notification.changeset(%{read: true})
    |> Repo.update!()
  end

  def dismiss_all(id) do
    Repo.get_by!(Sapiens.Cursos.Estudante, id: id)
    |> Ecto.assoc(:notifications)
    |> Repo.all()
    |> Enum.map(&mark_as_read/1)
  end
end

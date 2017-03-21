defmodule UcxChat.InvitationService do
  use UcxChat.Web, :service
  alias Coherence.Invitation
  alias UcxChat.User
  import Ecto.Changeset
  import Coherence.ControllerHelpers

  def create_and_send(email, name \\ nil) do
    name = if name, do: name, else: String.split(email, "@") |> hd
    invitation_params = %{email: email, name: name}

    cs = Invitation.changeset(%Invitation{}, invitation_params)
    case Repo.one from u in User, where: u.email == ^email do
      nil ->
        token = random_string 48
        url = UcxChat.Router.Helpers.invitation_url(UcxChat.Endpoint, :edit, token)
        cs = put_change(cs, :token, token)
        case Repo.insert cs do
          {:ok, invitation} ->
            send_user_email :invitation, invitation, url
            {:ok, invitation}
          {:error, changeset} ->
            changeset = case Repo.one from i in Invitation, where: i.email == ^email do
              nil -> changeset
              _invitation ->
                add_error(changeset, :email, ~g"Invitation already sent.")
            end
            {:error, changeset}
        end
      _ ->
        cs = cs
        |> add_error(:email, ~g"User already has an account!")
        {:error, cs}
    end
  end

  def resend(id) do
    case Repo.get(Invitation, id) do
      nil ->
        {:error, ~g"Cound not find the Invitation"}
      invitation ->
        send_user_email :invitation, invitation,
          UcxChat.Router.Helpers.invitation_url(UcxChat.Endpoint, :edit, invitation.token)
        {:ok, ~g"Invitation resent."}
    end
  end
end

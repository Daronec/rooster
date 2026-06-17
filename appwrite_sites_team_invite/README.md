## Appwrite Sites: страница принятия инвайта в команду

### Что это
Статическая страница `/team-invite`, которая принимает query-параметры из письма Appwrite Teams invite и подтверждает membership через API:

- `PATCH /v1/teams/{teamId}/memberships/{membershipId}/status`

### Куда загрузить
Загрузите архив в Appwrite Sites так, чтобы страница была доступна по пути:

- `https://accept-invite-rooster.appwrite.network/team-invite`

### Переменная в приложении
В `.env` приложения:

- `APPWRITE_TEAM_INVITE_RETURN_URL=https://accept-invite-rooster.appwrite.network/team-invite`


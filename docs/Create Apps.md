## Creating a Facebook App

- Create a Facebook app by going [here](https://developers.facebook.com/).
- Go to the basic settings of the app.
- Scroll down and click "Add Platform" then click on "Website".
- In the `Site url field` add the following :

1. If you are running the application locally, then add this `http://localhost:3000`
2. If you are running the application via gitpod, then add your `gitpod url`.

- Now, click "Products" in the sidebar and setup the "Facebook Login" product.
- Go to the settings of "Facebook Login".
- In `Valid OAuth Redirect URIs field` add the following :

1. If you are running the application locally, then add this `http://localhost:3000/users/auth/facebook/callback`.
2. If you are running the application via gitpod, then add this `<gitpod url>/users/auth/facebook/callback` in `Valid OAuth Redirect URIs`.

- Voila :beers: You have created a Facebook app.
- Note the App ID and App Secret.

## Creating a Google App

- Go to the [API Console](https://console.developers.google.com).
- From the projects list, select a project or create a new one.
- If the APIs & services page isn't already open, open the console left side menu and select APIs & services.
- On the left, click Credentials.
- Click New Credentials, then select OAuth client ID
- Choose "Web Application".
- In the `Authorized JavaScript origins field` add the following :

1. If you are running the application locally, then add this `http://localhost:3000`
2. If you are running the application via gitpod, then add your `gitpod url`

- In `Authorized redirect URIs field` add the following :

1. If you are running the application locally, then add this `http://localhost:3000/users/auth/google/callback`.
2. If you are running the application via gitpod, then add this `<gitpod url>/users/auth/google/callback`.

- Voila :beers: You have created a Google app.
- Note the client ID and client Secret.

## Creating a Github App

- Create a Github app by going [here](https://github.com/settings/developers).
- In the `Homepage URL field` add the following :

1. If you are running the application locally, then add this `http://localhost:3000`
2. If you are running the application via gitpod, then add your `gitpod url`.

- In `Authorization callback URL field` add the following :

1. If you are running the application locally, then add this `http://localhost:3000/users/auth/github/callback`.
2. If you are running the application via gitpod, then add this `<gitpod url>/users/auth/github/callback`.

- Voila :beers: You have created a Github app.
- Note the client ID and client Secret.
